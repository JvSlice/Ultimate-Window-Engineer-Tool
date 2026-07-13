import 'package:flutter/material.dart';

import '../fabrication/thread_data.dart';
import '../terminal_scaffold.dart';

enum FastenerTorqueCondition { dry, lubricated }

extension FastenerTorqueConditionLabel on FastenerTorqueCondition {
  String get label {
    switch (this) {
      case FastenerTorqueCondition.dry:
        return 'Dry / plain';
      case FastenerTorqueCondition.lubricated:
        return 'Lubricated / plated';
    }
  }

  double get nutFactor {
    switch (this) {
      case FastenerTorqueCondition.dry:
        return 0.20;
      case FastenerTorqueCondition.lubricated:
        return 0.15;
    }
  }
}

class FastenerTorqueSize {
  final String label;
  final ThreadSystem system;
  final double diameterIn;
  final double tensileStressAreaIn2;

  const FastenerTorqueSize({
    required this.label,
    required this.system,
    required this.diameterIn,
    required this.tensileStressAreaIn2,
  });
}

class FastenerTorqueGrade {
  final String label;
  final double proofStrengthPsi;
  final String note;

  const FastenerTorqueGrade({
    required this.label,
    required this.proofStrengthPsi,
    required this.note,
  });
}

class FastenerTorqueValue {
  final String size;
  final String system;
  final String grade;
  final double torqueInLb;
  final double torqueFtLb;
  final double torqueNm;

  const FastenerTorqueValue({
    required this.size,
    required this.system,
    required this.grade,
    required this.torqueInLb,
    required this.torqueFtLb,
    required this.torqueNm,
  });
}

const double _preloadFractionOfProof = 0.75;
const double _inchPoundToNm = 0.112985;

List<FastenerTorqueSize> get saeFastenerSizes {
  return [
    ...commonUNC,
    ...commonUNF,
  ].map(fastenerTorqueSizeFromThread).toList();
}

List<FastenerTorqueSize> get metricFastenerSizes {
  return commonMetric.map(fastenerTorqueSizeFromThread).toList();
}

FastenerTorqueSize fastenerTorqueSizeFromThread(ThreadSpec thread) {
  final diameterIn = thread.system == ThreadSystem.metric
      ? thread.major / 25.4
      : thread.major;

  final tensileAreaIn2 = switch (thread.system) {
    ThreadSystem.unc || ThreadSystem.unf =>
      0.7854 *
          (thread.major - (0.9743 / thread.pitchOrTpi)) *
          (thread.major - (0.9743 / thread.pitchOrTpi)),
    ThreadSystem.metric =>
      0.7854 *
          (thread.major - (0.9382 * thread.pitchOrTpi)) *
          (thread.major - (0.9382 * thread.pitchOrTpi)) /
          645.16,
  };

  return FastenerTorqueSize(
    label: thread.label,
    system: thread.system,
    diameterIn: diameterIn,
    tensileStressAreaIn2: tensileAreaIn2,
  );
}

const saeTorqueGrades = <FastenerTorqueGrade>[
  FastenerTorqueGrade(
    label: 'SAE Grade 2',
    proofStrengthPsi: 55000,
    note: 'Low or medium carbon steel reference.',
  ),
  FastenerTorqueGrade(
    label: 'SAE Grade 5',
    proofStrengthPsi: 85000,
    note: 'Medium carbon quenched and tempered steel reference.',
  ),
  FastenerTorqueGrade(
    label: 'SAE Grade 8',
    proofStrengthPsi: 120000,
    note: 'Alloy steel quenched and tempered reference.',
  ),
  FastenerTorqueGrade(
    label: '18-8 Stainless',
    proofStrengthPsi: 65000,
    note: 'General stainless reference. Galling risk varies by lubricant.',
  ),
];

const metricTorqueGrades = <FastenerTorqueGrade>[
  FastenerTorqueGrade(
    label: 'Class 8.8',
    proofStrengthPsi: 580 * 145.038,
    note: 'Metric property class 8.8 reference.',
  ),
  FastenerTorqueGrade(
    label: 'Class 10.9',
    proofStrengthPsi: 830 * 145.038,
    note: 'Metric property class 10.9 reference.',
  ),
  FastenerTorqueGrade(
    label: 'Class 12.9',
    proofStrengthPsi: 970 * 145.038,
    note: 'Metric property class 12.9 reference.',
  ),
];

FastenerTorqueValue calculateFastenerTorqueValue({
  required FastenerTorqueSize size,
  required FastenerTorqueGrade grade,
  required FastenerTorqueCondition condition,
}) {
  final clampLoad =
      size.tensileStressAreaIn2 *
      grade.proofStrengthPsi *
      _preloadFractionOfProof;
  final torqueInLb = condition.nutFactor * size.diameterIn * clampLoad;
  return FastenerTorqueValue(
    size: size.label,
    system: _systemLabel(size.system),
    grade: grade.label,
    torqueInLb: torqueInLb,
    torqueFtLb: torqueInLb / 12.0,
    torqueNm: torqueInLb * _inchPoundToNm,
  );
}

class FastenerTorqueChartPage extends StatefulWidget {
  const FastenerTorqueChartPage({super.key});

  @override
  State<FastenerTorqueChartPage> createState() =>
      _FastenerTorqueChartPageState();
}

