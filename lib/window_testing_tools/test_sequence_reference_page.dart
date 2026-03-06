import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class TestSequenceReferencePage extends StatelessWidget {
  const TestSequenceReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Test Sequence Reference",
      child: Center(
        child: Text(
          "Coming soon",
          style: TextStyle(color: accent, fontSize: 20),
        ),
      ),
    );
  }
}
