import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

enum TigMode { dc, ac }

class TigTungstenPage extends StatefulWidget {
  const TigTungstenPage({super.key});

  @override
  State<TigTungstenPage> createState() => _TigTungstenPageState();
}

class _TigTungstenPageState extends State<TigTungstenPage> {
  TigMode mode = TigMode.dc;

  final ampsCtrl = TextEditingController(text: "120");

  // results
  String? _recommendedType;
  String? _recommendedDiameter;
  String? _prepTip;
  String? _notes;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void dispose() {
    ampsCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final a = _p(ampsCtrl);

    setState(() {
      if (a == null || a <= 0) {
        _recommendedType = null;
        _recommendedDiameter = null;
        _prepTip = null;
        _notes = "Enter a valid amperage.";
        return;
      }

      // --- Type guidance (simple + shop-realistic) ---
      // DC steel/stainless: 2% Lanthanated (Blue) or 2% Thoriated (Red)
      // AC aluminum: 2% Lanthanated (Blue) is a great modern default
      if (mode == TigMode.dc) {
        _recommendedType = "2% Lanthanated (Blue) — best all-around DC";
        _prepTip = "Tip: Sharp/pointed grind (lengthwise), small flat on point.";
        _notes = "DC is typically steel/stainless. Blue works great and avoids thoriated handling concerns.";
      } else {
        _recommendedType = "2% Lanthanated (Blue) — best all-around AC";
        _prepTip = "Tip: Slightly blunted point / small flat (modern inverters).";
        _notes = "AC is typically aluminum. Pure (Green) is old-school; Blue is a strong modern default.";
      }

      // --- Diameter guidance (rule-of-thumb ranges) ---
      // DC (approx):
      // 1/16  : up to ~90A
      // 3/32  : ~90–200A
      // 1/8   : ~200–350A
      //
      // AC aluminum often wants a bit more tungsten (or you’ll “mushroom” it),
      // so we bias 1 step larger when near boundaries.
      String diameter;
      if (a <= 90) {
        diameter = (mode == TigMode.ac && a > 70) ? "3/32 in" : "1/16 in";
      } else if (a <= 200) {
        diameter = "3/32 in";
      } else if (a <= 350) {
        diameter = "1/8 in";
      } else {
        diameter = "5/32 in (high amp range)";
      }

      _recommendedDiameter = diameter;

      // Extra note tweak for AC
      if (mode == TigMode.ac) {
        _notes =
            "${_notes!}\nIf you see the tip balling/melting, go up a size or reduce amps / adjust balance.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "TIG Tungsten (AC/DC + Amps)",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Pick AC or DC, enter amps, then Calculate.",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 14),

            // AC/DC toggle
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => mode = TigMode.dc),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent, width: 2),
                      backgroundColor: mode == TigMode.dc
                          ? accent.withValues(alpha: 0.80)
                          : Colors.transparent,
                    ),
                    child: Text(
                      "DC",
                      style: TextStyle(color: accent, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => mode = TigMode.ac),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent, width: 2),
                      backgroundColor: mode == TigMode.ac
                          ? accent.withValues(alpha: 0.80)
                          : Colors.transparent,
                    ),
                    child: Text(
                      "AC",
                      style: TextStyle(color: accent, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            terminalNumberField(
              accent: accent,
              label: "Amps (A)",
              hint: "ex: 120",
              controller: ampsCtrl,
            ),

            const SizedBox(height: 14),

            terminalCalcButton(
              accent: accent,
              onPressed: _calculate,
            ),

            const SizedBox(height: 18),

            terminalResultCard(
              accent: accent,
              lines: [
                "Mode: ${mode == TigMode.dc ? 'DC (steel/stainless typical)' : 'AC (aluminum typical)'}",
                "Recommended tungsten type: ${_recommendedType ?? '—'}",
                "Recommended diameter: ${_recommendedDiameter ?? '—'}",
                "Prep: ${_prepTip ?? '—'}",
                if (_notes != null) "Notes: $_notes",
              ],
            ),

            const SizedBox(height: 18),

            // Quick cheat ranges (always visible)
            terminalResultCard(
              accent: accent,
              lines: const [
                "Quick size ranges (rule-of-thumb):",
                "• 1/16 in  → up to ~90A (DC), lower AC",
                "• 3/32 in  → ~90–200A",
                "• 1/8 in   → ~200–350A",
                "• 5/32 in  → 350A+",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
