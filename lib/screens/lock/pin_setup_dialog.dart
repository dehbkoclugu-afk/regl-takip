import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/pin_utils.dart';
import 'widgets/pin_pad.dart';

/// Shows a full-screen PIN setup flow. Returns true if PIN was set successfully.
Future<bool> showPinSetupDialog(BuildContext context) async {
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const _PinSetupScreen(),
    ),
  );
  return result == true;
}

/// Mevcut PIN'i doğrulatan tam ekran akış. Doğrulanırsa true döner.
/// PIN'i kaldırmak gibi güvenlik ayarlarını gevşeten işlemler, kilidi
/// açık unutulmuş bir telefonda tek dokunuşla yapılamamalı.
Future<bool> showPinVerifyDialog(BuildContext context) async {
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const _PinVerifyScreen(),
    ),
  );
  return result == true;
}

class _PinVerifyScreen extends StatefulWidget {
  const _PinVerifyScreen();

  @override
  State<_PinVerifyScreen> createState() => _PinVerifyScreenState();
}

class _PinVerifyScreenState extends State<_PinVerifyScreen> {
  final _storage = const FlutterSecureStorage();
  String _pin = '';
  bool _isError = false;
  bool _isVerifying = false;

  void _onDigit(String digit) {
    if (_isVerifying || _pin.length >= 4) return;
    setState(() {
      _isError = false;
      _pin += digit;
    });
    if (_pin.length == 4) {
      _verify();
    }
  }

  void _onDelete() {
    if (_isVerifying || _pin.isEmpty) return;
    setState(() {
      _isError = false;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verify() async {
    setState(() => _isVerifying = true);
    final stored = await _storage.read(key: 'app_pin');
    if (stored == null) {
      // Kayıt yoksa doğrulanacak şey de yok — engel olma
      if (mounted) Navigator.of(context).pop(true);
      return;
    }
    final ok = await compute(verifyPinTask, [stored, _pin]);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _isError = true;
      _pin = '';
      _isVerifying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryStrong, AppColors.primaryDeep],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: _isVerifying
                      ? null
                      : () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 28),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                ),
              ),
              const Spacer(flex: 2),
              Icon(
                Icons.lock_open_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.verifyPinTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (_isError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.wrongPin,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.yellow.shade200,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              PinDots(filled: _pin.length, isError: _isError),
              const Spacer(),
              PinPad(
                onDigit: _onDigit,
                onDelete: _onDelete,
                enabled: !_isVerifying,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinSetupScreen extends StatefulWidget {
  const _PinSetupScreen();

  @override
  State<_PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<_PinSetupScreen> {
  final _storage = const FlutterSecureStorage();
  String _pin = '';
  String? _firstPin;
  bool _isConfirming = false;
  bool _isError = false;
  bool _isSaving = false;

  void _onDigit(String digit) {
    if (_isSaving || _pin.length >= 4) return;
    setState(() {
      _isError = false;
      _pin += digit;
    });
    if (_pin.length == 4) {
      _handlePinComplete();
    }
  }

  void _onDelete() {
    if (_isSaving || _pin.isEmpty) return;
    setState(() {
      _isError = false;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _handlePinComplete() async {
    if (!_isConfirming) {
      // İlk giriş: onay için sakla
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _isConfirming = true;
      });
      return;
    }

    if (_pin != _firstPin) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isError = true;
        _pin = '';
        _firstPin = null;
        _isConfirming = false;
      });
      return;
    }

    setState(() => _isSaving = true);
    // PBKDF2 türetmesi isolate'ta: UI donmasın
    final encoded = await compute(encodePinTask, _pin);
    await _storage.write(key: 'app_pin', value: encoded);
    // Yeni PIN kurulduysa eski kilitlenme sayacı da sıfırlanmalı
    await _storage.delete(key: 'pin_failed_attempts');
    await _storage.delete(key: 'pin_lockout_until');
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryStrong, AppColors.primaryDeep],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed:
                      _isSaving ? null : () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 28),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                ),
              ),
              const Spacer(flex: 2),
              Icon(
                _isConfirming ? Icons.check_circle_outline : Icons.pin_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 16),
              Text(
                _isConfirming ? l10n.confirmPin : l10n.createPin,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (_isError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.pinMismatch,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.yellow.shade200,
                    ),
                  ),
                ),
              // PIN unutulursa kurtarma yolu yok: tek çıkış verinin
              // silinmesi. Bunu kurulum anında söylemek zorunlu — sonradan
              // öğrenen kullanıcı yıllarının kaydını kaybediyor.
              if (!_isConfirming)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
                  child: Text(
                    l10n.pinNoRecoveryWarning,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              PinDots(filled: _pin.length, isError: _isError),
              const Spacer(),
              PinPad(
                onDigit: _onDigit,
                onDelete: _onDelete,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
