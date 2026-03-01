import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

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
  final loadLbfCtrl = TextEditingController(text: "50");  // lbf (point) or total lbf (uniform)
  final ePsiCtrl = TextEditingController(text: "29000000"); // steel approx
  final iIn4Ctrl = TextEditingController(text: "0.05"); // moment of inertia

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

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

    final L_in = _p(lengthInCtrl);
    final P_total = _p(loadLbfCtrl);
    final E = _p(ePsiCtrl);
    final I = _p(iIn4Ctrl);

    // Convert L to feet for moment outputs if desired
    final L_ft = (L_in == null) ? null : L_in / 12.0;

    double? Vmax_lbf; // max shear at fixed end
    double? Mmax_inlb; // max moment at fixed end
    double? defl_in; // tip deflection

    if (L_in != null && P_total != null) {
      if (loadType == CantileverLoadType.endPoint) {
        // Point load at free end:
        // Vmax = P
        // Mmax = P*L
        // δ = P*L^3 / (3 E I)
        Vmax_lbf = P_total;
        Mmax_inlb = P_total * L_in;

        if (E != null && I != null && E > 0 && I > 0) {
          defl_in = (P_total * pow(L_in, 3)) / (3.0 * E * I);
        }
      } else {
        // Uniform load: user enters TOTAL load over length (lbf)
        // w = P_total/L
        // Vmax = wL = P_total
        // Mmax = wL^2/2 = P_total*L/2
        // δ = wL^4/(8 E I) = (P_total/L)*L^4/(8EI) = P_total*L^3/(8EI)
        Vmax_lbf = P_total;
        Mmax_inlb = (P_total * L_in) / 2.0;

        if (E != null && I != null && E > 0 && I > 0) {
          defl_in = (P_total * pow(L_in, 3)) / (8.0 * E * I);
        }
      }
    }

    final Mmax_ftlb = (Mmax_inlb == null) ? null : Mmax_inlb / 12.0;

    return TerminalScaffold(
      title: "Cantilever Beam",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Load type:",
              style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w800),
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
            terminalNumberField(accent: accent, label: "Length L (in)", hint: "in", controller: lengthInCtrl),
            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: loadType == CantileverLoadType.endPoint ? "Load P (lbf)" : "Total load over length (lbf)",
              hint: "lbf",
              controller: loadLbfCtrl,
            ),
            const SizedBox(height: 12),

            // Optional deflection inputs
            Text(
              "Deflection inputs (optional):",
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            terminalNumberField(accent: accent, label: "E (psi)", hint: "psi", controller: ePsiCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "I (in^4)", hint: "in^4", controller: iIn4Ctrl),

            const SizedBox(height: 18),
            terminalResultCard(
              accent: accent,
              lines: [
                if (Vmax_lbf == null) "Max Shear Vmax: —" else "Max Shear Vmax: ${Vmax_lbf.toStringAsFixed(2)} lbf",
                if (Mmax_inlb == null) "Max Moment Mmax: —" else "Max Moment Mmax: ${Mmax_inlb.toStringAsFixed(2)} in-lb",
                if (Mmax_ftlb == null) "" else "Max Moment Mmax: ${Mmax_ftlb.toStringAsFixed(2)} ft-lb",
                if (defl_in == null) "Tip Deflection δ: — (need E and I)"
                else "Tip Deflection δ: ${defl_in.toStringAsFixed(4)} in",
              ].where((s) => s.isNotEmpty).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
