import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

class ConePage extends StatefulWidget {
  const ConePage({super.key});

  @override
  State<ConePage> createState() => _ConePageState();
}

class _ConePageState extends State<ConePage> {
  final rCtrl = TextEditingController(text: "1");
  final hCtrl = TextEditingController(text: "3");

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

    final vol = (r == null || h == null) ? null : (1.0 / 3.0) * pi * r * r * h;
    final slant = (r == null || h == null) ? null : sqrt(r * r + h * h);
    final lateral = (r == null || slant == null) ? null : pi * r * slant;
    final total = (lateral == null || r == null) ? null : lateral + (pi * r * r);

    return TerminalScaffold(
      title: "Cone",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formulas:\nV = 1/3 πr²h\ns = √(r² + h²)\nLSA = πrs\nTSA = πrs + πr²",
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
                if (slant == null) "Slant height (s): —" else "Slant height (s): ${slant.toStringAsFixed(4)}",
                if (lateral == null) "Lateral SA: —" else "Lateral SA: ${lateral.toStringAsFixed(4)}",
                if (total == null) "Total SA: —" else "Total SA: ${total.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
