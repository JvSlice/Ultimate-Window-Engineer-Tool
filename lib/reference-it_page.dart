import 'package:flutter/material.dart';
import 'terminal_scaffold.dart';

class ReferenceitPage extends StatelessWidget {
  const ReferenceitPage({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: 'Reference it',

      child: Center(
        child: Text(
          'Reference it page',
          style: TextStyle(color: accent, fontSize: 20),
        ),
      ),
    );
  }
}
