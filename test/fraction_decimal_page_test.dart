import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'package:ultimate_window_engineer_tool/fabrication/fraction_decimal_page.dart';

void main() {
  Future<void> pumpSubject(WidgetTester tester) async {
    final themeController = AppThemeController();

    await tester.pumpWidget(
      MaterialApp(
        theme: themeController.buildTerminalTheme(themeController.accentColor),
        home: const FractionDecimalPage(),
      ),
    );
  }

  testWidgets('fraction input allows slash and space characters', (
    tester,
  ) async {
    await pumpSubject(tester);

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(field.keyboardType, TextInputType.text);
  });

  testWidgets('converts typed fractions to decimal inches', (tester) async {
    await pumpSubject(tester);

    await tester.enterText(find.byType(TextField), '3 7/16');
    await tester.tap(find.text('Calculate'));
    await tester.pump();

    expect(find.text('Primary: 3.437500 in'), findsOneWidget);
    expect(find.text('Secondary: 87.313 mm'), findsOneWidget);
  });
}
