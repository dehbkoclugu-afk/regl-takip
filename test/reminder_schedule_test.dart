import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/services/notification_service.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/models/period_record.dart';

void main() {
  test('cycle notification frequency grows from essential to detailed', () {
    expect(cycleNotificationEnabled(1, 1), isTrue);
    expect(cycleNotificationEnabled(1, 2), isFalse);
    expect(cycleNotificationEnabled(2, 2), isTrue);
    expect(cycleNotificationEnabled(2, 3), isFalse);
    expect(cycleNotificationEnabled(3, 3), isTrue);
  });

  group('etkin hatırlatma saatleri', () {
    test('özel saat yoksa genel saate düşer', () {
      final p = UserProfile(reminderHour: 9, reminderMinute: 30);
      expect(p.effectiveCycleHour, 9);
      expect(p.effectiveCycleMinute, 30);
      expect(p.effectiveMedicationHour, 9);
      expect(p.effectiveMedicationMinute, 30);
    });

    test('döngü saati genel saati ezer, ilaç etkilenmez', () {
      final p = UserProfile(
        reminderHour: 9,
        reminderMinute: 0,
        cycleReminderHour: 21,
        cycleReminderMinute: 15,
      );
      expect(p.effectiveCycleHour, 21);
      expect(p.effectiveCycleMinute, 15);
      expect(p.effectiveMedicationHour, 9);
      expect(p.effectiveMedicationMinute, 0);
    });

    test('ilaç saati genel saati ezer, döngü etkilenmez', () {
      final p = UserProfile(
        reminderHour: 20,
        reminderMinute: 0,
        medicationReminderHour: 8,
        medicationReminderMinute: 5,
      );
      expect(p.effectiveMedicationHour, 8);
      expect(p.effectiveMedicationMinute, 5);
      expect(p.effectiveCycleHour, 20);
      expect(p.effectiveCycleMinute, 0);
    });

    test('saat 0 geçerli bir değer — null ile karıştırılmamalı', () {
      final p = UserProfile(
        reminderHour: 9,
        cycleReminderHour: 0,
        cycleReminderMinute: 0,
      );
      expect(p.effectiveCycleHour, 0);
      expect(p.effectiveCycleMinute, 0);
    });
  });

  group('regl hatırlatma penceresi', () {
    test('varsayılan bir gün önce', () {
      expect(UserProfile().periodReminderLeadDays, 1);
    });

    test('değiştirilebilir', () {
      expect(UserProfile(periodReminderLeadDays: 3).periodReminderLeadDays, 3);
    });
  });

  group('yedek JSON gidiş-dönüşü', () {
    test('yeni alanlar korunur', () {
      final original = UserProfile(
        name: 'Test',
        reminderHour: 9,
        reminderMinute: 0,
        cycleReminderHour: 21,
        cycleReminderMinute: 30,
        medicationReminderHour: 8,
        medicationReminderMinute: 15,
        periodReminderLeadDays: 3,
        quietNotifications: true,
        usePounds: true,
        useFahrenheit: true,
        medicationPlan: [
          MedicationEntry(
            name: 'Demir',
            dose: '10 mg',
            reminderTime: '08:00',
          ),
        ],
      );
      final restored = UserProfile.fromJson(original.toJson());

      expect(restored.cycleReminderHour, 21);
      expect(restored.cycleReminderMinute, 30);
      expect(restored.medicationReminderHour, 8);
      expect(restored.medicationReminderMinute, 15);
      expect(restored.periodReminderLeadDays, 3);
      expect(restored.quietNotifications, isTrue);
      expect(restored.usePounds, isTrue);
      expect(restored.useFahrenheit, isTrue);
      expect(restored.medicationPlan.single.name, 'Demir');
      expect(restored.medicationPlan.single.reminderTime, '08:00');
      expect(restored.medicationPlanMigrated, isTrue);
    });

    test('alanları olmayan eski yedek varsayılanlarla okunur', () {
      // Alanlar eklenmeden önce alınmış bir yedeği taklit eder
      final old = <String, dynamic>{
        'name': 'Eski',
        'reminderHour': 9,
        'reminderMinute': 0,
      };
      final restored = UserProfile.fromJson(old);

      // Özel saat yok: genel saate düşmeli (eski davranışın aynısı)
      expect(restored.cycleReminderHour, isNull);
      expect(restored.medicationReminderHour, isNull);
      expect(restored.effectiveCycleHour, 9);
      expect(restored.effectiveMedicationHour, 9);
      expect(restored.periodReminderLeadDays, 1);
      // Eski yedekte alan yok: sessizlik kapalı, yani eski davranış
      expect(restored.quietNotifications, isFalse);
      expect(restored.usePounds, isFalse);
      expect(restored.useFahrenheit, isFalse);
      expect(restored.medicationPlan, isEmpty);
      expect(restored.medicationPlanMigrated, isFalse);
      expect(restored.cycleNotificationFrequency, 3);
    });
  });

  group('sessiz bildirim tercihi', () {
    test('varsayılan kapalı — mevcut kullanıcının davranışı değişmez', () {
      expect(UserProfile().quietNotifications, isFalse);
    });

    test('copyWith tercihi taşır ve diğer alanları bozmaz', () {
      final p = UserProfile(periodReminderLeadDays: 3);
      final quiet = p.copyWith(quietNotifications: true);
      expect(quiet.quietNotifications, isTrue);
      expect(quiet.periodReminderLeadDays, 3);
      // copyWith yeni nesne döndürür: kaynak değişmemeli
      expect(p.quietNotifications, isFalse);
    });

    test('copyWith tercihi açıkken kapatabilir', () {
      final p = UserProfile(quietNotifications: true);
      expect(p.copyWith(quietNotifications: false).quietNotifications, isFalse);
      // Verilmezse korunur
      expect(p.copyWith(name: 'X').quietNotifications, isTrue);
    });
  });

  group('döngü bildirimi yoğunluğu', () {
    test('varsayılan ayrıntılıdır ve copyWith ile değişir', () {
      final profile = UserProfile();
      expect(profile.cycleNotificationFrequency, 3);
      expect(
        profile.copyWith(cycleNotificationFrequency: 1)
            .cycleNotificationFrequency,
        1,
      );
    });

    test('yedekten gelen değer güvenli aralığa sıkıştırılır', () {
      expect(
        UserProfile.fromJson({'cycleNotificationFrequency': 99})
            .cycleNotificationFrequency,
        3,
      );
      expect(
        UserProfile.fromJson({'cycleNotificationFrequency': -2})
            .cycleNotificationFrequency,
        1,
      );
    });
  });
}
