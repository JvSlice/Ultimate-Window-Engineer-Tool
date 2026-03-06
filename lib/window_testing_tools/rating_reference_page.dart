import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class RatingReferencePage extends StatelessWidget {
  const RatingReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Rating Reference",
      child: Center(
        child: Text(
          "Coming soon",
          style: TextStyle(color: accent, fontSize: 20),
        ),
      ),
    );
  }
}
