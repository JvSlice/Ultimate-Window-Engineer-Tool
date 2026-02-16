import 'package:flutter/material.dart';
import 'terminal_scaffold.dart';

class FabricateItPage extends StatelessWidget {
  const FabricateItPage({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    const accent = Colors.green;
    return const TerminalScaffold(
      title: 'Fabricate it',
      accent: accent,
      child: Center(
        child: Text(
          'Fabriacate it page',
          style: TextStyle(color: accent, fontSize: 20),
        ),
      ),
    );
  }
}
