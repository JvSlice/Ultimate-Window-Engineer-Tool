import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/fabrication/test_buck_calculator.dart';

void main() {
  group('test buck calculator', () {
    test('preserves existing cut size and cross measure math', () {
      final result = calculateTestBuck(
        unitWidth: 36,
        unitHeight: 60,
        caulkJoint: 0.5,
        materialThickness: 1.5,
      );

      expect(result.horizontalCut, 40);
      expect(result.verticalCut, 61);
      expect(result.doubleHorizontalCut, 43);
      expect(result.doubleVerticalCut, 64);
      expect(result.outsideWidth, 40);
      expect(result.outsideHeight, 64);
      expect(result.crossMeasureOutside, closeTo(72.966, 0.001));
      expect(result.crossMeasureInside, closeTo(71.086, 0.001));
      expect(result.doubleCrossMeasureOutside, closeTo(77.123, 0.001));
    });

    testWidgets('shows single buck results by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TestBuckCalculatorPage()),
      );

      expect(find.text('Single Buck Lumber Cut Sizes'), findsOneWidget);
      expect(find.text('Single Buck Quick Summary'), findsOneWidget);
      expect(find.text('Double Buck Lumber Cut Sizes'), findsNothing);
      expect(find.text('Outer Buck Lumber Cut Sizes'), findsNothing);
    });

    testWidgets('shows inner and outer results when double buck is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: TestBuckCalculatorPage()),
      );

      await tester.tap(find.text('Double Buck'));
      await tester.pumpAndSettle();

      expect(find.text('Inner Buck Lumber Cut Sizes'), findsOneWidget);
      expect(find.text('Outer Buck Lumber Cut Sizes'), findsOneWidget);
      expect(find.text('Double Buck Quick Summary'), findsOneWidget);
      expect(find.text('Single Buck Quick Summary'), findsNothing);
    });
  });
}
