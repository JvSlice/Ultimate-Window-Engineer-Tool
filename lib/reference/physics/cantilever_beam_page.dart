import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';
import 'section_props_store.dart';

enum CantileverLoadType { endPoint, uniform }

class CantileverBeamPage extends StatefulWidget {
  const CantileverBeamPage({super.key});

  @override
  State<CantileverBeamPage> createState() => _CantileverBeamPageState();
}

class _CantileverBeamPageState extends State<CantileverBeamPage> {
  CantileverLoadType loadType = CantileverLoadType.endPoint;

  // Inputs
  final lengthInCtrl = TextEditingController(text: "24"); // inches
  final loadLbfCtrl = TextEditingController(text: "50"); // lbf (point) or total lbf (uniform)
  final ePsiCtrl = TextEditingController(text: "29000000"); // steel approx
  final iIn4Ctrl = TextEditingController(text: "0.05"); // moment of inertia

  // Results (only update on Calculate)
  double? Vmax_lbf;
  double? Mmax_inlb;
  double? defl_in;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final L_in = _p(lengthInCtrl);
    final P_total = _p(loadLbfCtrl);
    final E = _p(ePsiCtrl);
    final I = _p(iIn4Ctrl);

    setState(() {
      Vmax_lbf = null;
      Mmax_inlb = null;
      defl_in = null;

      if (L_in == null || P_total == null || L_in <= 0) return;

      if (loadType == CantileverLoadType.endPoint) {
        Vmax_lbf = P_total;
        Mmax_inlb = P_total * L_in;

        if (E != null && I != null && E > 0 && I > 0) {
          defl_in = (P_total * pow(L_in, 3)) / (3.0 * E * I);
        }
      } else {
        Vmax_lbf = P_total;
        Mmax_inlb = (P_total * L_in) / 2.0;

        if (E != null && I != null && E > 0 && I > 0) {
          defl_in = (P_total * pow(L_in, 3)) / (8.0 * E * I);
        }
      }
    });
  }

  void _useSavedI() {
    final saved = lastSectionProps.value;
    if (saved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No saved section properties yet.")),
      );
      return;
    }

    // saved.ix is in saved.units (in^4 or mm^4)
    double ixIn4 = saved.ix;
    if (saved.units == SectionIUnits.mm) {
      // mm^4 -> in^4 : divide by 25.4^4
      ixIn4 = ixIn4 / pow(25.4, 4);
    }

    setState(() {
      iIn4Ctrl.text = ixIn4.toStringAsFixed(6);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Loaded Ix = ${ixIn4.toStringAsFixed(6)} in^4")),
    );
  }

  @override
  void dispose() {
    lengthInCtrl.dispose();
    loadLbfCtrl.dispose();
    ePsiCtrl.dispose();
    iIn4Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final Mmax_ftlb = (Mmax_inlb == null) ? null : Mmax_inlb! / 12.0;

    return TerminalScaffold(
      title: "Cantilever Beam",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Load type:",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => loadType = CantileverLoadType.endPoint),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent, width: 2),
                      backgroundColor: loadType == CantileverLoadType.endPoint
                          ? accent.withValues(alpha: 0.80)
                          : Colors.transparent,
                    ),
                    child: Text("END LOAD", style: TextStyle(color: accent)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => loadType = CantileverLoadType.uniform),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent, width: 2),
                      backgroundColor: loadType == CantileverLoadType.uniform
                          ? accent.withValues(alpha: 0.80)
                          : Colors.transparent,
                    ),
                    child: Text("UNIFORM", style: TextStyle(color: accent)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              loadType == CantileverLoadType.endPoint
                  ? "Point load at free end:\nVmax = P\nMmax = P·L\nδ = P·L³ / (3EI)"
                  : "Uniform load (using TOTAL load):\nVmax = P_total\nMmax = P_total·L / 2\nδ = P_total·L³ / (8EI)",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),

            const SizedBox(height: 18),
            terminalNumberField(
              accent: accent,
              label: "Length L (in)",
              hint: "in",
              controller: lengthInCtrl,
            ),
            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: loadType == CantileverLoadType.endPoint
                  ? "Load P (lbf)"
                  : "Total load over length (lbf)",
              hint: "lbf",
              controller: loadLbfCtrl,
            ),

            const SizedBox(height: 14),
            Text(
              "Deflection inputs (optional):",
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            terminalNumberField(
              accent: accent,
              label: "E (psi)",
              hint: "psi",
              controller: ePsiCtrl,
            ),
            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: "I (in^4)",
              hint: "in^4",
              controller: iIn4Ctrl,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: terminalCalcButton(
                    accent: accent,
                    onPressed: _calculate,
                    label: "Calculate",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: terminalCalcButton(
                    accent: accent,
                    onPressed: _useSavedI,
                    label: "Use Saved I",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            terminalResultCard(
              accent: accent,
              lines: [
                "Max Shear Vmax: ${Vmax_lbf == null ? '—' : Vmax_lbf!.toStringAsFixed(2)} lbf",
                "Max Moment Mmax: ${Mmax_inlb == null ? '—' : Mmax_inlb!.toStringAsFixed(2)} in-lb",
                "Max Moment Mmax: ${Mmax_ftlb == null ? '—' : Mmax_ftlb.toStringAsFixed(2)} ft-lb",
                defl_in == null
                    ? "Tip Deflection δ: — (need E and I)"
                    : "Tip Deflection δ: ${defl_in!.toStringAsFixed(4)} in",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
