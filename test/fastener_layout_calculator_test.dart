import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/fabrication/fastener_layout_calculator.dart';

void main() {
  group('fastener layout calculator', () {
    test('calculates basic perimeter layout without spacing below minimum', () {
      final result = calculateFastenerLayout(
        width: 60,
        height: 72,
        cornerOffset: 3,
        minimumSpacing: 16,
      );

      expect(result.isValid, isTrue);
      expect(result.top.availableDistance, 54);
      expect(result.top.spaces, 3);
      expect(result.top.spacing, 18);
      expect(result.top.locations, [3, 21, 39, 57]);
      expect(result.top.fastenerCount, 4);

      expect(result.left.availableDistance, 66);
      expect(result.left.spaces, 4);
      expect(result.left.spacing, 16.5);
      expect(result.left.locations, [3, 19.5, 36, 52.5, 69]);
      expect(result.left.fastenerCount, 5);

      expect(result.totalFasteners, 18);
    });

    test('uses largest whole number of spaces that stays above minimum', () {
      final side = calculateFastenerSideLayout(
        name: 'Top',
        reference: 'from left corner',
        sideLength: 60,
        cornerOffset: 3,
        minimumSpacing: 16,
      );

      expect(side.spaces, 3);
      expect(side.spacing, 18);
      expect(side.spacing >= side.minimumSpacing, isTrue);
    });

    test('supports adjustable corner offset', () {
      final side = calculateFastenerSideLayout(
        name: 'Top',
        reference: 'from left corner',
        sideLength: 60,
        cornerOffset: 4,
        minimumSpacing: 16,
      );

      expect(side.availableDistance, 52);
      expect(side.spaces, 3);
      expect(side.spacing, closeTo(17.333333333, 0.000001));
      expect(side.locations.first, 4);
      expect(side.locations.last, 56);
    });

    test('formats fractions to nearest sixteenth without changing layout', () {
      final side = calculateFastenerSideLayout(
        name: 'Top',
        reference: 'from left corner',
        sideLength: 60,
        cornerOffset: 4,
        minimumSpacing: 16,
      );

      expect(
        formatFastenerInches(side.spacing, FastenerDisplayMode.fraction),
        '17 5/16 in',
      );
      expect(
        formatFastenerInches(side.locations.last, FastenerDisplayMode.fraction),
        '56 in',
      );
    });

    test('formats decimal inches without changing layout', () {
      final side = calculateFastenerSideLayout(
        name: 'Top',
        reference: 'from left corner',
        sideLength: 60,
        cornerOffset: 4,
        minimumSpacing: 16,
      );

      expect(
        formatFastenerInches(side.spacing, FastenerDisplayMode.decimal),
        '17.333 in',
      );
      expect(side.locations.last, 56);
    });

    test('rejects short side when available distance is below minimum', () {
      final side = calculateFastenerSideLayout(
        name: 'Top',
        reference: 'from left corner',
        sideLength: 20,
        cornerOffset: 3,
        minimumSpacing: 16,
      );

      expect(side.isValid, isFalse);
      expect(side.availableDistance, 14);
      expect(side.locations, isEmpty);
    });
  });
}
