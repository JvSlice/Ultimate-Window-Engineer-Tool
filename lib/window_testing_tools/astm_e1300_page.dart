import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

enum GlassBuild { monolithic, igu }
enum GlassType { annealed, heatStrengthened, tempered, laminated }
enum LoadDuration { shortDuration, longDuration }

class AstmE1300Page extends StatefulWidget {
  const AstmE1300Page({super.key});

  @override
  State<AstmE1300Page> createState() => _AstmE1300PageState();
}

class _AstmE1300PageState extends State<AstmE1300Page> {
  GlassBuild glassbuild = GlassBuild.monolithic;
  LoadDuration duration = LoadDuration.shortDuration;

  GlassType monoType = GlassType.tempered;
  GlassType lite1Type = GlassType.tempered;
  GlassType lite2Type = GlassType.tempered;

  final shortSideCtrl = TextEditingController(text: "");
  final longSideCtrl = TextEditingController(text: "");
  final loadCtrl = TextEditingController(text: "");

  final monoThicknessCtrl = TextEditingController(text: "0.250");
  final lite1ThicknessCtrl = TextEditingController(text: "0.125");
  final lite2ThicknessCtrl = TextEditingController(text: "0.125");

  double? aspectRatio;
  double? monoAllowablePsf;
  double? lite1AllowablePsf;
  double? lite2AllowablePsf;
  double? lite1Share;
  double? lite2Share;
  double? lite1Applied;
  double? lite2Applied;
  bool? monoPass;
  bool? iguPass;
  String? warning;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  double _glassFactor(GlassType t) {
    switch (t) {
      case GlassType.annealed:
        return 1.00;
      case GlassType.heatStrengthened:
        return 2.00;
      case GlassType.tempered:
        return 4.00;
      case GlassType.laminated:
        return 1.20;
    }
  }

  double _durationFactor(LoadDuration d) {
    switch (d) {
      case LoadDuration.shortDuration:
        return 1.00;
      case LoadDuration.longDuration:
        return 0.70;
    }
  }

  // Reference-only screening formula.
  // This is intentionally simple and is NOT a standards-compliant ASTM table lookup.
  double _referenceAllowablePsf({
    required double thicknessIn,
    required GlassType glassType,
    required double aspectRatio,
    required LoadDuration duration,
  }) {
    const double baseK = 1400.0;

    final g = _glassFactor(glassType);
    final d = _durationFactor(duration);

    final arPenalty = 1.0 + ((aspectRatio - 1.0).clamp(0.0, 10.0) * 0.35);

    return (baseK * thicknessIn * thicknessIn * g * d) / arPenalty;
  }

  void _calculate() {
    final shortSide = _p(shortSideCtrl);
    final longSide = _p(longSideCtrl);
    final load = _p(loadCtrl);

    final monoThickness = _p(monoThicknessCtrl);
    final lite1Thickness = _p(lite1ThicknessCtrl);
    final lite2Thickness = _p(lite2ThicknessCtrl);

    setState(() {
      aspectRatio = null;
      monoAllowablePsf = null;
      lite1AllowablePsf = null;
      lite2AllowablePsf = null;
      lite1Share = null;
      lite2Share = null;
      lite1Applied = null;
      lite2Applied = null;
      monoPass = null;
      iguPass = null;
      warning = null;

      if (shortSide == null || longSide == null || load == null) {
        warning = "Enter short side, long side, and load.";
        return;
      }

      if (shortSide <= 0 || longSide <= 0 || load <= 0) {
        warning = "Inputs must be greater than 0.";
        return;
      }

      final shortDim = min(shortSide, longSide);
      final longDim = max(shortSide, longSide);
      aspectRatio = longDim / shortDim;

      if (build == GlassBuild.monolithic) {
        if (monoThickness == null || monoThickness <= 0) {
          warning = "Enter a valid monolithic glass thickness.";
          return;
        }

        monoAllowablePsf = _referenceAllowablePsf(
          thicknessIn: monoThickness,
          glassType: monoType,
          aspectRatio: aspectRatio!,
          duration: duration,
        );

        monoPass = load <= monoAllowablePsf!;
      } else {
        if (lite1Thickness == null ||
            lite2Thickness == null ||
            lite1Thickness <= 0 ||
            lite2Thickness <= 0) {
          warning = "Enter valid IGU lite thicknesses.";
          return;
        }

        // Simple reference-only load share by stiffness ~ t^3
        final k1 = pow(lite1Thickness, 3).toDouble();
        final k2 = pow(lite2Thickness, 3).toDouble();
        final kTotal = k1 + k2;

        lite1Share = k1 / kTotal;
        lite2Share = k2 / kTotal;

        lite1Applied = load * lite1Share!;
        lite2Applied = load * lite2Share!;

        lite1AllowablePsf = _referenceAllowablePsf(
          thicknessIn: lite1Thickness,
          glassType: lite1Type,
          aspectRatio: aspectRatio!,
          duration: duration,
        );

        lite2AllowablePsf = _referenceAllowablePsf(
          thicknessIn: lite2Thickness,
          glassType: lite2Type,
          aspectRatio: aspectRatio!,
          duration: duration,
        );

        iguPass = lite1Applied! <= lite1AllowablePsf! &&
            lite2Applied! <= lite2AllowablePsf!;
      }

      warning =
          "Reference-only screening tool. Not a final ASTM E1300 compliance result. Use Window Glass Design for offical Calculations.";
    });
  }

