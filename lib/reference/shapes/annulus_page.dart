import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

class AnnulusPage extends StatefulWidget {
  const AnnulusPage({super.key});

  @override
  State<AnnulusPage> createState() => _AnnulusPageState();
}

class _AnnulusPageState extends State<AnnulusPage> {
  final roCtrl = TextEditingController(text: "2");
  final riCtrl = TextEditingController(text: "1");

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void dispose() {
    roCtrl.dispose();
    riCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final ro = _p(roCtrl);
    final ri = _p(riCtrl);

    double? area;
    String? warning;

    if (ro != null && ri != null) {
      if (ri > ro) {
        warning = "Inner radius must be ≤ outer radius";
      } else {
        area = pi * (ro * ro - ri * ri);
      }
    }

    return TerminalScaffold(
      title: "Annulus (Ring)",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formula:\nA = π(Ro² − Ri²)",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            terminalNumberField(accent: accent, label: "Outer radius (Ro)", hint: "units", controller: roCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "Inner radius (Ri)", hint: "units", controller: riCtrl),
            const SizedBox(height: 18),
            if (warning != null)
              Text(warning!, style: TextStyle(color: accent.withValues(alpha: 0.8))),
            terminalResultCard(
              accent: accent,
              lines: [
                if (area == null) "Area (A): —" else "Area (A): ${area.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
