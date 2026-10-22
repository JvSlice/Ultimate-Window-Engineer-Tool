import 'package:flutter/material.dart';

import '../../terminal_scaffold.dart';
import 'material_data.dart';
import 'material_models.dart';
import 'material_units.dart';

class MaterialComparisonRow {
  final String label;
  final List<String> values;

  const MaterialComparisonRow({required this.label, required this.values});
}

String materialCategoryLabel(MaterialCategory category) {
  switch (category) {
    case MaterialCategory.steel:
      return 'Steel';
    case MaterialCategory.aluminum:
      return 'Aluminum';
    case MaterialCategory.nonFerrous:
      return 'Non-ferrous';
    case MaterialCategory.plastic:
      return 'Plastic';
    case MaterialCategory.wood:
      return 'Wood';
    case MaterialCategory.masonry:
      return 'Masonry';
  }
}

String weldabilityLabel(WeldabilityRating? rating) {
  switch (rating) {
    case WeldabilityRating.excellent:
      return 'Excellent';
    case WeldabilityRating.good:
      return 'Good';
    case WeldabilityRating.fair:
      return 'Fair';
    case WeldabilityRating.poor:
      return 'Poor';
    case WeldabilityRating.notRecommended:
      return 'Not recommended';
    case null:
      return '-';
  }
}

String formatTempRange(TempRange? range) {
  if (range == null) return '-';

  final hasF = range.minF != null || range.maxF != null;
  final hasC = range.minC != null || range.maxC != null;

  String f = '';
  if (hasF) {
    final a = range.minF?.toString() ?? '-';
    final b = range.maxF?.toString() ?? '-';
    f = '$a-$b F';
  }

  String c = '';
  if (hasC) {
    final a = range.minC?.toString() ?? '-';
    final b = range.maxC?.toString() ?? '-';
    c = '$a-$b C';
  }

  if (hasF && hasC) return '$f / $c';
  if (hasF) return f;
  if (hasC) return c;
  return '-';
}

List<MaterialComparisonRow> buildMaterialComparisonRows(
  List<MaterialSpec> selected,
) {
  final limited = selected.take(3).toList();
  String valueFor(String Function(MaterialSpec material) reader, int index) {
    if (index >= limited.length) return '-';
    return reader(limited[index]);
  }

  List<String> values(String Function(MaterialSpec material) reader) {
    return List.generate(3, (index) => valueFor(reader, index));
  }

  return [
    MaterialComparisonRow(
      label: 'Category',
      values: values((m) => materialCategoryLabel(m.category)),
    ),
    MaterialComparisonRow(
      label: 'Common use',
      values: values((m) => m.commonUse ?? '-'),
    ),
    MaterialComparisonRow(
      label: 'Density (lb/in^3)',
      values: values((m) => fmt6(kgm3ToLbIn3(m.densityKgM3))),
    ),
    MaterialComparisonRow(
      label: 'Density (lb/ft^3)',
      values: values((m) => fmt3(kgm3ToLbFt3(m.densityKgM3))),
    ),
    MaterialComparisonRow(
      label: 'Density (kg/m^3)',
      values: values((m) => fmt3(m.densityKgM3)),
    ),
    MaterialComparisonRow(
      label: 'Thermal expansion',
      values: values(
        (m) => m.thermalExpansionMicroInInF == null
            ? '-'
            : '${m.thermalExpansionMicroInInF!.toStringAsFixed(2)} microin/in/F',
      ),
    ),
    MaterialComparisonRow(
      label: 'Yield strength',
      values: values(
        (m) => m.strength?.yieldPsi == null
            ? '-'
            : '${m.strength!.yieldPsi!.toStringAsFixed(0)} psi',
      ),
    ),
    MaterialComparisonRow(
      label: 'Tensile strength',
      values: values(
        (m) => m.strength?.tensilePsi == null
            ? '-'
            : '${m.strength!.tensilePsi!.toStringAsFixed(0)} psi',
      ),
    ),
    MaterialComparisonRow(
      label: 'Hardness',
      values: values((m) {
        final h = m.hardness;
        if (h == null || h.min == null || h.max == null) return '-';
        return '${h.min!.toStringAsFixed(0)}-${h.max!.toStringAsFixed(0)} ${h.scale ?? ''}'
            .trim();
      }),
    ),
    MaterialComparisonRow(
      label: 'Machinability',
      values: values(
        (m) => m.machining?.machinabilityPercent == null
            ? '-'
            : '${m.machining!.machinabilityPercent}%',
      ),
    ),
    MaterialComparisonRow(
      label: 'SFM notes',
      values: values((m) => m.machining?.sfmNotes ?? '-'),
    ),
    MaterialComparisonRow(
      label: 'Machining notes',
      values: values((m) => m.machining?.notes ?? '-'),
    ),
    MaterialComparisonRow(
      label: 'Weldability',
      values: values((m) => weldabilityLabel(m.weldability)),
    ),
    MaterialComparisonRow(
      label: 'Melting range',
      values: values((m) => formatTempRange(m.melting)),
    ),
    MaterialComparisonRow(
      label: 'Material notes',
      values: values((m) => m.notes ?? '-'),
    ),
  ];
}

