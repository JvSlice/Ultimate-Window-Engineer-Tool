import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

class ConePage extends StatefulWidget {
  const ConePage({super.key});

  @override
  State<ConePage> createState() => _ConePageState();
}

class _ConePageState extends State<ConePage> {
  final rCtrl = TextEditingController(text: "1");
  final hCtrl = TextEditingController(text: "3");

  double? volume;
  double? slant;
  double? lateral;
  double? total;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final r = _p(rCtrl);
    final h = _p(hCtrl);

    setState(() {
      if (r == null || h == null || r <= 0 || h <= 0) {
        volume = null;
        slant = null;
        lateral = null;
        total = null;
      } else {
        volume = (1.0 / 3.0) * pi * r * r * h;
        slant = sqrt(r * r + h * h);
        lateral = pi * r * slant!;
        total = lateral! + (pi * r * r);
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
                "Slant height (s): ${slant == null ? '—' : slant!.toStringAsFixed(4)}",
                "Lateral SA: ${lateral == null ? '—' : lateral!.toStringAsFixed(4)}",
                "Total SA: ${total == null ? '—' : total!.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
