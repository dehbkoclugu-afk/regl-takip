import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/motion.dart';
import '../../core/utils/pin_utils.dart';
import '../../providers/providers.dart';

class LockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  String _enteredPin = '';
  bool _isError = false;

  // Brute-force koruması: 5 yanlış denemeden sonra artan bekleme süresi
  static const _maxFreeAttempts = 5;
  static const _attemptsKey = 'pin_failed_attempts';
  static const _lockoutKey = 'pin_lockout_until';
  int _lockoutRemainingSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _restoreLockout();
    _tryBiometric();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  bool get _isLockedOut => _lockoutRemainingSeconds > 0;

  Future<void> _restoreLockout() async {
    final stored = await _storage.read(key: _lockoutKey);
    final until = int.tryParse(stored ?? '');
    if (until == null) return;
    final remainingMs = until - DateTime.now().millisecondsSinceEpoch;
    if (remainingMs > 0 && mounted) {
      _startLockoutCountdown((remainingMs / 1000).ceil());
    }
  }

  void _startLockoutCountdown(int seconds) {
    _lockoutTimer?.cancel();
    setState(() => _lockoutRemainingSeconds = seconds);
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _lockoutRemainingSeconds--;
        if (_lockoutRemainingSeconds <= 0) {
          timer.cancel();
          _lockoutRemainingSeconds = 0;
        }
      });
    });
  }

  Future<void> _registerFailedAttempt() async {
    final stored = await _storage.read(key: _attemptsKey);
    final attempts = (int.tryParse(stored ?? '') ?? 0) + 1;
    await _storage.write(key: _attemptsKey, value: attempts.toString());

    if (attempts >= _maxFreeAttempts) {
      // Her fazladan yanlış deneme bekleme süresini 30 sn artırır (max 5 dk)
      final lockoutSeconds =
          (30 * (attempts - _maxFreeAttempts + 1)).clamp(30, 300);
      final until = DateTime.now()
          .add(Duration(seconds: lockoutSeconds))
          .millisecondsSinceEpoch;
      await _storage.write(key: _lockoutKey, value: until.toString());
      if (mounted) _startLockoutCountdown(lockoutSeconds);
    }
  }

  Future<void> _clearFailedAttempts() async {
    await _storage.delete(key: _attemptsKey);
    await _storage.delete(key: _lockoutKey);
  }

  Future<void> _tryBiometric() async {
    final profile = ref.read(userProfileProvider);
    if (profile?.biometricEnabled != true) return;

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isDeviceSupported) return;
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      final authenticated = await _localAuth.authenticate(
        localizedReason: l10n.unlockWithBiometric,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated && mounted) {
        widget.onUnlocked();
      }
    } catch (_) {
      // Biyometrik başarısız - PIN ekranında kalsın
    }
  }

  void _onDigitPressed(String digit) {
    if (_isLockedOut) return;
    if (_enteredPin.length >= 4) return;
    setState(() {
      _isError = false;
      _enteredPin += digit;
    });
    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _isError = false;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    final stored = await _storage.read(key: 'app_pin');
    final enteredHash = PinUtils.hashPin(_enteredPin);

    // Yeni format: hash karşılaştır. Eski format: düz PIN — eşleşirse
    // hash'e yükselt (geçmiş sürümden gelen kullanıcılar kilitlenmesin).
    final isLegacyMatch = stored != null && stored == _enteredPin;
    final isMatch = stored != null && (stored == enteredHash || isLegacyMatch);

    if (isMatch) {
      if (isLegacyMatch) {
        await _storage.write(key: 'app_pin', value: enteredHash);
      }
      await _clearFailedAttempts();
      widget.onUnlocked();
    } else {
      HapticFeedback.heavyImpact();
      await _registerFailedAttempt();
      if (!mounted) return;
      setState(() {
        _isError = true;
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider);
    final motion = context.motionEnabled;

    Widget lockIcon = Icon(Icons.lock_rounded,
        size: 48, color: Colors.white.withValues(alpha: 0.9));
    if (motion) {
      lockIcon = lockIcon
          .animateSafe(context)
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.5, 0.5));
    }

    Widget title = Text(
      l10n.enterPin,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
    if (motion) title = title.animateSafe(context).fadeIn(delay: 200.ms);

    Widget wrongPinText = Text(
      l10n.wrongPin,
      style: TextStyle(
        fontSize: 14,
        color: Colors.yellow.shade200,
      ),
    );
    if (motion) {
      wrongPinText = wrongPinText.animateSafe(context).shakeX(hz: 4, amount: 4);
    }

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
              const Spacer(flex: 2),
              lockIcon,
              const SizedBox(height: 16),
              title,
              if (_isLockedOut)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.tooManyAttempts(_lockoutRemainingSeconds),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.yellow.shade200,
                    ),
                  ),
                )
              else if (_isError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: wrongPinText,
                ),
              const SizedBox(height: 32),
              _buildPinDots(),
              const Spacer(),
              _buildNumpad(),
              const SizedBox(height: 16),
              if (profile?.biometricEnabled == true)
                TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint_rounded,
                      color: Colors.white, size: 28),
                  label: Text(
                    l10n.unlockWithBiometric,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Semantics(
      label: '${_enteredPin.length}/4',
      liveRegion: true,
      child: ExcludeSemantics(child: _buildPinDotsRow()),
    );
  }

  Widget _buildPinDotsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final isFilled = i < _enteredPin.length;
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
                ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2)
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
                      onTap: _onDeletePressed,
                    ),
                  );
                }
                return _numpadButton(
                  child: Text(key,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  onTap: () => _onDigitPressed(key),
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