class MaterialComparePage extends StatefulWidget {
  const MaterialComparePage({super.key});

  @override
  State<MaterialComparePage> createState() => _MaterialComparePageState();
}

class _MaterialComparePageState extends State<MaterialComparePage> {
  late MaterialSpec firstMaterial;
  late MaterialSpec secondMaterial;
  late MaterialSpec thirdMaterial;

  List<MaterialSpec> get _sortedMaterials {
    return [...materials]..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  void initState() {
    super.initState();
    final list = _sortedMaterials;
    firstMaterial = list.firstWhere(
      (m) => m.name.contains('6061'),
      orElse: () => list[0],
    );
    secondMaterial = list.firstWhere(
      (m) => m.name.contains('1018'),
      orElse: () => list.length > 1 ? list[1] : list[0],
    );
    thirdMaterial = list.firstWhere(
      (m) => m.name.contains('Brass'),
      orElse: () => list.length > 2 ? list[2] : list[0],
    );
  }

  Widget _selector({
    required Color accent,
    required String label,
    required MaterialSpec value,
    required ValueChanged<MaterialSpec> onChanged,
  }) {
    final items = _sortedMaterials;

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
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: 0.6), width: 2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MaterialSpec>(
              value: value,
              isExpanded: true,
              dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
              iconEnabledColor: accent,
              style: TextStyle(color: accent),
              items: items.map((material) {
                return DropdownMenuItem(
                  value: material,
                  child: Text(
                    material.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: accent),
                  ),
                );
              }).toList(),
              onChanged: (material) {
                if (material == null) return;
                onChanged(material);
              },
            ),
          ),
        ),
      ],
    );
  }

  TableRow _tableRow({
    required Color accent,
    required List<String> cells,
    bool header = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: header
            ? accent.withValues(alpha: 0.14)
            : Theme.of(context).colorScheme.surfaceContainer,
      ),
      children: cells.map((cell) {
        return Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.centerLeft,
          child: Text(
            cell,
            style: TextStyle(
              color: accent,
              fontWeight: header ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final selected = [firstMaterial, secondMaterial, thirdMaterial];
    final rows = buildMaterialComparisonRows(selected);

    return TerminalScaffold(
      title: 'Compare Materials',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Compare up to three centralized material records side-by-side.',
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            _selector(
              accent: accent,
              label: 'Material 1',
              value: firstMaterial,
              onChanged: (value) => setState(() => firstMaterial = value),
            ),
            const SizedBox(height: 12),
            _selector(
              accent: accent,
              label: 'Material 2',
              value: secondMaterial,
              onChanged: (value) => setState(() => secondMaterial = value),
            ),
            const SizedBox(height: 12),
            _selector(
              accent: accent,
              label: 'Material 3',
              value: thirdMaterial,
              onChanged: (value) => setState(() => thirdMaterial = value),
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(color: accent.withValues(alpha: 0.55)),
                defaultColumnWidth: const FixedColumnWidth(220),
                children: [
                  _tableRow(
                    accent: accent,
                    header: true,
                    cells: [
                      'Property',
                      firstMaterial.name,
                      secondMaterial.name,
                      thirdMaterial.name,
                    ],
                  ),
                  ...rows.map(
                    (row) => _tableRow(
                      accent: accent,
                      cells: [row.label, ...row.values],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Values are representative references. Actual material properties vary by alloy, temper, supplier, and condition.',
              style: TextStyle(color: accent.withValues(alpha: 0.65)),
            ),
          ],
        ),
      ),
    );
  }
}
