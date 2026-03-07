import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class AstmE1300Page extends StatelessWidget {
  const AstmE1300Page({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "ASTM E1300",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            "ASTM E1300 calculator coming soon",
            style: TextStyle(
              color: accent,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
