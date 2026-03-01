import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';

class PhysicsEquationsPage extends StatelessWidget {
  const PhysicsEquationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Physics Equations",
      child: Center(
        child: Text(
          "Physics equations will live here.",
          style: TextStyle(color: accent, fontSize: 18),
        ),
      ),
    );
  }
}
