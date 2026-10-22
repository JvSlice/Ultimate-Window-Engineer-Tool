import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'package:ultimate_window_engineer_tool/home/search/main_menu_search_engine.dart';
import 'package:ultimate_window_engineer_tool/home/search/search_registry.dart';
import 'package:ultimate_window_engineer_tool/reference/forge_calculator.dart';
import 'package:ultimate_window_engineer_tool/reference/forge_calculator_page.dart';

void main() {
  ForgeResult? example({double loss = 10, double stockWidth = 2}) =>
      calculateForgeCutoff(
        finishedHeight: 0.25,
        finishedWidth: 0.25,
        finishedLength: 9,
        stockHeight: 0.25,
        stockWidth: stockWidth,
        lossPercent: loss,
      );

  group('forge calculation', () {
    test('issue example and material loss allowance', () {
      final result = example()!;
      expect(result.finishedVolume, closeTo(0.5625, 1e-12));
      expect(result.theoreticalLength, closeTo(1.125, 1e-12));
      expect(result.recommendedLength, closeTo(1.25, 1e-12));
      expect(result.additionalLength, closeTo(0.125, 1e-12));
    });

    test('zero loss is allowed', () {
      final result = example(loss: 0)!;
      expect(result.recommendedLength, result.theoreticalLength);
      expect(result.additionalLength, 0);
    });

    test('different starting cross-sections change cutoff length', () {
      expect(example(stockWidth: 1)!.theoreticalLength, 2.25);
      expect(example(stockWidth: 2)!.theoreticalLength, 1.125);
    });

    test('imperial and metric calculations agree after conversion', () {
      final inches = example()!;
      double mm(double value) => convertForgeLength(
        value,
        ForgeUnitSystem.imperial,
        ForgeUnitSystem.metric,
      );
      final metric = calculateForgeCutoff(
        finishedHeight: mm(0.25),
        finishedWidth: mm(0.25),
        finishedLength: mm(9),
        stockHeight: mm(0.25),
        stockWidth: mm(2),
        lossPercent: 10,
      )!;
      expect(
        metric.theoreticalLength,
        closeTo(mm(inches.theoreticalLength), 1e-10),
      );
      expect(
        metric.recommendedLength,
        closeTo(mm(inches.recommendedLength), 1e-10),
      );
      expect(
        convertForgeLength(
          mm(9),
          ForgeUnitSystem.metric,
          ForgeUnitSystem.imperial,
        ),
        closeTo(9, 1e-12),
      );
    });

    test('rejects invalid values and zero stock area', () {
      expect(example(loss: 100), isNull);
      expect(example(loss: -1), isNull);
      expect(example(stockWidth: 0), isNull);
      expect(example(stockWidth: -2), isNull);
      expect(example(stockWidth: double.nan), isNull);
      expect(example(stockWidth: double.infinity), isNull);
    });

    test('parses shop fractions and formats approximate inch results', () {
      expect(parseForgeDimension('1 1/2', ForgeUnitSystem.imperial), 1.5);
      expect(parseForgeDimension('1/4', ForgeUnitSystem.imperial), 0.25);
      expect(parseForgeDimension('1/0', ForgeUnitSystem.imperial), isNull);
      expect(parseForgeDimension('1/4', ForgeUnitSystem.metric), isNull);
      expect(formatForgeFraction(1.125), '1 1/8');
      expect(formatForgeFraction(1.25), '1 1/4');
    });
  });

  testWidgets('page recalculates on change, converts units, and resets', (
    tester,
  ) async {
    final theme = AppThemeController();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme.buildTerminalTheme(theme.accentColor),
        home: const ForgeCalculatorPage(),
      ),
    );
    final pageScroll = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.textContaining('Theoretical cutoff length:'),
      300,
      scrollable: pageScroll,
    );
    expect(
      find.textContaining('Theoretical cutoff length: 1.125 in'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Recommended cutoff length: 1.25 in'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Material loss (%)'),
      -300,
      scrollable: pageScroll,
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) => widget is TextField && widget.controller?.text == '10',
      ),
      '0',
    );
    await tester.pump();
    expect(
      find.textContaining('Recommended cutoff length: 1.125 in'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Metric (mm)'),
      -300,
      scrollable: pageScroll,
    );
    await tester.tap(find.text('Metric (mm)'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      '6.35',
    );
    await tester.scrollUntilVisible(
      find.textContaining('Theoretical cutoff length: 28.575 mm'),
      300,
      scrollable: pageScroll,
    );
    expect(
      find.textContaining('Theoretical cutoff length: 28.575 mm'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Reset'));
    await tester.tap(find.text('Reset'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.textContaining('Recommended cutoff length: 1.25 in'),
      300,
      scrollable: pageScroll,
    );
    expect(
      find.textContaining('Recommended cutoff length: 1.25 in'),
      findsOneWidget,
    );
  });

  test('search finds forge calculator by shop terms', () {
    final engine = MainMenuSearchEngine();
    for (final query in [
      'forge',
      'blacksmith',
      'bladesmith',
      'cutoff length',
    ]) {
      final hits = engine.buildHits(
        query: query,
        entries: buildSearchRegistry(AppThemeController()),
        onOpenEntry: (_) {},
        onOpenConvertIt: () {},
      );
      expect(hits.any((hit) => hit.title == 'Forge Calculator'), isTrue);
    }
  });
}
