import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AccentChoice { green, red, yellow }

String accentChoiceToString(AccentChoice c) => c.name;

AccentChoice accentChoiceFromString(String? s) {
  switch (s) {
    case 'red':
      return AccentChoice.red;
    case 'yellow':
      return AccentChoice.yellow;
    case 'green':
    default:
      return AccentChoice.green;
  }
}

Color accentColorFromChoice(AccentChoice c) {
  switch (c) {
    case AccentChoice.green:
      return const Color(0xFF00E676);
    case AccentChoice.red:
      return const Color(0xFFFF5252);
    case AccentChoice.yellow:
      return const Color(0xFFFFD54F);
  }
}

class AppThemeController extends ChangeNotifier {
  static const String _prefsKey = 'accent_choice';

  AccentChoice _accentChoice = AccentChoice.green;

  AccentChoice get accentChoice => _accentChoice;
  Color get accentColor => accentColorFromChoice(_accentChoice);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    _accentChoice = accentChoiceFromString(saved);
    notifyListeners();
  }

  Future<void> setAccentChoice(AccentChoice choice) async {
    _accentChoice = choice;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, accentChoiceToString(choice));
  }

  ThemeData buildTerminalTheme(Color accent) {
    const bg = Color(0xFF0B0F14);
    final scheme =
        ColorScheme.dark(
          surface: bg,
          surfaceContainerHighest: Color(0xFF121821),
          onSurface: Colors.white,
        ).copyWith(
          primary: accent,
          secondary: accent,
          tertiary: accent,
          outline: accent,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }
}
