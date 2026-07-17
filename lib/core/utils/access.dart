import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';

/// Premium kapısı: erişim varsa true; ücretsiz katmandaysa paywall'ı
/// açar ve false döner. Rota dışı giriş noktaları (sheet, buton) için —
/// rotalar router redirect'iyle korunur.
bool ensurePremiumAccess(BuildContext context, WidgetRef ref) {
  if (ref.read(accessProvider) != AccessLevel.free) return true;
  GoRouter.of(context).push('/paywall');
  return false;
}
