import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/reference/knife_bevel_calculator.dart';

KnifeBevelInput _input({
  required KnifeBevelMode mode,
  required double bevelHeight,
  required double blockAngle,
  KnifeGrindType type = KnifeGrindType.fullFlat,
  double seatOffset = 0,
}) => KnifeBevelInput(
  mode: mode,
  grindType: type,
  orientation: KnifeGrindingOrientation.right,
  stockThickness: 0.125,
  bladeHeight: 1.25,
  edgeThickness: 0.010,
  desiredBevelHeight: bevelHeight,
  blockAngleDegrees: blockAngle,
  seatOffsetDegrees: seatOffset,
  curvatureRadius: 0.25,
);

void main() {
  test('target bevel computes symmetric angle and required block setting', () {
    final result = calculateKnifeBevel(
      _input(
        mode: KnifeBevelMode.desiredBevel,
        bevelHeight: 0.75,
        blockAngle: 0,
      ),
    )!;
    final expected = math.atan((0.125 - 0.010) / (2 * 0.75)) * 180 / math.pi;
    expect(result.bevelAngleDegrees, closeTo(expected, 1e-10));
    expect(result.requiredBlockAngleDegrees, closeTo(expected, 1e-10));
    expect(result.totalIncludedAngleDegrees, closeTo(expected * 2, 1e-10));
  });

  test('existing block solves inverse geometry and includes seat offset', () {
    final result = calculateKnifeBevel(
      _input(
        mode: KnifeBevelMode.existingBlock,
        bevelHeight: 1,
        blockAngle: 10,
        seatOffset: 2,
      ),
    )!;
    final expectedHeight = (0.125 - 0.010) / (2 * math.tan(12 * math.pi / 180));
    expect(result.bevelAngleDegrees, closeTo(12, 1e-10));
    expect(result.bevelHeight, closeTo(expectedHeight, 1e-10));
  });

  test('single-sided grind uses full thickness reduction', () {
    final result = calculateKnifeBevel(
      _input(
        mode: KnifeBevelMode.desiredBevel,
        bevelHeight: 0.75,
        blockAngle: 0,
        type: KnifeGrindType.chisel,
      ),
    )!;
    final expected = math.atan((0.125 - 0.010) / 0.75) * 180 / math.pi;
    expect(result.bevelAngleDegrees, closeTo(expected, 1e-10));
    expect(result.totalIncludedAngleDegrees, closeTo(expected, 1e-10));
  });

  test(
    'rejects invalid edge geometry and detects bevel beyond blade height',
    () {
      final invalid = _input(
        mode: KnifeBevelMode.desiredBevel,
        bevelHeight: 0.75,
        blockAngle: 0,
      );
      expect(
        calculateKnifeBevel(
          KnifeBevelInput(
            mode: invalid.mode,
            grindType: invalid.grindType,
            orientation: invalid.orientation,
            stockThickness: invalid.stockThickness,
            bladeHeight: invalid.bladeHeight,
            edgeThickness: invalid.stockThickness,
            desiredBevelHeight: invalid.desiredBevelHeight,
            blockAngleDegrees: invalid.blockAngleDegrees,
            seatOffsetDegrees: invalid.seatOffsetDegrees,
            curvatureRadius: invalid.curvatureRadius,
          ),
        ),
        isNull,
      );
      final beyond = calculateKnifeBevel(
        _input(
          mode: KnifeBevelMode.desiredBevel,
          bevelHeight: 2,
          blockAngle: 0,
        ),
      )!;
      expect(beyond.isAchievable, isFalse);
    },
  );
}
