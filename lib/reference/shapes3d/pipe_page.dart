import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';
import '../../reference/materials/material_data.dart';
import '../../reference/materials/material_models.dart';
import '../../reference/materials/material_units.dart';

enum TubeShape { round, rectangular }

class PipePage extends StatefulWidget {
  const PipePage({super.key});

  @override
  State<PipePage> createState() => _PipePageState();
}

class _PipePageState extends State<PipePage> {
  TubeShape shape = TubeShape.round;

  // Round tube inputs
  final odCtrl = TextEditingController(text: "2.0");
  final idCtrl = TextEditingController(text: "1.5");

  // Rectangular tube inputs
  final outerWidthCtrl = TextEditingController(text: "2.0");
  final outerHeightCtrl = TextEditingController(text: "2.0");
  final wallCtrl = TextEditingController(text: "0.125");

  // Shared
  final lenCtrl = TextEditingController(text: "12.0");

  MaterialSpec? selectedMaterial;

  double? area;
  double? volume;
  double? weightLb;
  String? warning;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final len = _p(lenCtrl);

    setState(() {
      area = null;
      volume = null;
      weightLb = null;
      warning = null;

      if (shape == TubeShape.round) {
        final od = _p(odCtrl);
        final id = _p(idCtrl);

        if (od == null || id == null) {
          warning = "Enter OD and ID.";
          return;
        }

        if (od <= 0 || id < 0) {
          warning = "OD must be > 0 and ID must be ≥ 0.";
          return;
        }

        if (id > od) {
          warning = "ID must be ≤ OD.";
          return;
        }

        final ro = od / 2.0;
        final ri = id / 2.0;

        area = pi * (ro * ro - ri * ri);
      } else {
        final outerW = _p(outerWidthCtrl);
        final outerH = _p(outerHeightCtrl);
        final wall = _p(wallCtrl);

        if (outerW == null || outerH == null || wall == null) {
          warning = "Enter outer width, outer height, and wall thickness.";
          return;
        }

        if (outerW <= 0 || outerH <= 0 || wall <= 0) {
          warning = "All dimensions must be greater than 0.";
          return;
        }

        final innerW = outerW - (2 * wall);
        final innerH = outerH - (2 * wall);

        if (innerW < 0 || innerH < 0) {
          warning = "Wall thickness is too large for the entered outer dimensions.";
          return;
        }

        area = (outerW * outerH) - (innerW * innerH);
      }

      if (len != null) {
        if (len <= 0) {
          warning = "Length must be greater than 0.";
          return;
        }

        volume = area! * len;

        if (selectedMaterial != null) {
          final densityLbIn3 = kgm3ToLbIn3(selectedMaterial!.densityKgM3);
          weightLb = volume! * densityLbIn3;
        }
      }
    });
  }

  @override
  void dispose() {
    odCtrl.dispose();
    idCtrl.dispose();
    outerWidthCtrl.dispose();
    outerHeightCtrl.dispose();
    wallCtrl.dispose();
    lenCtrl.dispose();
    super.dispose();
  }

  Widget _shapeButton(
    Color accent,
    String label,
    TubeShape value,
  ) {
    final selected = shape == value;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            shape = value;
            warning = null;
          });
        },
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
        ),
      ),
    );
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
              shape == TubeShape.round
                  ? "Round Tube Formulas:\nA = π(Ro² − Ri²)\nV = A × L\nWeight = Volume × Density"
                  : "Square / Rectangular Tube Formulas:\nA = (OW × OH) − (IW × IH)\nIW = OW − 2t\nIH = OH − 2t\nV = A × L\nWeight = Volume × Density",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _shapeButton(accent, "ROUND", TubeShape.round),
                const SizedBox(width: 10),
                _shapeButton(accent, "RECT / SQ", TubeShape.rectangular),
              ],
            ),

            const SizedBox(height: 16),

            if (shape == TubeShape.round) ...[
              terminalNumberField(
                accent: accent,
                label: "OD",
                hint: "inches",
                controller: odCtrl,
              ),
              const SizedBox(height: 12),
              terminalNumberField(
                accent: accent,
                label: "ID",
                hint: "inches",
                controller: idCtrl,
              ),
            ] else ...[
              terminalNumberField(
                accent: accent,
                label: "Outer Width",
                hint: "inches",
                controller: outerWidthCtrl,
              ),
              const SizedBox(height: 12),
              terminalNumberField(
                accent: accent,
                label: "Outer Height",
                hint: "inches",
                controller: outerHeightCtrl,
              ),
              const SizedBox(height: 12),
              terminalNumberField(
                accent: accent,
                label: "Wall Thickness",
                hint: "inches",
                controller: wallCtrl,
              ),
            ],

            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Length (L)",
              hint: "inches",
              controller: lenCtrl,
            ),

            const SizedBox(height: 16),

            Text(
              "Material",
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: accent, width: 2),
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
              ),
              child: DropdownButton<MaterialSpec>(
                value: selectedMaterial,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: Colors.black,
                iconEnabledColor: accent,
                style: TextStyle(color: accent),
                hint: Text(
                  "Select material",
                  style: TextStyle(color: accent.withValues(alpha: 0.7)),
                ),
                items: materials.map((m) {
                  return DropdownMenuItem<MaterialSpec>(
                    value: m,
                    child: Text(
                      m.name,
                      style: TextStyle(color: accent),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMaterial = value;
                  });
                },
              ),
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
                "Shape: ${shape == TubeShape.round ? 'Round Tube' : 'Square / Rectangular Tube'}",
                "Area (A): ${area == null ? '—' : '${area!.toStringAsFixed(4)} in²'}",
                "Volume (V): ${volume == null ? '—' : '${volume!.toStringAsFixed(4)} in³'}",
                "Material: ${selectedMaterial?.name ?? '—'}",
                "Weight: ${weightLb == null ? '—' : '${weightLb!.toStringAsFixed(4)} lb'}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
