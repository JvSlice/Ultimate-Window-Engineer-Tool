import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

class VelocityAccelPage extends StatefulWidget {
  const VelocityAccelPage({super.key});

  @override
  State<VelocityAccelPage> createState() => _VelocityAccelPageState();
}

class _VelocityAccelPageState extends State<VelocityAccelPage> {
  // Inputs (leave blank if unknown)
  final dCtrl = TextEditingController(text: "");     // distance
  final tCtrl = TextEditingController(text: "");     // time
  final vCtrl = TextEditingController(text: "");     // velocity (final or average depending on equation)
  final v0Ctrl = TextEditingController(text: "");    // initial velocity
  final dvCtrl = TextEditingController(text: "");    // delta v
  final aCtrl = TextEditingController(text: "");     // acceleration

  // Results
  double? _vFromDT;
  double? _aFromDvT;
  double? _vFromV0AT;
  double? _dFromV0AT;
  double? _vFromEnergy; // from v^2 = v0^2 + 2ad
  String? _warning;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void dispose() {
    dCtrl.dispose();
    tCtrl.dispose();
    vCtrl.dispose();
    v0Ctrl.dispose();
    dvCtrl.dispose();
    aCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final d = _p(dCtrl);
    final t = _p(tCtrl);
    final v = _p(vCtrl);
    final v0 = _p(v0Ctrl);
    final dv = _p(dvCtrl);
    final a = _p(aCtrl);

    setState(() {
      _warning = null;
      _vFromDT = null;
      _aFromDvT = null;
      _vFromV0AT = null;
      _dFromV0AT = null;
      _vFromEnergy = null;

      // v = d/t
      if (d != null && t != null) {
        if (t == 0) {
          _warning = "Time cannot be 0.";
        } else {
          _vFromDT = d / t;
        }
      }

      // a = Δv / t
      if (dv != null && t != null) {
        if (t == 0) {
          _warning = "Time cannot be 0.";
        } else {
          _aFromDvT = dv / t;
        }
      }

      // v = v0 + a t
      if (v0 != null && a != null && t != null) {
        _vFromV0AT = v0 + a * t;
      }

      // d = v0 t + 1/2 a t^2
      if (v0 != null && a != null && t != null) {
        _dFromV0AT = v0 * t + 0.5 * a * t * t;
      }

      // v^2 = v0^2 + 2 a d
      if (v0 != null && a != null && d != null) {
        final inside = (v0 * v0) + 2.0 * a * d;
        if (inside < 0) {
          _warning = "v² = v0² + 2ad went negative (check signs/units).";
        } else {
          _vFromEnergy = sqrt(inside);
        }
      }

      // If nothing computed, show a helpful message
      final any =
          _vFromDT != null ||
          _aFromDvT != null ||
          _vFromV0AT != null ||
          _dFromV0AT != null ||
          _vFromEnergy != null;

      if (!any && _warning == null) {
        _warning =
            "Enter enough values for at least one formula. Example: distance + time, or v0 + a + t.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Velocity & Acceleration",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Common formulas:\n"
              "v = d / t\n"
              "a = Δv / t\n"
              "v = v₀ + a·t\n"
              "d = v₀·t + ½·a·t²\n"
              "v² = v₀² + 2·a·d",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),

            // Inputs
            terminalNumberField(
              accent: accent,
              label: "Distance (d)",
              hint: "units (ft, m, in...)",
              controller: dCtrl,
            ),
            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: "Time (t)",
              hint: "seconds",
              controller: tCtrl,
            ),
            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: "Velocity (v)",
              hint: "units/sec",
              controller: vCtrl,
            ),
            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: "Initial velocity (v₀)",
              hint: "units/sec",
              controller: v0Ctrl,
            ),
            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: "Change in velocity (Δv)",
              hint: "units/sec",
              controller: dvCtrl,
            ),
            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: "Acceleration (a)",
              hint: "units/sec²",
              controller: aCtrl,
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
                "v = d/t: ${_vFromDT == null ? '—' : _vFromDT!.toStringAsFixed(6)}",
                "a = Δv/t: ${_aFromDvT == null ? '—' : _aFromDvT!.toStringAsFixed(6)}",
                "v = v₀ + a·t: ${_vFromV0AT == null ? '—' : _vFromV0AT!.toStringAsFixed(6)}",
                "d = v₀·t + ½·a·t²: ${_dFromV0AT == null ? '—' : _dFromV0AT!.toStringAsFixed(6)}",
                "v = √(v₀² + 2ad): ${_vFromEnergy == null ? '—' : _vFromEnergy!.toStringAsFixed(6)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
