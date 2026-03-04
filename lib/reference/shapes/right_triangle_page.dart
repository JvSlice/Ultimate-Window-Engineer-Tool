import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

class RightTrianglePage extends StatefulWidget {
  const RightTrianglePage({super.key});

  @override
  State<RightTrianglePage> createState() => _RightTrianglePageState();
}

class _RightTrianglePageState extends State<RightTrianglePage> {
  final aCtrl = TextEditingController(text: "3");
  final bCtrl = TextEditingController(text: "4");

  double? c;
  double? angleA;
  double? angleB;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final a = _p(aCtrl);
    final b = _p(bCtrl);

    setState(() {
      if (a == null || b == null || a <= 0 || b <= 0) {
        c = null;
        angleA = null;
        angleB = null;
      } else {
        c = sqrt(a * a + b * b);
        // angles in degrees
        angleA = atan2(a, b) * 180.0 / pi; // opposite=a, adjacent=b
        angleB = atan2(b, a) * 180.0 / pi; // opposite=b, adjacent=a
      }
    });
  }

  @override
  void dispose() {
    aCtrl.dispose();
    bCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Right Triangle",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formulas:\n"
              "c = √(a² + b²)\n"
              "A = atan(a / b)\n"
              "B = atan(b / a)\n"
              "(angles in degrees)",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),

            terminalNumberField(
              accent: accent,
              label: "Leg a",
              hint: "units",
              controller: aCtrl,
            ),
            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Leg b",
              hint: "units",
              controller: bCtrl,
            ),
            const SizedBox(height: 16),

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
                "Hypotenuse (c): ${c == null ? '—' : c!.toStringAsFixed(4)}",
                "Angle A: ${angleA == null ? '—' : '${angleA!.toStringAsFixed(2)}°'}",
                "Angle B: ${angleB == null ? '—' : '${angleB!.toStringAsFixed(2)}°'}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
