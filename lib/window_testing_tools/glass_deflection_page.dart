import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class GlassDeflectionPage extends StatelessWidget {
  const GlassDeflectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Glass & Deflection",
      child: Center(
        child: Text(
          "Coming soon",
          style: TextStyle(color: accent, fontSize: 20),
        ),
      ),
    );
  }
}
