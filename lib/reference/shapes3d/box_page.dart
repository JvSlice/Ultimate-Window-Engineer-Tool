import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

class BoxPage extends StatefulWidget {
  const BoxPage({super.key});

  @override
  State<BoxPage> createState() => _BoxPageState();
}

class _BoxPageState extends State<BoxPage> {
  final lCtrl = TextEditingController(text: "10");
  final wCtrl = TextEditingController(text: "5");
  final hCtrl = TextEditingController(text: "2");

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

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
    final l = _p(lCtrl);
    final w = _p(wCtrl);
    final h = _p(hCtrl);

    final vol = (l == null || w == null || h == null) ? null : l * w * h;
    final sa = (l == null || w == null || h == null)
        ? null
        : 2 * (l * w + l * h + w * h);

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
            terminalNumberField(accent: accent, label: "Length (L)", hint: "units", controller: lCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "Width (W)", hint: "units", controller: wCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "Height (H)", hint: "units", controller: hCtrl),
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
