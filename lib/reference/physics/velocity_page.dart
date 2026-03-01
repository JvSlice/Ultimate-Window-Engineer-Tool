import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class VelocityPage extends StatelessWidget {
  const VelocityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return TerminalScaffold(
      title: "Velocity & Accel",
      child: Center(
        child: Text("Coming soon.", style: TextStyle(color: accent, fontSize: 18)),
      ),
    );
  }
}
