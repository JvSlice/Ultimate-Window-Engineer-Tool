import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

class PipePage extends StatefulWidget {
  const PipePage({super.key});

  @override
  State<PipePage> createState() => _PipePageState();
}

class _PipePageState extends State<PipePage> {
  final odCtrl = TextEditingController(text: "2.0");
  final idCtrl = TextEditingController(text: "1.5");
  final lenCtrl = TextEditingController(text: "12.0");

  double? area;
  double? volume;
  String? warning;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final od = _p(odCtrl);
    final id = _p(idCtrl);
    final len = _p(lenCtrl);

    setState(() {
      area = null;
      volume = null;
      warning = null;

      if (od == null || id == null) return;

      if (id > od) {
        warning = "ID must be ≤ OD";
        return;
      }

      final ro = od / 2.0;
      final ri = id / 2.0;

      area = pi * (ro * ro - ri * ri);

      if (len != null) {
        volume = area! * len;
      }
    });
  }

  @override
  void dispose() {
    odCtrl.dispose();
    idCtrl.dispose();
    lenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Pipe / Tube",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formulas:\nA = π(Ro² − Ri²)\nV = A × L",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),

            const SizedBox(height: 16),

            terminalNumberField(
              accent: accent,
              label: "OD",
              hint: "units",
              controller: odCtrl,
            ),

            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "ID",
              hint: "units",
              controller: idCtrl,
            ),

            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Length (L)",
              hint: "units",
              controller: lenCtrl,
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

            if (warning != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  warning!,
                  style: TextStyle(color: accent.withValues(alpha: 0.85)),
                ),
              ),

            terminalResultCard(
              accent: accent,
              lines: [
                "Area (A): ${area == null ? '—' : area!.toStringAsFixed(4)}",
                "Volume (V): ${volume == null ? '—' : volume!.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
