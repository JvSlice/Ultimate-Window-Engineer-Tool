import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

class CylinderPage extends StatefulWidget {
  const CylinderPage({super.key});

  @override
  State<CylinderPage> createState() => _CylinderPageState();
}

class _CylinderPageState extends State<CylinderPage> {
  final rCtrl = TextEditingController(text: "1");
  final hCtrl = TextEditingController(text: "4");

  double? volume;
  double? surfaceArea;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final r = _p(rCtrl);
    final h = _p(hCtrl);

    setState(() {
      if (r == null || h == null || r <= 0 || h <= 0) {
        volume = null;
        surfaceArea = null;
      } else {
        volume = pi * r * r * h;
        surfaceArea = (2 * pi * r * h) + (2 * pi * r * r);
      }
    });
  }

  @override
  void dispose() {
    rCtrl.dispose();
    hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Cylinder",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formulas:\nV = πr²h\nSA = 2πrh + 2πr²",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),

            const SizedBox(height: 16),

            terminalNumberField(
              accent: accent,
              label: "Radius (r)",
              hint: "units",
              controller: rCtrl,
            ),

            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Height (h)",
              hint: "units",
              controller: hCtrl,
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
                "Volume (V): ${volume == null ? '—' : volume!.toStringAsFixed(4)}",
                "Surface Area (SA): ${surfaceArea == null ? '—' : surfaceArea!.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
