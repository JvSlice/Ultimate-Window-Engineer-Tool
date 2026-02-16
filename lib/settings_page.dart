import 'package:flutter/material.dart';
import 'terminal_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    const accent = Colors.green;
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
