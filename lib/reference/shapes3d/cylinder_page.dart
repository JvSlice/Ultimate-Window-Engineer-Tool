import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

class CylinderPage extends StatefulWidget {
  const CylinderPage({super.key});

  @override
  State<CylinderPage> createState() => _CylinderPageState();
}

class _CylinderPageState extends State<CylinderPage> {
  final rCtrl = TextEditingController(text: "1");
  final hCtrl = TextEditingController(text: "4");

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void dispose() {
    rCtrl.dispose();
    hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final r = _p(rCtrl);
    final h = _p(hCtrl);

    final vol = (r == null || h == null) ? null : pi * r * r * h;
    final sa = (r == null || h == null) ? null : (2 * pi * r * h) + (2 * pi * r * r);

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
            terminalNumberField(accent: accent, label: "Radius (r)", hint: "units", controller: rCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "Height (h)", hint: "units", controller: hCtrl),
            const SizedBox(height: 18),
            terminalResultCard(
              accent: accent,
              lines: [
                if (vol == null) "Volume (V): —" else "Volume (V): ${vol.toStringAsFixed(4)}",
                if (sa == null) "Surface Area (SA): —" else "Surface Area (SA): ${sa.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
