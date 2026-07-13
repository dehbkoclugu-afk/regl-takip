import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/pin_utils.dart';

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

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _isError = false;
      _pin += digit;
    });
    if (_pin.length == 4) {
      _handlePinComplete();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _isError = false;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _handlePinComplete() async {
    if (!_isConfirming) {
      // First entry - save and ask for confirmation
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _isConfirming = true;
      });
    } else {
      // Confirmation entry
      if (_pin == _firstPin) {
        await _storage.write(key: 'app_pin', value: PinUtils.hashPin(_pin));
        if (mounted) Navigator.of(context).pop(true);
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _isError = true;
          _pin = '';
          _firstPin = null;
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryStrong, AppColors.secondaryStrong],
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
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 28),
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
                style: TextStyle(
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
              const SizedBox(height: 32),
              _buildPinDots(),
              const Spacer(),
              _buildNumpad(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Semantics(
      label: '${_pin.length}/4',
      liveRegion: true,
      child: ExcludeSemantics(child: _buildPinDotsRow()),
    );
  }

  Widget _buildPinDotsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final isFilled = i < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: isFilled ? 18 : 14,
          height: isFilled ? 18 : 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isError
                ? Colors.yellow.shade200
                : isFilled
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
            border: !isFilled
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.5), width: 2)
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    final digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: digits.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key.isEmpty) return const SizedBox(width: 72);
                if (key == 'del') {
                  return Semantics(
                    button: true,
                    label: MaterialLocalizations.of(context)
                        .deleteButtonTooltip,
                    child: _numpadButton(
                      child: const Icon(Icons.backspace_rounded,
                          color: Colors.white, size: 24),
                      onTap: _onDelete,
                    ),
                  );
                }
                return _numpadButton(
                  child: Text(key,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  onTap: () => _onDigit(key),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _numpadButton({required Widget child, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(36),
        splashColor: Colors.white24,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
