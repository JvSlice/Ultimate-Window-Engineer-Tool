import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'package:ultimate_window_engineer_tool/settings_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Black & Copper palette uses the requested colors', () async {
    final controller = AppThemeController();
    await controller.setAccentChoice(AccentChoice.blackCopper);
    final theme = controller.buildTerminalTheme(blackCopperAccent);

    expect(
      accentColorFromChoice(AccentChoice.blackCopper),
      const Color(0xFFB87333),
    );
    expect(controller.selectionColor, const Color(0xFFD99554));
    expect(theme.scaffoldBackgroundColor, const Color(0xFF0D0D0D));
    expect(theme.colorScheme.surfaceContainer, const Color(0xFF1C1C1C));
    expect(theme.colorScheme.onSurface, const Color(0xFFF2F2F2));
    expect(theme.colorScheme.onSurfaceVariant, const Color(0xFFA8A8A8));
    expect(theme.colorScheme.outline, const Color(0xFF514239));
    expect(theme.colorScheme.primaryContainer, const Color(0xFFD99554));
  });

  test('existing accent colors remain unchanged', () {
    expect(accentColorFromChoice(AccentChoice.green), const Color(0xFF00E676));
    expect(accentColorFromChoice(AccentChoice.red), const Color(0xFFFF5252));
    expect(accentColorFromChoice(AccentChoice.yellow), const Color(0xFFFFD54F));
  });

  test('selected theme is saved and restored', () async {
    final controller = AppThemeController();
    await controller.load();
    await controller.setAccentChoice(AccentChoice.blackCopper);

    final restored = AppThemeController();
    await restored.load();
    expect(restored.accentChoice, AccentChoice.blackCopper);
    expect(restored.accentColor, blackCopperAccent);
  });

  testWidgets('theme can be selected live from Settings', (tester) async {
    final controller = AppThemeController();
    await controller.load();

    await tester.pumpWidget(
      AnimatedBuilder(
        animation: controller,
        builder: (context, _) => MaterialApp(
          theme: controller.buildTerminalTheme(controller.accentColor),
          home: SettingsPage(themeController: controller),
        ),
      ),
    );

    await tester.tap(find.text('Black & Copper'));
    await tester.pumpAndSettle();

    expect(controller.accentChoice, AccentChoice.blackCopper);
    expect(find.text('Current: Black & Copper'), findsOneWidget);
    expect(
      Theme.of(
        tester.element(find.text('Current: Black & Copper')),
      ).colorScheme.primary,
      blackCopperAccent,
    );
  });
}
