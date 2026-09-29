import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'package:ultimate_window_engineer_tool/window_testing_tools/astm_e1300_page.dart';

void main() {
  Future<void> pumpSubject(WidgetTester tester) async {
    final themeController = AppThemeController();

    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: themeController.buildTerminalTheme(themeController.accentColor),
        home: const AstmE1300Page(),
      ),
    );
  }

  testWidgets('defaults to monolithic glass inputs and result card', (
    tester,
  ) async {
    await pumpSubject(tester);

    expect(find.text('Glass Type'), findsOneWidget);
    expect(find.text('Glass Thickness (in)'), findsOneWidget);
    expect(find.text('Lite 1 Type'), findsNothing);
    expect(find.text('Lite 2 Type'), findsNothing);
    expect(find.text('Build: Monolithic'), findsOneWidget);
  });

  testWidgets('calculates monolithic glass without requiring IGU lites', (
    tester,
  ) async {
    await pumpSubject(tester);

    await tester.enterText(find.byType(TextField).at(0), '24');
    await tester.enterText(find.byType(TextField).at(1), '48');
    await tester.enterText(find.byType(TextField).at(2), '50');
    await tester.enterText(find.byType(TextField).at(3), '0.25');

    await tester.ensureVisible(find.text('Calculate'));
    await tester.tap(find.text('Calculate'));
    await tester.pump();

    expect(find.text('Build: Monolithic'), findsOneWidget);
    expect(find.text('Result: PASS'), findsOneWidget);
    expect(
      find.textContaining('Enter valid IGU lite thicknesses'),
      findsNothing,
    );
  });
}
