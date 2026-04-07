import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

enum PulleyMode { solveEffort, solveLoad }

class PulleyPage extends StatefulWidget {
  const PulleyPage({super.key});

  @override
  State<PulleyPage> createState() => _PulleyPageState();
}

class _PulleyPageState extends State<PulleyPage> {
  PulleyMode mode = PulleyMode.solveEffort;

  // Inputs
  final partsCtrl = TextEditingController(text: "4");      // supporting rope parts
  final loadCtrl = TextEditingController(text: "200");     // lbf (or any force unit)
  final effortCtrl = TextEditingController(text: "");      // lbf (used if solving load)
  final effCtrl = TextEditingController(text: "85");       // percent (0-100)

  final liftCtrl = TextEditingController(text: "12");      // inches (or any length)
  // Results
  double? _ima;
  double? _ama;
  double? _effortOut;
  double? _loadOut;
  double? _ropePull;
  String? _warning;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void dispose() {
    partsCtrl.dispose();
    loadCtrl.dispose();
    effortCtrl.dispose();
    effCtrl.dispose();
    liftCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final parts = _p(partsCtrl);
    final load = _p(loadCtrl);
    final effort = _p(effortCtrl);
    final effPct = _p(effCtrl);
    final lift = _p(liftCtrl);

    setState(() {
      _warning = null;
      _ima = null;
      _ama = null;
      _effortOut = null;
      _loadOut = null;
      _ropePull = null;

      if (parts == null || parts <= 0) {
        _warning = "Supporting parts must be a positive number.";
        return;
      }

      final ima = parts; // ideal MA equals number of supporting rope parts
      _ima = ima;

      double eff = 1.0;
      if (effPct != null) {
        if (effPct <= 0 || effPct > 100) {
          _warning = "Efficiency must be 1–100%.";
          return;
        }
        eff = effPct / 100.0;
      }

      // Actual mechanical advantage (approx) = IMA * efficiency
      final ama = ima * eff;
      _ama = ama;

      if (mode == PulleyMode.solveEffort) {
        if (load == null || load <= 0) {
          _warning = "Enter a positive Load to solve for Effort.";
          return;
        }
        // Effort = Load / AMA
        _effortOut = load / ama;
        _loadOut = load;
      } else {
        if (effort == null || effort <= 0) {
          _warning = "Enter a positive Effort to solve for Load.";
          return;
        }
        // Load = Effort * AMA
        _loadOut = effort * ama;
        _effortOut = effort;
      }

      // Distance tradeoff: rope pulled = lift * IMA (ideal)
      if (lift != null && lift > 0) {
        _ropePull = lift * ima;
      }
    });
  }

  Widget _modeButton(Color accent, String label, PulleyMode m) {
    final selected = mode == m;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => mode = m),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 2),
          backgroundColor: selected ? accent.withValues(alpha: 0.80) : Colors.transparent,
        ),
        child: Text(label, style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Pulley Calculator",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Basics:\n"
              "IMA = supporting rope parts\n"
              "AMA ≈ IMA × efficiency\n"
              "Effort = Load ÷ AMA\n"
              "Load = Effort × AMA\n"
              "Rope pulled (ideal) = Lift × IMA",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),

            Text("Solve for:", style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(
              children: [
                _modeButton(accent, "EFFORT", PulleyMode.solveEffort),
                const SizedBox(width: 10),
                _modeButton(accent, "LOAD", PulleyMode.solveLoad),
              ],
            ),

            const SizedBox(height: 18),
            terminalNumberField(
              accent: accent,
              label: "Supporting rope parts (IMA)",
              hint: "ex: 2, 4, 6",
              controller: partsCtrl,
            ),
            const SizedBox(height: 12),

            if (mode == PulleyMode.solveEffort) ...[
              terminalNumberField(
                accent: accent,
                label: "Load (force)",
                hint: "lbf (or N)",
                controller: loadCtrl,
              ),
            ] else ...[
              terminalNumberField(
                accent: accent,
                label: "Effort (force)",
                hint: "lbf (or N)",
                controller: effortCtrl,
              ),
            ],

            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: "Efficiency (%)",
              hint: "ex: 85",
              controller: effCtrl,
            ),

            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: "Lift distance (optional)",
              hint: "in (or mm)",
              controller: liftCtrl,
            ),

            const SizedBox(height: 16),
            terminalCalcButton(
              accent: accent,
              onPressed: _calculate,
            ),

            const SizedBox(height: 18),

            if (_warning != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_warning!, style: TextStyle(color: accent.withValues(alpha: 0.9))),
              ),

            terminalResultCard(
              accent: accent,
              lines: [
                "IMA: ${_ima == null ? '—' : _ima!.toStringAsFixed(2)}",
                "AMA (with efficiency): ${_ama == null ? '—' : _ama!.toStringAsFixed(2)}",
                "Load: ${_loadOut == null ? '—' : _loadOut!.toStringAsFixed(3)}",
                "Effort: ${_effortOut == null ? '—' : _effortOut!.toStringAsFixed(3)}",
                "Rope pulled (ideal): ${_ropePull == null ? '—' : _ropePull!.toStringAsFixed(3)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
