import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/enums.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/services/backup_service.dart';
import 'package:regl_takip/services/hive_service.dart';

void main() {
  group('BackupService.parseBackup', () {
    final service = BackupService(HiveService());

    test('valid backup parses with counts', () {
      final json = jsonEncode({
        'app': 'regl_takip',
        'version': 1,
        'exportedAt': '2026-07-13T10:00:00.000',
        'profile': UserProfile(name: 'Test').toJson(),
        'periodRecords': [
          PeriodRecord(id: 'r1', startDate: DateTime(2026, 6, 1)).toJson(),
        ],
        'dailyLogs': [
          DailyLog(id: 'l1', date: DateTime(2026, 6, 2)).toJson(),
        ],
      });
      final data = service.parseBackup(json);
      expect(data.profile?.name, 'Test');
      expect(data.periodRecords.length, 1);
      expect(data.dailyLogs.length, 1);
      expect(data.totalRecordCount, 2);
    });

    test('rejects non-JSON', () {
      expect(() => service.parseBackup('bu json değil'),
          throwsA(isA<BackupException>()));
    });

    test('rejects foreign app file', () {
      expect(
          () => service.parseBackup(jsonEncode({'app': 'other', 'version': 1})),
          throwsA(isA<BackupException>()));
    });

    test('rejects unsupported version', () {
      expect(
          () => service
              .parseBackup(jsonEncode({'app': 'regl_takip', 'version': 99})),
          throwsA(isA<BackupException>()));
    });

    test('empty lists tolerated', () {
      final data = service
          .parseBackup(jsonEncode({'app': 'regl_takip', 'version': 1}));
      expect(data.profile, isNull);
      expect(data.totalRecordCount, 0);
    });
  });

  group('UserProfile JSON round-trip', () {
    test('all fields survive', () {
      final profile = UserProfile(
        name: 'Ayşe',
        birthDate: DateTime(1995, 6, 15),
        averageCycleLength: 30,
        averagePeriodLength: 6,
        pinEnabled: true,
        biometricEnabled: true,
        onboardingCompleted: true,
        language: 'en',
        lastPeriodStart: DateTime(2026, 7, 1),
        periodReminderEnabled: false,
        ovulationReminderEnabled: false,
        medicationReminderEnabled: true,
        reminderHour: 21,
        reminderMinute: 30,
        darkModeEnabled: true,
        waterGoal: 10,
      );

      final restored = UserProfile.fromJson(
          jsonDecode(jsonEncode(profile.toJson())) as Map<String, dynamic>);

      expect(restored.name, 'Ayşe');
      expect(restored.birthDate, DateTime(1995, 6, 15));
      expect(restored.averageCycleLength, 30);
      expect(restored.averagePeriodLength, 6);
      expect(restored.pinEnabled, isTrue);
      expect(restored.biometricEnabled, isTrue);
      expect(restored.onboardingCompleted, isTrue);
      expect(restored.language, 'en');
      expect(restored.lastPeriodStart, DateTime(2026, 7, 1));
      expect(restored.periodReminderEnabled, isFalse);
      expect(restored.ovulationReminderEnabled, isFalse);
      expect(restored.medicationReminderEnabled, isTrue);
      expect(restored.reminderHour, 21);
      expect(restored.reminderMinute, 30);
      expect(restored.darkModeEnabled, isTrue);
      expect(restored.waterGoal, 10);
    });

    test('missing fields fall back to defaults', () {
      final restored = UserProfile.fromJson({});
      expect(restored.averageCycleLength, 28);
      expect(restored.language, 'tr');
      expect(restored.lastPeriodStart, isNull);
    });
  });

  group('PeriodRecord JSON round-trip', () {
    test('completed record', () {
      final record = PeriodRecord(
        id: 'abc',
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 5),
        notes: 'not',
      );
      final restored = PeriodRecord.fromJson(
          jsonDecode(jsonEncode(record.toJson())) as Map<String, dynamic>);
      expect(restored.id, 'abc');
      expect(restored.startDate, DateTime(2026, 7, 1));
      expect(restored.endDate, DateTime(2026, 7, 5));
      expect(restored.notes, 'not');
    });

    test('ongoing record keeps null endDate', () {
      final record = PeriodRecord(id: 'x', startDate: DateTime(2026, 7, 10));
      final restored = PeriodRecord.fromJson(record.toJson());
      expect(restored.isOngoing, isTrue);
    });
  });

  group('DailyLog JSON round-trip', () {
    test('full log survives including nested entries and enums', () {
      final log = DailyLog(
        id: 'log1',
        date: DateTime(2026, 7, 12),
        symptoms: [
          SymptomEntry(type: SymptomType.cramp, severity: 3),
          SymptomEntry(type: SymptomType.headache),
        ],
        mood: MoodEntry(type: MoodType.calm, note: 'iyi'),
        temperature: 36.7,
        temperatureTime: '08:00',
        weight: 60.5,
        waterIntake: 6,
        sleepStart: '23:30',
        sleepEnd: '07:15',
        sleepQuality: 4,
        sexualActivity: SexualActivityEntry(
            protectionMethod: ProtectionMethod.condom, orgasm: true),
        medications: [
          MedicationEntry(name: 'Parol', dose: '500mg', taken: true),
        ],
        notes: 'günlük not',
        flowIntensity: FlowIntensity.heavy,
        flowColor: FlowColor.darkRed,
        hasClots: true,
        padChangeCount: 4,
        ovulationTestPositive: true,
      );

      final restored = DailyLog.fromJson(
          jsonDecode(jsonEncode(log.toJson())) as Map<String, dynamic>);

      expect(restored.id, 'log1');
      expect(restored.dateKey, '2026-07-12');
      expect(restored.symptoms.length, 2);
      expect(restored.symptoms.first.type, SymptomType.cramp);
      expect(restored.symptoms.first.severity, 3);
      expect(restored.mood?.type, MoodType.calm);
      expect(restored.mood?.note, 'iyi');
      expect(restored.temperature, 36.7);
      expect(restored.weight, 60.5);
      expect(restored.waterIntake, 6);
      expect(restored.sleepQuality, 4);
      expect(restored.sexualActivity?.protectionMethod,
          ProtectionMethod.condom);
      expect(restored.sexualActivity?.orgasm, isTrue);
      expect(restored.medications.single.name, 'Parol');
      expect(restored.medications.single.taken, isTrue);
      expect(restored.notes, 'günlük not');
      expect(restored.flowIntensity, FlowIntensity.heavy);
      expect(restored.flowColor, FlowColor.darkRed);
      expect(restored.hasClots, isTrue);
      expect(restored.padChangeCount, 4);
      expect(restored.ovulationTestPositive, isTrue);
    });

    test('unknown enum names are skipped, not fatal', () {
      final restored = DailyLog.fromJson({
        'id': 'x',
        'date': '2026-07-12T00:00:00.000',
        'symptoms': [
          {'type': 'futureSymptomFromV9', 'severity': 2},
          {'type': 'cramp', 'severity': 1},
        ],
        'mood': {'type': 'futureMood'},
        'flowIntensity': 'ultraMega',
      });
      // Bilinmeyen semptom atlanır, bilinen kalır
      expect(restored.symptoms.length, 1);
      expect(restored.symptoms.single.type, SymptomType.cramp);
      // Bilinmeyen mood/flow null olur
      expect(restored.mood, isNull);
      expect(restored.flowIntensity, isNull);
    });
  });

  group('enumFromName', () {
    test('resolves valid names and rejects unknown', () {
      expect(enumFromName(MoodType.values, 'happy'), MoodType.happy);
      expect(enumFromName(MoodType.values, 'nonexistent'), isNull);
      expect(enumFromName(MoodType.values, null), isNull);
    });
  });
}
