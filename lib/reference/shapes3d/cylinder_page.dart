import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';
import '../../reference/materials/material_data.dart';
import '../../reference/materials/material_models.dart';
import '../../reference/materials/material_units.dart';

class CylinderPage extends StatefulWidget {
  const CylinderPage({super.key});

  @override
  State<CylinderPage> createState() => _CylinderPageState();
}

class _CylinderPageState extends State<CylinderPage> {
  final rCtrl = TextEditingController(text: "1");
  final hCtrl = TextEditingController(text: "4");

  MaterialSpec? selectedMaterial;

  double? volume;
  double? surfaceArea;
  double? weightLb;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final r = _p(rCtrl);
    final h = _p(hCtrl);

    setState(() {
      if (r == null || h == null || r <= 0 || h <= 0) {
        volume = null;
        surfaceArea = null;
        weightLb = null;
      } else {
        volume = pi * r * r * h;
        surfaceArea = (2 * pi * r * h) + (2 * pi * r * r);

        if (selectedMaterial != null) {
          final densityLbIn3 = kgm3ToLbIn3(selectedMaterial!.densityKgM3);
          weightLb = volume! * densityLbIn3;
        } else {
          weightLb = null;
        }
      }
    });
  }

  @override
  void dispose() {
    rCtrl.dispose();
    hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Cylinder",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formulas:\nV = πr²h\nSA = 2πrh + 2πr²\nWeight = Volume × Density",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),

            const SizedBox(height: 16),

            terminalNumberField(
              accent: accent,
              label: "Radius (r)",
              hint: "inches",
              controller: rCtrl,
            ),

            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Height (h)",
              hint: "inches",
              controller: hCtrl,
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

            terminalResultCard(
              accent: accent,
              lines: [
                "Volume (V): ${volume == null ? '—' : volume!.toStringAsFixed(4)} in³",
                "Surface Area (SA): ${surfaceArea == null ? '—' : surfaceArea!.toStringAsFixed(4)} in²",
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
