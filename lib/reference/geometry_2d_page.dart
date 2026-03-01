import 'dart:math';
import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';
import '../widgets/terminal_fields.dart';

class Geometry2DPage extends StatefulWidget {
  const Geometry2DPage({super.key});

  @override
  State<Geometry2DPage> createState() => _Geometry2DPageState();
}

class _Geometry2DPageState extends State<Geometry2DPage> {
  final radiusCtrl = TextEditingController(text: "1.0");

  double? _parse(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void dispose() {
    radiusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final r = _parse(radiusCtrl);

    final area = (r == null) ? null : pi * r * r;
    final circ = (r == null) ? null : 2 * pi * r;

    return TerminalScaffold(
      title: "2D Shapes",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Circle", style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              "Formulas:\nA = πr²\nC = 2πr",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),

            terminalNumberField(
              accent: accent,
              label: "Radius (r)",
              hint: "inches, mm, etc.",
              controller: radiusCtrl,
            ),

            const SizedBox(height: 18),

            terminalResultCard(
              accent: accent,
              lines: [
                if (area == null) "Area: —" else "Area (A): ${area.toStringAsFixed(4)}",
                if (circ == null) "Circumference: —" else "Circumference (C): ${circ.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
