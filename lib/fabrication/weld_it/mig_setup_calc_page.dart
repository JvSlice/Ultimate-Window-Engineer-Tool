import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import 'weld_data.dart';
import 'weld_models.dart';

class MigSetupCalcPage extends StatefulWidget {
  const MigSetupCalcPage({super.key});

  @override
  State<MigSetupCalcPage> createState() => _MigSetupCalcPageState();
}

class _MigSetupCalcPageState extends State<MigSetupCalcPage> {
  WeldMaterial _selectedMaterial = weldMaterials.first;
  ThicknessOption _selectedThickness = weldThicknessOptions[1];

  MigRecommendation? get _recommendation {
    return migData[WeldKey(
      material: _selectedMaterial,
      thicknessLabel: _selectedThickness.label,
    )];
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _resultCard(MigRecommendation rec) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Starting Point',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _row('Material', _selectedMaterial.label),
          _row('Thickness', _selectedThickness.label),
          const Divider(),
          _row('Voltage', rec.voltage),
          _row('Wire Speed', rec.wireSpeed),
          _row('Wire Size', rec.wireSize),
          _row('Gas', rec.shieldingGas),
          _row('Polarity', rec.polarity),
          _row('Notes', rec.notes),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rec = _recommendation;

    return TerminalScaffold(
      title: 'MIG Setup Calc',
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'MIG material and thickness calculator',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<WeldMaterial>(
              initialValue: _selectedMaterial,
              decoration: const InputDecoration(
                labelText: 'Material',
                border: OutlineInputBorder(),
              ),
              items: weldMaterials
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedMaterial = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ThicknessOption>(
              initialValue: _selectedThickness,
              decoration: const InputDecoration(
                labelText: 'Thickness',
                border: OutlineInputBorder(),
              ),
              items: weldThicknessOptions
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedThickness = value);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => setState(() {}),
                child: const Text(
                  'RUN CALC',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (rec != null)
              _resultCard(rec)
            else
              const Text('No recommendation found for this combination.'),
          ],
        ),
      ),
    );
  }
}
