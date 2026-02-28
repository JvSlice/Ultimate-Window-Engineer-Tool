import 'package:flutter/material.dart';
import 'terminal_scaffold.dart';

class ToolFour extends StatelessWidget {
  const ToolFour({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: 'Coming Soon',

      child: Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(color: accent, fontSize: 20),
        ),
      ),
    );
  }
}
