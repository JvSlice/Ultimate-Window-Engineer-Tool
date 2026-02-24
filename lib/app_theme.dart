import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AccentChoice { green, red, yellow }
String accentChoiceToString(AccentChoice c) => c.name;

AccentChoice accentColorFromChoice(AccentChoice c) {
  switch (s) {
    case 'red': 
    return AccentChoice.red;
    
  }
}

Color accentColorFromChoice(AccentChoice c) {
  switch (c) {
    case AccentChoice.green:
      return const Color(0xFE00E676);
    case AccentChoice.red:
      return const Color(0xFFFF5252);
    case AccentChoice.yellow:
      return const Color(0xFFFFD54F);
  }
}

class AppThemeController extends ChangeNotifier {
  static const _prefsKey = 'accent_choice';

  AccentChoice _accentChoice = AccentChoice.green;
  
  AccentChoice get AccentChoice => _accentChoice;

  Color get AccentChoice => accentColorFromChoice(_accentChoice);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, accentChoiceToString(choice));
  }
}

ThemeData buildTermialTheme(Color accent) {
  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
  );
  return ThemeData(
    brightness: Brightness.dark
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF0BF14),
    useMaterial3: true,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16)
    ),
  );
}
