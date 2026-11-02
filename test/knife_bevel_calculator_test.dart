import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'package:ultimate_window_engineer_tool/reference/knife_bevel_calculator.dart';
import 'package:ultimate_window_engineer_tool/reference/knife_bevel_calculator_page.dart';

KnifeBevelInput _input({
  required KnifeBevelMode mode,
  required double bevelHeight,
  required double blockAngle,
  KnifeGrindType type = KnifeGrindType.fullFlat,
  double? measuredAngle,
  double radius = 0.25,
}) => KnifeBevelInput(
  mode: mode,
  grindType: type,
  orientation: KnifeGrindingOrientation.right,
  stockThickness: 0.125,
  bladeHeight: 1.25,
  edgeThickness: 0.010,
  desiredBevelHeight: bevelHeight,
  blockAngleDegrees: blockAngle,
  measuredGrindingAngleDegrees: measuredAngle,
  curvatureRadius: radius,
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

  test('existing nominal block angle solves inverse geometry', () {
    final result = calculateKnifeBevel(
      _input(
        mode: KnifeBevelMode.existingBlock,
        bevelHeight: 1,
        blockAngle: 10,
      ),
    )!;
    final expectedHeight = (0.125 - 0.010) / (2 * math.tan(10 * math.pi / 180));
    expect(result.bevelAngleDegrees, closeTo(10, 1e-10));
    expect(result.bevelHeight, closeTo(expectedHeight, 1e-10));
  });

  test('issue validation: 12 degree nominal angle gives 0.2705 inch bevel', () {
    final result = calculateKnifeBevel(
      _input(
        mode: KnifeBevelMode.existingBlock,
        bevelHeight: 1,
        blockAngle: 12,
      ),
    )!;
    expect(result.bevelAngleDegrees, closeTo(12, 1e-10));
    expect(result.totalIncludedAngleDegrees, closeTo(24, 1e-10));
    expect(result.bevelHeight, closeTo(0.2705, 0.0001));
  });

  test('measured grinding angle overrides nominal block angle', () {
    final result = calculateKnifeBevel(
      _input(
        mode: KnifeBevelMode.existingBlock,
        bevelHeight: 1,
        blockAngle: 12,
        measuredAngle: 12.3,
      ),
    )!;
    final expectedHeight =
        (0.125 - 0.010) / (2 * math.tan(12.3 * math.pi / 180));
    expect(result.nominalBlockAngleDegrees, closeTo(12, 1e-10));
    expect(result.actualGrindingAngleDegrees, closeTo(12.3, 1e-10));
    expect(result.measuredGrindingAngleDegrees, closeTo(12.3, 1e-10));
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

  test('curved profile exposes distinct edge and shoulder tangents', () {
    final result = calculateKnifeBevel(
      _input(
        mode: KnifeBevelMode.desiredBevel,
        bevelHeight: 0.75,
        blockAngle: 12,
        type: KnifeGrindType.hollow,
        radius: 0.5,
      ),
    );
    expect(result, isNotNull);
    expect(result!.upperArc, isNotNull);
    expect(result.edgeTangentAngleDegrees, isNotNull);
    expect(result.shoulderTangentAngleDegrees, isNotNull);
    expect(result.upperArc!.radius, 0.5);
    expect(
      result.edgeTangentAngleDegrees,
      isNot(closeTo(result.shoulderTangentAngleDegrees!, 1e-6)),
    );
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
            measuredGrindingAngleDegrees: invalid.measuredGrindingAngleDegrees,
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

  test(
    'legacy saved grinding blocks load without applying old seat offsets',
    () {
      final block = SavedKnifeGrindingBlock.fromJson({
        'id': 'old',
        'name': 'Shop block',
        'angleDegrees': 12,
        'orientation': 'right',
        'seatOffsetDegrees': 3,
      });
      expect(block, isNotNull);
      expect(block!.angleDegrees, 12);
      expect(block.measuredAngleDegrees, isNull);
    },
  );

  test(
    'saved grinding block store persists nominal and measured angles',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = KnifeGrindingBlockStore();
      final block = SavedKnifeGrindingBlock(
        id: 'calibrated',
        name: 'Calibrated 12',
        angleDegrees: 12,
        measuredAngleDegrees: 12.3,
        orientation: KnifeGrindingOrientation.right,
      );
      await store.save([block]);
      final loaded = await store.load();
      expect(loaded, hasLength(1));
      expect(loaded.single.angleDegrees, 12);
      expect(loaded.single.measuredAngleDegrees, 12.3);
    },
  );

  testWidgets('calculator fits narrow screens in Black & Copper theme', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final theme = AppThemeController();
    await theme.setAccentChoice(AccentChoice.blackCopper);
    for (final width in [375.0, 430.0]) {
      tester.view.physicalSize = Size(width * 2, 800 * 2);
      tester.view.devicePixelRatio = 2;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme.buildTerminalTheme(theme.accentColor),
          home: const KnifeBevelCalculatorPage(),
        ),
      );
      await tester.pumpAndSettle();
      final firstException = tester.takeException();
      expect(firstException, isNull, reason: 'width $width');
      await tester.scrollUntilVisible(
        find.text('How it works'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'scrolled at width $width',
      );
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
