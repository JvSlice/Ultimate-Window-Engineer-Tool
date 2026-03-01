import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

class CirclePage extends StatefulWidget {
  const CirclePage({super.key});

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  final rCtrl = TextEditingController(text: "1");

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void dispose() {
    rCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final r = _p(rCtrl);

    final area = (r == null) ? null : pi * r * r;
    final circ = (r == null) ? null : 2 * pi * r;

    return TerminalScaffold(
      title: "Circle",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formulas:\nA = πr²\nC = 2πr",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            terminalNumberField(accent: accent, label: "Radius (r)", hint: "units", controller: rCtrl),
            const SizedBox(height: 18),
            terminalResultCard(
              accent: accent,
              lines: [
                if (area == null) "Area (A): —" else "Area (A): ${area.toStringAsFixed(4)}",
                if (circ == null) "Circumference (C): —" else "Circumference (C): ${circ.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