  Widget _toggleButton<T>({
    required Color accent,
    required String label,
    required T current,
    required T value,
    required VoidCallback onPressed,
  }) {
    final selected = current == value;

    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 2),
          backgroundColor:
              selected ? accent.withValues(alpha: 0.80) : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _glassTypeDropdown({
    required Color accent,
    required GlassType value,
    required ValueChanged<GlassType?> onChanged,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: accent, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: accent, width: 2),
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
          ),
          child: DropdownButton<GlassType>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: Colors.black,
            iconEnabledColor: accent,
            style: TextStyle(color: accent),
            items: GlassType.values.map((g) {
              return DropdownMenuItem(
                value: g,
                child: Text(
                  _glassTypeLabel(g),
                  style: TextStyle(color: accent),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _glassTypeLabel(GlassType g) {
    switch (g) {
      case GlassType.annealed:
        return "Annealed";
      case GlassType.heatStrengthened:
        return "Heat Strengthened";
      case GlassType.tempered:
        return "Tempered";
      case GlassType.laminated:
        return "Laminated";
    }
  }

  @override
  void dispose() {
    shortSideCtrl.dispose();
    longSideCtrl.dispose();
    loadCtrl.dispose();
    monoThicknessCtrl.dispose();
    lite1ThicknessCtrl.dispose();
    lite2ThicknessCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "ASTM E1300 (Reference)",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            terminalResultCard(
              accent: accent,
              lines: const [
                "Reference-only screening tool.",
                "Not a licensed ASTM table engine.",
                "Use for internal comparison / early review only.",
              ],
            ),
            const SizedBox(height: 16),

            Text(
              "Configuration",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _toggleButton<GlassBuild>(
                  accent: accent,
                  label: "MONOLITHIC",
                  current: glassbuild,
                  value: GlassBuild.monolithic,
                  onPressed: () {
                    setState(() {
                      glassbuild = GlassBuild.monolithic;
                    });
                  },
                ),
                const SizedBox(width: 10),
                _toggleButton<GlassBuild>(
                  accent: accent,
                  label: "IGU",
                  current: glassbuild,
                  value: GlassBuild.igu,
                  onPressed: () {
                    setState(() {
                      glassbuild = GlassBuild.igu;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _toggleButton<LoadDuration>(
                  accent: accent,
                  label: "SHORT",
                  current: duration,
                  value: LoadDuration.shortDuration,
                  onPressed: () {
                    setState(() {
                      duration = LoadDuration.shortDuration;
                    });
                  },
                ),
                const SizedBox(width: 10),
                _toggleButton<LoadDuration>(
                  accent: accent,
                  label: "LONG",
                  current: duration,
                  value: LoadDuration.longDuration,
                  onPressed: () {
                    setState(() {
                      duration = LoadDuration.longDuration;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              "Lite Geometry / Load",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Short Side (in)",
              hint: "ex: 24",
              controller: shortSideCtrl,
            ),
            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Long Side (in)",
              hint: "ex: 48",
              controller: longSideCtrl,
            ),
            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Applied Load (psf)",
              hint: "ex: 50",
              controller: loadCtrl,
            ),

            const SizedBox(height: 18),

            if (build == GlassBuild.monolithic) ...[
              _glassTypeDropdown(
                accent: accent,
                value: monoType,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    monoType = v;
                  });
                },
                label: "Glass Type",
              ),
              const SizedBox(height: 12),
              terminalNumberField(
                accent: accent,
                label: "Glass Thickness (in)",
                hint: "ex: 0.250",
                controller: monoThicknessCtrl,
              ),
            ] else ...[
              _glassTypeDropdown(
                accent: accent,
                value: lite1Type,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    lite1Type = v;
                  });
                },
                label: "Lite 1 Type",
              ),
              const SizedBox(height: 12),
              terminalNumberField(
                accent: accent,
                label: "Lite 1 Thickness (in)",
                hint: "ex: 0.125",
                controller: lite1ThicknessCtrl,
              ),
              const SizedBox(height: 12),
              _glassTypeDropdown(
                accent: accent,
                value: lite2Type,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    lite2Type = v;
                  });
                },
                label: "Lite 2 Type",
              ),
              const SizedBox(height: 12),
              terminalNumberField(
                accent: accent,
                label: "Lite 2 Thickness (in)",
                hint: "ex: 0.125",
                controller: lite2ThicknessCtrl,
              ),
            ],

            const SizedBox(height: 16),

            terminalCalcButton(
              accent: accent,
              onPressed: _calculate,
            ),

            const SizedBox(height: 18),

            if (warning != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  warning!,
                  style: TextStyle(
                    color: accent.withValues(alpha: 0.90),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            terminalResultCard(
              accent: accent,
              lines: [
                "Aspect Ratio (long / short): ${aspectRatio == null ? '—' : aspectRatio!.toStringAsFixed(3)}",
                "Build: ${build == GlassBuild.monolithic ? 'Monolithic' : 'IGU'}",
                "Duration: ${duration == LoadDuration.shortDuration ? 'Short' : 'Long'}",
              ],
            ),

            const SizedBox(height: 14),

            if (build == GlassBuild.monolithic)
              terminalResultCard(
                accent: accent,
                lines: [
                  "Glass Type: ${_glassTypeLabel(monoType)}",
                  "Reference Allowable Load: ${monoAllowablePsf == null ? '—' : monoAllowablePsf!.toStringAsFixed(3)} psf",
                  "Applied Load: ${_p(loadCtrl) == null ? '—' : _p(loadCtrl)!.toStringAsFixed(3)} psf",
                  "Result: ${monoPass == null ? '—' : (monoPass! ? 'PASS' : 'FAIL')}",
                ],
              )
            else
              terminalResultCard(
                accent: accent,
                lines: [
                  "Lite 1 Type: ${_glassTypeLabel(lite1Type)}",
                  "Lite 1 Load Share: ${lite1Share == null ? '—' : (lite1Share! * 100).toStringAsFixed(1)}%",
                  "Lite 1 Applied Load: ${lite1Applied == null ? '—' : lite1Applied!.toStringAsFixed(3)} psf",
                  "Lite 1 Allowable: ${lite1AllowablePsf == null ? '—' : lite1AllowablePsf!.toStringAsFixed(3)} psf",
                  "",
                  "Lite 2 Type: ${_glassTypeLabel(lite2Type)}",
                  "Lite 2 Load Share: ${lite2Share == null ? '—' : (lite2Share! * 100).toStringAsFixed(1)}%",
                  "Lite 2 Applied Load: ${lite2Applied == null ? '—' : lite2Applied!.toStringAsFixed(3)} psf",
                  "Lite 2 Allowable: ${lite2AllowablePsf == null ? '—' : lite2AllowablePsf!.toStringAsFixed(3)} psf",
                  "",
                  "IGU Result: ${iguPass == null ? '—' : (iguPass! ? 'PASS' : 'FAIL')}",
                ],
              ),
          ],
        ),
      ),
    );
  }
}

