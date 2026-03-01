import 'dart:math';
import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';
import '../widgets/terminal_fields.dart';

class Geometry3DPage extends StatefulWidget {
  const Geometry3DPage({super.key});

  @override
  State<Geometry3DPage> createState() => _Geometry3DPageState();
}

class _Geometry3DPageState extends State<Geometry3DPage> {
  final radiusCtrl = TextEditingController(text: "1.0");
  final heightCtrl = TextEditingController(text: "1.0");

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void dispose() {
    radiusCtrl.dispose();
    heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final r = _p(radiusCtrl);
    final h = _p(heightCtrl);

    final volume = (r == null || h == null) ? null : pi * r * r * h;
    final sa = (r == null || h == null) ? null : (2 * pi * r * h) + (2 * pi * r * r);

    return TerminalScaffold(
      title: "3D Shapes",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Cylinder", style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              "Formulas:\nV = πr²h\nSA = 2πrh + 2πr²",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),

            terminalNumberField(accent: accent, label: "Radius (r)", hint: "units", controller: radiusCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "Height (h)", hint: "units", controller: heightCtrl),

            const SizedBox(height: 18),

            terminalResultCard(
              accent: accent,
              lines: [
                if (volume == null) "Volume: —" else "Volume (V): ${volume.toStringAsFixed(4)}",
                if (sa == null) "Surface Area: —" else "Surface Area (SA): ${sa.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
