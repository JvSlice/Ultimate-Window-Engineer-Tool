import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'terminal_scaffold.dart';

class SettingsPage extends StatelessWidget {
  final AppThemeController themeController;
  const SettingsPage({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final accent = themeController.accentColor;
    return const TerminalScaffold(
      title: 'Settings',
      accent: accent,
      child: Center(
        child: Text(
          'Settings Page',
          style: TextStyle(color: accent, fontSize: 20),
        ),
      ),
    );
  }
}
