import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const blackCopperBackground = Color(0xFF0D0D0D);
const blackCopperSurface = Color(0xFF1C1C1C);
const blackCopperAccent = Color(0xFFB87333);
const blackCopperHighlight = Color(0xFFD99554);
const blackCopperText = Color(0xFFF2F2F2);
const blackCopperSecondaryText = Color(0xFFA8A8A8);
const blackCopperBorder = Color(0xFF514239);

enum AccentChoice { green, red, yellow, blackCopper }

String accentChoiceToString(AccentChoice c) => c.name;

AccentChoice accentChoiceFromString(String? s) {
  switch (s) {
    case 'red':
      return AccentChoice.red;
    case 'yellow':
      return AccentChoice.yellow;
    case 'blackCopper':
      return AccentChoice.blackCopper;
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
    case AccentChoice.blackCopper:
      return blackCopperAccent;
  }
}

Color accentForegroundFromChoice(AccentChoice choice) =>
    choice == AccentChoice.blackCopper ? blackCopperBackground : Colors.black;

Color terminalSurfaceForAccent(Color accent) =>
    accent == blackCopperAccent ? blackCopperSurface : Colors.black;

class AppThemeController extends ChangeNotifier {
  static const String _prefsKey = 'accent_choice';

  AccentChoice _accentChoice = AccentChoice.green;

  AccentChoice get accentChoice => _accentChoice;
  Color get accentColor => accentColorFromChoice(_accentChoice);
  Color get selectionColor => _accentChoice == AccentChoice.blackCopper
      ? blackCopperHighlight
      : accentColor;
  Color get accentForegroundColor => accentForegroundFromChoice(_accentChoice);
  Color get primaryBackground => _accentChoice == AccentChoice.blackCopper
      ? blackCopperBackground
      : const Color(0xFF0B0F14);
  Color get secondaryBackground => _accentChoice == AccentChoice.blackCopper
      ? blackCopperSurface
      : const Color(0xFF121821);

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
    final bg = primaryBackground;
    final secondaryBg = secondaryBackground;
    final copperPalette = _accentChoice == AccentChoice.blackCopper;
    final primaryText = copperPalette ? blackCopperText : Colors.white;
    final secondaryText = copperPalette
        ? blackCopperSecondaryText
        : Colors.white70;
    final outline = copperPalette ? blackCopperBorder : accent;
    final scheme =
        ColorScheme.dark(
          surface: bg,
          surfaceContainer: secondaryBg,
          surfaceContainerHighest: secondaryBg,
          onSurface: primaryText,
          onSurfaceVariant: secondaryText,
        ).copyWith(
          primary: accent,
          primaryContainer: copperPalette ? blackCopperHighlight : null,
          onPrimary: accentForegroundColor,
          secondary: copperPalette ? blackCopperHighlight : accent,
          tertiary: accent,
          outline: outline,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,

      cardTheme: CardThemeData(
        color: secondaryBg,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(backgroundColor: secondaryBg),
      popupMenuTheme: PopupMenuThemeData(color: secondaryBg),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(secondaryBg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryBg,
        labelStyle: TextStyle(color: accent),
        hintStyle: TextStyle(color: secondaryText),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }
}
