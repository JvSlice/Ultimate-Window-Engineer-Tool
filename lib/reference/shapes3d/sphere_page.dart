import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

class SpherePage extends StatefulWidget {
  const SpherePage({super.key});

  @override
  State<SpherePage> createState() => _SpherePageState();
}

class _SpherePageState extends State<SpherePage> {
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

    final vol = (r == null) ? null : (4.0 / 3.0) * pi * r * r * r;
    final sa = (r == null) ? null : 4 * pi * r * r;

    return TerminalScaffold(
      title: "Sphere",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formulas:\nV = 4/3 πr³\nSA = 4πr²",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            terminalNumberField(accent: accent, label: "Radius (r)", hint: "units", controller: rCtrl),
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
