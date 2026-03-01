import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';

class MaterialPropertiesPage extends StatelessWidget {
  const MaterialPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Material Properties",
      child: Center(
        child: Text(
          "Material property tables will live here.",
          style: TextStyle(color: accent, fontSize: 18),
        ),
      ),
    );
  }
}
