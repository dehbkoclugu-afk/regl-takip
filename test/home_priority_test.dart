import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/providers/providers.dart';

void main() {
  test('home priority restores known values and defaults safely', () {
    expect(HomePriority.fromStorage('today'), HomePriority.today);
    expect(HomePriority.fromStorage('cycle'), HomePriority.cycle);
    expect(HomePriority.fromStorage('unknown'), HomePriority.cycle);
    expect(HomePriority.fromStorage(null), HomePriority.cycle);
  });
}
