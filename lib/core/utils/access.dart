import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../services/ad_service.dart';

bool shouldShowTrialEndNotice({
  required AccessLevel access,
  required bool alreadyShown,
  required bool onboardingCompleted,
}) =>
    access == AccessLevel.free && !alreadyShown && onboardingCompleted;

bool canWriteDailyTracking(AccessLevel access) => access != AccessLevel.free;

/// Premium kapısı: erişim varsa true; ücretsiz katmandaysa paywall'ı
/// açar ve false döner. Rota dışı giriş noktaları (sheet, buton) için —
/// rotalar router redirect'iyle korunur.
bool ensurePremiumAccess(BuildContext context, WidgetRef ref) {
  if (canWriteDailyTracking(ref.read(accessProvider))) return true;
  GoRouter.of(context).push('/paywall');
  return false;
}

/// Takip ekranlarının salt-okunur katmanı: ekran ve geçmiş görünür kalır,
/// yalnız veri değiştiren eylem plan ekranına gider.
bool ensureTrackingWriteAccess(BuildContext context, WidgetRef ref) =>
    ensurePremiumAccess(context, ref);

/// Başarılı kullanıcı kaydını uygulama köküne bildirir. Reklam gösterilip
/// gösterilmeyeceği burada değil, erişim ve 24 saat sınırı yeniden
/// doğrulandıktan sonra kökte kararlaştırılır.
void notifyTrackingRecordSaved() => AdService.notifyRecordSaved();

bool shouldNotifyTrackingRecord(SnackBarClosedReason reason) =>
    reason != SnackBarClosedReason.action;

/// Geri alınabilir kayıt reklamla kesilmez. Kullanıcı Geri Al'a basarsa
/// ortada kalıcı kayıt yoktur ve reklam olayı üretilmez.
void notifyTrackingRecordAfterUndoWindow(
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller,
) {
  unawaited(controller.closed.then((reason) {
    if (shouldNotifyTrackingRecord(reason)) notifyTrackingRecordSaved();
  }));
}
