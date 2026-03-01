import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class PulleysPage extends StatelessWidget {
  const PulleysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return TerminalScaffold(
      title: "Pulleys",
      child: Center(
        child: Text("Coming soon.", style: TextStyle(color: accent, fontSize: 18)),
      ),
    );
  }
}
