import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class StructuralTestMathPage extends StatelessWidget {
  const StructuralTestMathPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Structural Test Math",
      child: Center(
        child: Text(
          "Coming soon",
          style: TextStyle(color: accent, fontSize: 20),
        ),
      ),
    );
  }
}
