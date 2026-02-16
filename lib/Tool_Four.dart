import 'package:flutter/material.dart';
import 'terminal_scaffold.dart';

class ToolFour extends StatelessWidget {
  const ToolFour({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    const accent = Colors.green;

    return const TerminalScaffold(
      title: 'Coming Soon',
      accent: accent,
      child: Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(color: accent, fontSize: 20),
        ),
      ),
    );
  }
}