class _FastenerTorqueChartPageState extends State<FastenerTorqueChartPage> {
  FastenerTorqueCondition _condition = FastenerTorqueCondition.dry;
  ThreadSystem? _systemFilter;
  String? _gradeFilter;
  final _filterController = TextEditingController();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: 'Fastener Torque Chart',
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _panel(
              context,
              title: 'Reference Basis',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'General reference only. Manufacturer torque, anchor approvals, project specs, and fastener supplier data override this chart.',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Values use T = K x D x F, where K is nut factor, D is nominal diameter, and F is 75% of proof load. Thread sizes are pulled from the Drill & Tap Selector lists. Actual torque changes with thread condition, lubrication, coating, washers, embedment, and joint stiffness.',
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.82),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _conditionButton(FastenerTorqueCondition.dry),
                      const SizedBox(width: 12),
                      _conditionButton(FastenerTorqueCondition.lubricated),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _systemFilterButton('All Threads', null),
                      _systemFilterButton('UNC', ThreadSystem.unc),
                      _systemFilterButton('UNF', ThreadSystem.unf),
                      _systemFilterButton('Metric', ThreadSystem.metric),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _gradeFilter,
                    decoration: const InputDecoration(
                      labelText: 'Grade / Class Filter',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        child: Text('All grades and classes'),
                      ),
                      for (final grade in [
                        ...saeTorqueGrades,
                        ...metricTorqueGrades,
                      ])
                        DropdownMenuItem<String>(
                          value: grade.label,
                          child: Text(grade.label),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _gradeFilter = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _filterController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Search within results',
                      hintText:
                          '1/4-20, M10, grade 8, class 10.9, stainless...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _torqueTable(
              context,
              title: 'Inch Fasteners',
              sizes: saeFastenerSizes,
              grades: saeTorqueGrades,
            ),
            const SizedBox(height: 16),
            _torqueTable(
              context,
              title: 'Metric Fasteners',
              sizes: metricFastenerSizes,
              grades: metricTorqueGrades,
            ),
            const SizedBox(height: 16),
            _panel(
              context,
              title: 'Notes',
              child: Text(
                'Dry/plain uses K = 0.20. Lubricated/plated uses K = 0.15. Stainless fasteners can gall; use supplier guidance and compatible lubricant. Concrete anchors and structural screws require manufacturer-published installation torque.',
                style: TextStyle(color: accent, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _conditionButton(FastenerTorqueCondition condition) {
    final accent = Theme.of(context).colorScheme.primary;
    final selected = _condition == condition;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _condition = condition;
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 2),
          backgroundColor: selected
              ? accent.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: Text(condition.label, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _systemFilterButton(String label, ThreadSystem? system) {
    final accent = Theme.of(context).colorScheme.primary;
    final selected = _systemFilter == system;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _systemFilter = system;
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: accent, width: 2),
        backgroundColor: selected
            ? accent.withValues(alpha: 0.15)
            : Colors.transparent,
      ),
      child: Text(label),
    );
  }

  Widget _torqueTable(
    BuildContext context, {
    required String title,
    required List<FastenerTorqueSize> sizes,
    required List<FastenerTorqueGrade> grades,
  }) {
    final accent = Theme.of(context).colorScheme.primary;
    final rows = _filteredRows(sizes: sizes, grades: grades);
    final tableVisible =
        _systemFilter == null ||
        sizes.any((size) => size.system == _systemFilter);

    if (!tableVisible) return const SizedBox.shrink();

    return _panel(
      context,
      title: '$title - ${_condition.label}',
      child: rows.isEmpty
          ? Text('No matching torque rows.', style: TextStyle(color: accent))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
                dataTextStyle: TextStyle(color: accent),
                columns: const [
                  DataColumn(label: Text('Size')),
                  DataColumn(label: Text('Thread')),
                  DataColumn(label: Text('Grade/Class')),
                  DataColumn(label: Text('in-lb')),
                  DataColumn(label: Text('ft-lb')),
                  DataColumn(label: Text('N·m')),
                ],
                rows: rows.map(_dataRow).toList(),
              ),
            ),
    );
  }

  List<FastenerTorqueValue> _filteredRows({
    required List<FastenerTorqueSize> sizes,
    required List<FastenerTorqueGrade> grades,
  }) {
    final query = _filterController.text.trim().toLowerCase();
    final visibleSizes = _systemFilter == null
        ? sizes
        : sizes.where((size) => size.system == _systemFilter).toList();
    final visibleGrades = _gradeFilter == null
        ? grades
        : grades.where((grade) => grade.label == _gradeFilter).toList();

    final values = [
      for (final size in visibleSizes)
        for (final grade in visibleGrades)
          calculateFastenerTorqueValue(
            size: size,
            grade: grade,
            condition: _condition,
          ),
    ];

    if (query.isEmpty) return values;

    return values.where((value) {
      final searchable = [
        value.size,
        value.system,
        value.grade,
        _condition.label,
        'dry',
        'lubricated',
        'plated',
        'torque',
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  DataRow _dataRow(FastenerTorqueValue value) {
    return DataRow(
      cells: [
        DataCell(Text(value.size)),
        DataCell(Text(value.system)),
        DataCell(Text(value.grade)),
        DataCell(Text(_formatTorque(value.torqueInLb))),
        DataCell(Text(_formatTorque(value.torqueFtLb))),
        DataCell(Text(_formatTorque(value.torqueNm))),
      ],
    );
  }

  Widget _panel(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final accent = Theme.of(context).colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        border: Border.all(color: accent, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

String _formatTorque(double value) {
  if (value >= 100) return value.toStringAsFixed(0);
  if (value >= 10) return value.toStringAsFixed(1);
  return value.toStringAsFixed(2);
}

String _systemLabel(ThreadSystem system) {
  switch (system) {
    case ThreadSystem.unc:
      return 'UNC';
    case ThreadSystem.unf:
      return 'UNF';
    case ThreadSystem.metric:
      return 'Metric';
  }
}
