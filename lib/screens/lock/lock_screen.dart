import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/motion.dart';
import '../../core/utils/pin_lockout.dart';
import '../../core/utils/pin_utils.dart';
import '../../providers/providers.dart';
import 'widgets/pin_pad.dart';

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
  bool _isVerifying = false;

  // Brute-force koruması: 5 yanlış denemeden sonra artan bekleme süresi
  final _lockout = PinLockout();
  int _lockoutRemainingSeconds = 0;
  Timer? _lockoutTimer;
  // Kalan bekleme süresi diskten okunana kadar giriş kabul edilmez, yoksa
  // uygulamayı yeniden başlatmak bekleme süresini atlatmanın yolu olur
  bool _lockoutRestored = false;

  @override
  void initState() {
    super.initState();
    _restoreLockout();
    _recoverIfPinMissing();
    _tryBiometric();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  bool get _isLockedOut => _lockoutRemainingSeconds > 0;
  bool get _acceptsInput =>
      _lockoutRestored && !_isLockedOut && !_isVerifying;

  /// Hive geri yüklendiği hâlde secure storage boşsa (cihaz yedeğinden
  /// dönüş, Keystore sıfırlanması) `pinEnabled` açık ama PIN yok olur —
  /// kullanıcı asla giremeyeceği bir ekranda kilitli kalır. Böyle bir
  /// durumda kilidi kapat ve içeri al.
  Future<void> _recoverIfPinMissing() async {
    final profile = ref.read(userProfileProvider);
    if (profile?.pinEnabled != true) return;
    final stored = await _storage.read(key: 'app_pin');
    if (stored != null || !mounted) return;
    await ref.read(userProfileProvider.notifier).saveProfile(pinEnabled: false);
    if (!mounted) return;
    // Biyometri hâlâ açıksa kilit ekranı orada kalır; değilse içeri gir
    final p = ref.read(userProfileProvider);
    if (p?.biometricEnabled != true) widget.onUnlocked();
  }

  Future<void> _restoreLockout() async {
    final remaining = await _lockout.remainingSeconds();
    if (!mounted) return;
    if (remaining > 0) _startLockoutCountdown(remaining);
    setState(() => _lockoutRestored = true);
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
    final lockoutSeconds = await _lockout.registerFailure();
    if (lockoutSeconds > 0 && mounted) {
      _startLockoutCountdown(lockoutSeconds);
    }
  }

  Future<void> _clearFailedAttempts() => _lockout.clear();

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
        await _clearFailedAttempts();
        widget.onUnlocked();
      }
    } catch (_) {
      // Biyometrik başarısız - PIN ekranında kalsın
    }
  }

  void _onDigitPressed(String digit) {
    if (!_acceptsInput) return;
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
    if (!_acceptsInput || _enteredPin.isEmpty) return;
    setState(() {
      _isError = false;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    if (_isLockedOut) return;
    setState(() => _isVerifying = true);
    final entered = _enteredPin;

    try {
      final stored = await _storage.read(key: 'app_pin');
      if (stored == null) {
        // PIN kaydı yok: _recoverIfPinMissing devrede, burada kilitleme
        return;
      }

      // PBKDF2 50k tur — UI thread'i kilitlememek için isolate'ta
      final isMatch = await compute(verifyPinTask, [stored, entered]);

      if (isMatch) {
        if (!PinUtils.isModern(stored)) {
          // Eski format (düz metin / tuzsuz SHA-256) → tuzlu PBKDF2'ye yükselt
          final upgraded = await compute(encodePinTask, entered);
          await _storage.write(key: 'app_pin', value: upgraded);
        }
        await _clearFailedAttempts();
        if (!mounted) return;
        widget.onUnlocked();
        return;
      }

      HapticFeedback.heavyImpact();
      await _registerFailedAttempt();
      if (!mounted) return;
      setState(() {
        _isError = true;
        _enteredPin = '';
      });
    } finally {
      if (mounted) setState(() => _isVerifying = false);
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
      style: const TextStyle(
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
            colors: [AppColors.primaryStrong, AppColors.primaryDeep],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                            textAlign: TextAlign.center,
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
                      PinDots(filled: _enteredPin.length, isError: _isError),
                      const Spacer(),
                      PinPad(
                        onDigit: _onDigitPressed,
                        onDelete: _onDeletePressed,
                        enabled: _acceptsInput,
                      ),
                      const SizedBox(height: 16),
                      if (profile?.biometricEnabled == true)
                        TextButton.icon(
                          onPressed: _tryBiometric,
                          icon: const Icon(Icons.fingerprint_rounded,
                              color: Colors.white, size: 28),
                          label: Text(
                            l10n.unlockWithBiometric,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
