import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../materials/material_data.dart';
import '../materials/material_models.dart';

class ThermalExpansionPage extends StatefulWidget {
  const ThermalExpansionPage({super.key});

  @override
  State<ThermalExpansionPage> createState() => _ThermalExpansionPageState();
}

class _ThermalExpansionPageState extends State<ThermalExpansionPage> {
  late MaterialSpec selectedMaterial;
  final customCoeffCtrl = TextEditingController();
  final tempDiffCtrl = TextEditingController(text: '20');
  final lengthCtrl = TextEditingController(text: '72');

  @override
  void initState() {
    super.initState();
    final usableMaterials = _materialsWithExpansion;
    selectedMaterial = usableMaterials.firstWhere(
      (m) => m.name.contains('6061'),
      orElse: () => usableMaterials.first,
    );
  }

  @override
  void dispose() {
    customCoeffCtrl.dispose();
    tempDiffCtrl.dispose();
    lengthCtrl.dispose();
    super.dispose();
  }

  List<MaterialSpec> get _materialsWithExpansion {
    final list = materials
        .where((m) => m.thermalExpansionMicroInInF != null)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  double _readDouble(TextEditingController ctrl, double fallback) {
    return double.tryParse(ctrl.text.trim()) ?? fallback;
  }

  double get _selectedCoeff => selectedMaterial.thermalExpansionMicroInInF ?? 0;

  double get _activeCoeff {
    final custom = double.tryParse(customCoeffCtrl.text.trim());
    if (custom != null && custom > 0) return custom;
    return _selectedCoeff;
  }

  String _fmt(double value, int places) {
    if (value.isNaN || value.isInfinite) return '—';
    return value.toStringAsFixed(places);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final usableMaterials = _materialsWithExpansion;

    final coeffMicroInInF = _activeCoeff;
    final coeffInInF = coeffMicroInInF / 1000000.0;
    final coeffMicroMMMC = coeffMicroInInF * 1.8;
    final tempDiffF = _readDouble(tempDiffCtrl, 20);
    final lengthIn = _readDouble(lengthCtrl, 72);

    final deltaIn = coeffInInF * lengthIn * tempDiffF;
    final deltaThousandths = deltaIn * 1000;
    final finalLengthIn = lengthIn + deltaIn;
    final lengthFt = lengthIn / 12;
    final deltaMm = deltaIn * 25.4;

    return TerminalScaffold(
      title: 'Thermal Expansion',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Linear thermal expansion: ΔL = α × L × ΔT',
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 14),

            Text(
              'Material',
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: accent.withValues(alpha: 0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<MaterialSpec>(
                  value: selectedMaterial,
                  dropdownColor: Colors.black,
                  iconEnabledColor: accent,
                  isExpanded: true,
                  style: TextStyle(color: accent),
                  items: usableMaterials
                      .map(
                        (m) => DropdownMenuItem<MaterialSpec>(
                          value: m,
                          child: Text(
                            '${m.name}  (${m.thermalExpansionMicroInInF!.toStringAsFixed(1)} µin/in/°F)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedMaterial = value);
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),
            terminalNumberField(
              accent: accent,
              label: 'Custom coefficient, optional (µin/in/°F)',
              hint: 'Leave blank to use selected material',
              controller: customCoeffCtrl,
            ),
            const SizedBox(height: 14),
            terminalNumberField(
              accent: accent,
              label: 'Temperature difference ΔT (°F)',
              hint: '20',
              controller: tempDiffCtrl,
            ),
            const SizedBox(height: 14),
            terminalNumberField(
              accent: accent,
              label: 'Original length L (inches)',
              hint: '72',
              controller: lengthCtrl,
            ),
            const SizedBox(height: 14),

            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => setState(() {}),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent, width: 2),
                ),
                child: Text(
                  'CALCULATE',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            terminalResultCard(
              accent: accent,
              lines: [
                'Selected material: ${selectedMaterial.name}',
                'Material coefficient: ${_fmt(_selectedCoeff, 2)} µin/in/°F',
                'Active coefficient: ${_fmt(coeffMicroInInF, 2)} µin/in/°F',
                'Metric equivalent: ${_fmt(coeffMicroMMMC, 2)} µm/m/°C',
                '',
                'Temperature difference: ${_fmt(tempDiffF, 2)} °F',
                'Starting length: ${_fmt(lengthIn, 3)} in (${_fmt(lengthFt, 3)} ft)',
                '',
                'Expansion / contraction: ${_fmt(deltaIn, 5)} in',
                'Expansion / contraction: ${_fmt(deltaThousandths, 3)} thousandths',
                'Expansion / contraction: ${_fmt(deltaMm, 3)} mm',
                'Final length: ${_fmt(finalLengthIn, 5)} in',
                '',
                'Note: A negative temperature difference returns shrinkage.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}
