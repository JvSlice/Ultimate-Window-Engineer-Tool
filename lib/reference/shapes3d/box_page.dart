import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

class BoxPage extends StatefulWidget {
  const BoxPage({super.key});

  @override
  State<BoxPage> createState() => _BoxPageState();
}

class _BoxPageState extends State<BoxPage> {
  final lCtrl = TextEditingController(text: "10");
  final wCtrl = TextEditingController(text: "5");
  final hCtrl = TextEditingController(text: "2");

  double? volume;
  double? surfaceArea;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final l = _p(lCtrl);
    final w = _p(wCtrl);
    final h = _p(hCtrl);

    setState(() {
      if (l == null || w == null || h == null) {
        volume = null;
        surfaceArea = null;
      } else {
        volume = l * w * h;
        surfaceArea = 2 * (l * w + l * h + w * h);
      }
    });
  }

  @override
  void dispose() {
    lCtrl.dispose();
    wCtrl.dispose();
    hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Box",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formulas:\nV = L × W × H\nSA = 2(LW + LH + WH)",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),

            const SizedBox(height: 16),

            terminalNumberField(
              accent: accent,
              label: "Length (L)",
              hint: "units",
              controller: lCtrl,
            ),

            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Width (W)",
              hint: "units",
              controller: wCtrl,
            ),

            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Height (H)",
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
