import 'package:flutter/material.dart';
import 'terminal_scaffold.dart';

class ReferenceitPage extends StatelessWidget {
  const ReferenceitPage({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    const accent = Colors.green;

    return const TerminalScaffold(
      title: 'Reference it',
      accent: accent,
      child: Center(
        child: Text(
          'Reference it page',
          style: TextStyle(color: accent, fontSize: 20),
        ),
      ),
    );
  }
}
