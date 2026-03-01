import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

class RightTrianglePage extends StatefulWidget {
  const RightTrianglePage({super.key});

  @override
  State<RightTrianglePage> createState() => _RightTrianglePageState();
}

class _RightTrianglePageState extends State<RightTrianglePage> {
  final aCtrl = TextEditingController(text: "3");
  final bCtrl = TextEditingController(text: "4");

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void dispose() {
    aCtrl.dispose();
    bCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final a = _p(aCtrl);
    final b = _p(bCtrl);

    final c = (a == null || b == null) ? null : sqrt(a * a + b * b);
    final angleA = (a == null || b == null) ? null : (atan2(a, b) * 180 / pi);
    final angleB = (a == null || b == null) ? null : (atan2(b, a) * 180 / pi);

    return TerminalScaffold(
      title: "Right Triangle",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formulas:\nC = √(a² + b²)\nθ = atan(opposite/adjacent)",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            terminalNumberField(accent: accent, label: "Leg a", hint: "units", controller: aCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "Leg b", hint: "units", controller: bCtrl),
            const SizedBox(height: 18),
            terminalResultCard(
              accent: accent,
              lines: [
                if (c == null) "Hypotenuse (c): —" else "Hypotenuse (c): ${c.toStringAsFixed(4)}",
                if (angleA == null) "Angle A: —" else "Angle A: ${angleA.toStringAsFixed(2)}°",
                if (angleB == null) "Angle B: —" else "Angle B: ${angleB.toStringAsFixed(2)}°",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
