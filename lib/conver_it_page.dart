import 'package:flutter/material.dart';
import 'terminal_scaffold.dart';

class ConverItPage extends StatelessWidget {
  const ConverItPage({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    const accent = Colors.green;
    return const TerminalScaffold(
      title: 'Convert It',
      accent: accent,
      child: Center(
        child: Text(
          'Covert it page',
          style: TextStyle(color: accent, fontSize: 20),
        ),
      ),
    );
  }
}
