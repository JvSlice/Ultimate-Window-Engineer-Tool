import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

enum WaterFactorMode { fifteen, twenty, custom }

class StructuralTestMathPage extends StatefulWidget {
  const StructuralTestMathPage({super.key});

  @override
  State<StructuralTestMathPage> createState() => _StructuralTestMathPageState();
}

class _StructuralTestMathPageState extends State<StructuralTestMathPage> {
  final designPressureCtrl = TextEditingController(text: "");
  final overloadCtrl = TextEditingController(text: "");
  final psfCtrl = TextEditingController(text: "");
  final waterPressureCtrl = TextEditingController(text: "");
  final customFactorCtrl = TextEditingController(text: "20");

  WaterFactorMode factorMode = WaterFactorMode.twenty;

  double? designFromDp;
  double? overloadFromDp;
  double? designFromOverload;
  double? overloadInput;

  double? waterFromPsf;
  double? psfFromWater;

  double? waterRaw;
  double? waterPre22;
  double? water2022;

  String? warning;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  double _waterFactor() {
    switch (factorMode) {
      case WaterFactorMode.fifteen:
        return 0.15;
      case WaterFactorMode.twenty:
        return 0.20;
      case WaterFactorMode.custom:
        final val = _p(customFactorCtrl);
        if (val == null) return 0.20;
        return val / 100.0;
    }
  }

  void _calculate() {
    final dp = _p(designPressureCtrl);
    final overload = _p(overloadCtrl);
    final psf = _p(psfCtrl);
    final water = _p(waterPressureCtrl);
    final factor = _waterFactor();
    waterRaw = null;
    waterPre22 = null;
    water2022 = null;

    setState(() {
      warning = null;

      designFromDp = null;
      overloadFromDp = null;
      designFromOverload = null;
      overloadInput = null;
      waterFromPsf = null;
      psfFromWater = null;

      if (factor <= 0) {
        warning = "Water factor must be greater than 0%.";
        return;
      }

      // DP -> Overload
      if (dp != null) {
        designFromDp = dp;
        overloadFromDp = dp * 1.5;
      }

      // Overload -> DP
      if (overload != null) {
        overloadInput = overload;
        designFromOverload = overload / 1.5;
      }

      // PSF -> Water
      if (psf != null) {
        waterRaw = psf * factor;

        waterPre22 = waterRaw! > 12 ? 12 : waterRaw;
        water2022 = waterRaw! > 15 ? 15 : waterRaw;
      }

      // Water -> PSF
      if (water != null) {
        if (factor == 0) {
          warning = "Water factor cannot be 0%.";
        } else {
          psfFromWater = water / factor;
        }
      }

      final noInputs =
          dp == null && overload == null && psf == null && water == null;

      if (noInputs) {
        warning = "Enter at least one value to calculate.";
      }
    });
  }

  Widget _factorButton(Color accent, String label, WaterFactorMode mode) {
    final selected = factorMode == mode;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            factorMode = mode;
          });
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 2),
          backgroundColor: selected
              ? accent.withValues(alpha: 0.80)
              : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(color: accent, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  @override
  void dispose() {
    designPressureCtrl.dispose();
    overloadCtrl.dispose();
    psfCtrl.dispose();
    waterPressureCtrl.dispose();
    customFactorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final factorPercent = (_waterFactor() * 100).toStringAsFixed(1);

    return TerminalScaffold(
      title: "Structural Test Math",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Quick math for design pressure, overload, and water test pressure.",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),

            Text(
              "Design Pressure / Overload",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "Overload = DP × 1.5\nDP = Overload ÷ 1.5",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 14),

            terminalNumberField(
              accent: accent,
              label: "Design Pressure (psf)",
              hint: "Enter DP",
              controller: designPressureCtrl,
            ),
            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Overload Pressure (psf)",
              hint: "Enter overload",
              controller: overloadCtrl,
            ),

            const SizedBox(height: 22),

            Text(
              "PSF / Water Pressure",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "Water pressure = PSF × factor\nPSF = Water pressure ÷ factor",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                _factorButton(accent, "15%", WaterFactorMode.fifteen),
                const SizedBox(width: 10),
                _factorButton(accent, "20%", WaterFactorMode.twenty),
                const SizedBox(width: 10),
                _factorButton(accent, "CUSTOM", WaterFactorMode.custom),
              ],
            ),

            const SizedBox(height: 12),

            if (factorMode == WaterFactorMode.custom)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: terminalNumberField(
                  accent: accent,
                  label: "Custom Water Factor (%)",
                  hint: "ex: 18",
                  controller: customFactorCtrl,
                ),
              ),

            terminalNumberField(
              accent: accent,
              label: "PSF for Water Conversion",
              hint: "Enter PSF",
              controller: psfCtrl,
            ),
            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Water Pressure",
              hint: "Enter water pressure",
              controller: waterPressureCtrl,
            ),

            const SizedBox(height: 16),

            terminalCalcButton(accent: accent, onPressed: _calculate),

            const SizedBox(height: 18),

            if (warning != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  warning!,
                  style: TextStyle(color: accent.withValues(alpha: 0.9)),
                ),
              ),

            terminalResultCard(
              accent: accent,
              lines: [
                "DP input: ${designFromDp == null ? '—' : designFromDp!.toStringAsFixed(3)} psf",
                "Overload from DP: ${overloadFromDp == null ? '—' : overloadFromDp!.toStringAsFixed(3)} psf",
                "Overload input: ${overloadInput == null ? '—' : overloadInput!.toStringAsFixed(3)} psf",
                "DP from overload: ${designFromOverload == null ? '—' : designFromOverload!.toStringAsFixed(3)} psf",
              ],
            ),

            const SizedBox(height: 14),

            terminalResultCard(
              accent: accent,
              lines: [
                "Water factor: $factorPercent%",
                "Water pressure from PSF: ${waterFromPsf == null ? '—' : waterFromPsf!.toStringAsFixed(3)}",
                "PSF from water pressure: ${psfFromWater == null ? '—' : psfFromWater!.toStringAsFixed(3)}",
                "Pre-2022 cap (12PSF): ${waterPre22 == null ? "-" : waterPre22!.toStringAsFixed(3)} psf",
                "2022+ cap (15 psf): ${water2022 == null ? '-' : water2022!.toStringAsFixed(3)} PSF",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
