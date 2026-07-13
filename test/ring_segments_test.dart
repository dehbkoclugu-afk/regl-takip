import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/theme/app_colors.dart';
import 'package:regl_takip/screens/dashboard/widgets/cycle_progress_ring.dart';

void main() {
  group('ringSegmentsFor', () {
    test('28/5 cycle produces the four expected bands', () {
      // ovülasyon günü 15, fertil 10-16
      final segments = ringSegmentsFor(28, 5);
      expect(segments.length, 4);

      expect(segments[0].startDay, 1);
      expect(segments[0].endDay, 5);
      expect(segments[0].color, AppColors.ringMenstrual);

      expect(segments[1].startDay, 6);
      expect(segments[1].endDay, 9);
      expect(segments[1].color, AppColors.ringFollicular);

      expect(segments[2].startDay, 10);
      expect(segments[2].endDay, 16);
      expect(segments[2].color, AppColors.ringFertile);

      expect(segments[3].startDay, 17);
      expect(segments[3].endDay, 28);
      expect(segments[3].color, AppColors.ringLuteal);
    });

    test('bands tile the whole cycle without gaps or overlap', () {
      for (final cycleLen in [21, 28, 35, 45]) {
        final segments = ringSegmentsFor(cycleLen, 5);
        int expectedStart = 1;
        for (final s in segments) {
          expect(s.startDay, expectedStart,
              reason: 'cycleLen=$cycleLen segment ${s.color}');
          expect(s.endDay >= s.startDay, isTrue);
          expectedStart = s.endDay + 1;
        }
        expect(expectedStart - 1, cycleLen,
            reason: 'cycleLen=$cycleLen son gün kapsanmalı');
      }
    });

    test('short cycle: fertile band yields to period, tiling holds', () {
      // 21 gün: ovülasyon 8, ham fertil 3-9 regl (1-5) ile örtüşür —
      // fertil bant 6'dan başlar, folliküler düşer, döşeme bozulmaz
      final segments = ringSegmentsFor(21, 5);
      expect(segments[0].endDay, 5);
      expect(segments[1].startDay, 6);
      expect(segments[1].color, AppColors.ringFertile);
      int expectedStart = 1;
      for (final s in segments) {
        expect(s.startDay, expectedStart);
        expectedStart = s.endDay + 1;
      }
      expect(segments.last.endDay, 21);
    });
  });
}
