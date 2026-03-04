import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

class CirclePage extends StatefulWidget {
  const CirclePage({super.key});

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  final rCtrl = TextEditingController(text: "1");

  double? area;
  double? circ;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final r = _p(rCtrl);

    setState(() {
      if (r == null || r <= 0) {
        area = null;
        circ = null;
      } else {
        area = pi * r * r;
        circ = 2 * pi * r;
      }
    });
  }

  @override
  void dispose() {
    rCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Circle",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // DEBUG STAMP (leave it for now so you can confirm you're on the right file)
            Text(
              "CIRCLE PAGE v3",
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              "Formulas:\nA = πr²\nC = 2πr",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),

            terminalNumberField(
              accent: accent,
              label: "Radius (r)",
              hint: "units",
              controller: rCtrl,
            ),
            const SizedBox(height: 16),

            // Force full-width so it can't disappear due to layout sizing
            SizedBox(
              width: double.infinity,
              child: terminalCalcButton(
                accent: accent,
                onPressed: _calculate,
              ),
            ),
            const SizedBox(height: 18),

            terminalResultCard(
              accent: accent,
              lines: [
                "Area (A): ${area == null ? '—' : area!.toStringAsFixed(4)}",
                "Circumference (C): ${circ == null ? '—' : circ!.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
