import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';

class ForkliftLoadCalculatorPage extends StatefulWidget {
  const ForkliftLoadCalculatorPage({super.key});

  @override
  State<ForkliftLoadCalculatorPage> createState() =>
      _ForkliftLoadCalculatorPageState();
}

class _ForkliftLoadCalculatorPageState
    extends State<ForkliftLoadCalculatorPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final TextEditingController _quickRatedCapacityController =
      TextEditingController(text: '9400');
  final TextEditingController _quickRatedLoadCenterController =
      TextEditingController(text: '24');
  final TextEditingController _quickActualLoadCenterController =
      TextEditingController(text: '24');
  final TextEditingController _quickAttachmentWeightController =
      TextEditingController(text: '0');
  final TextEditingController _quickAttachmentShiftController =
      TextEditingController(text: '0');

  final TextEditingController _rowMaxHeightController =
      TextEditingController(text: '189');
  final TextEditingController _rowRatedCapacityController =
      TextEditingController(text: '9400');
  final TextEditingController _rowRatedLoadCenterController =
      TextEditingController(text: '24');

  final TextEditingController _chartActualHeightController =
      TextEditingController(text: '120');
  final TextEditingController _chartActualLoadCenterController =
      TextEditingController(text: '24');
  final TextEditingController _chartAttachmentWeightController =
      TextEditingController(text: '0');
  final TextEditingController _chartAttachmentShiftController =
      TextEditingController(text: '0');

  final List<ForkliftChartRow> _chartRows = [
    const ForkliftChartRow(
      maxHeightIn: 189,
      ratedCapacityLb: 9400,
      ratedLoadCenterIn: 24,
    ),
  ];

  QuickCalcResult? _quickResult;
  ChartCalcResult? _chartResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _runQuickCalc();
    _runChartCalc();
  }

  @override
  void dispose() {
    _tabController.dispose();

    _quickRatedCapacityController.dispose();
    _quickRatedLoadCenterController.dispose();
    _quickActualLoadCenterController.dispose();
    _quickAttachmentWeightController.dispose();
    _quickAttachmentShiftController.dispose();

    _rowMaxHeightController.dispose();
    _rowRatedCapacityController.dispose();
    _rowRatedLoadCenterController.dispose();

    _chartActualHeightController.dispose();
    _chartActualLoadCenterController.dispose();
    _chartAttachmentWeightController.dispose();
    _chartAttachmentShiftController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

    return TerminalScaffold(
      title: 'Forklift Load Calculator',
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(accent, textTheme),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              indicatorColor: accent,
              labelColor: accent,
              unselectedLabelColor: accent.withValues(alpha: 0.65),
              tabs: const [
                Tab(text: 'Quick Calc'),
                Tab(text: 'Plate Builder'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildQuickCalcTab(accent),
                  _buildPlateBuilderTab(accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color accent, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _terminalBox(accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated capacity tool',
            style: textTheme.titleMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Uses a simplified load-moment model.\n'
            'Verify all results against the OEM rating plate and load chart before use.',
            style: textTheme.bodyMedium?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCalcTab(Color accent) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(
            accent: accent,
            title: 'Quick Calc Inputs',
            child: Column(
              children: [
                _numberField(
                  controller: _quickRatedCapacityController,
                  label: 'Rated Capacity (lb)',
                  accent: accent,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: _quickRatedLoadCenterController,
                  label: 'Rated Load Center (in)',
                  accent: accent,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: _quickActualLoadCenterController,
                  label: 'Actual Load Center (in)',
                  accent: accent,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: _quickAttachmentWeightController,
                  label: 'Attachment Weight (lb) [optional]',
                  accent: accent,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: _quickAttachmentShiftController,
                  label: 'Forward CG Shift (in) [optional]',
                  accent: accent,
                ),
                const SizedBox(height: 12),
                _terminalButton(
                  accent: accent,
                  label: 'Run Quick Calc',
                  onPressed: _runQuickCalc,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickResultCard(accent),
          const SizedBox(height: 12),
          _buildReferenceCentersCard(accent),
        ],
      ),
    );
  }

  Widget _buildPlateBuilderTab(Color accent) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(
            accent: accent,
            title: 'Add / Edit Plate Row',
            child: Column(
              children: [
                _numberField(
                  controller: _rowMaxHeightController,
                  label: 'Row Max Height (in)',
                  accent: accent,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: _rowRatedCapacityController,
                  label: 'Row Rated Capacity (lb)',
                  accent: accent,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: _rowRatedLoadCenterController,
                  label: 'Row Rated Load Center (in)',
                  accent: accent,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _terminalButton(
                      accent: accent,
                      label: 'Add Row',
                      onPressed: _addChartRow,
                    ),
                    _terminalButton(
                      accent: accent,
                      label: 'Sort Rows',
                      onPressed: _sortRows,
                    ),
                    _terminalButton(
                      accent: accent,
                      label: 'Clear Rows',
                      onPressed: _clearRowsConfirm,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildChartRowsCard(accent),
          const SizedBox(height: 12),
          _sectionCard(
            accent: accent,
            title: 'Chart Calculation Inputs',
            child: Column(
              children: [
                _numberField(
                  controller: _chartActualHeightController,
                  label: 'Actual Lift Height (in)',
                  accent: accent,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: _chartActualLoadCenterController,
                  label: 'Actual Load Center (in)',
                  accent: accent,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: _chartAttachmentWeightController,
                  label: 'Attachment Weight (lb) [optional]',
                  accent: accent,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: _chartAttachmentShiftController,
                  label: 'Forward CG Shift (in) [optional]',
                  accent: accent,
                ),
                const SizedBox(height: 12),
                _terminalButton(
                  accent: accent,
                  label: 'Run Chart Calc',
                  onPressed: _runChartCalc,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildChartResultCard(accent),
        ],
      ),
    );
  }

  Widget _buildQuickResultCard(Color accent) {
    final result = _quickResult;

    return _sectionCard(
      accent: accent,
      title: 'Quick Calc Result',
      child: result == null
          ? Text('No result yet.', style: TextStyle(color: accent))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _resultLine(
                  accent,
                  'Rated Moment',
                  '${result.ratedMoment.toStringAsFixed(1)} lb-in',
                ),
                _resultLine(
                  accent,
                  'Attachment Penalty Moment',
                  '${result.attachmentPenaltyMoment.toStringAsFixed(1)} lb-in',
                ),
                _resultLine(
                  accent,
                  'Remaining Moment',
                  '${result.remainingMoment.toStringAsFixed(1)} lb-in',
                ),
                const SizedBox(height: 8),
                _resultLine(
                  accent,
                  'Estimated Max Capacity',
                  '${result.estimatedCapacityLb.toStringAsFixed(0)} lb',
                  big: true,
                ),
                const SizedBox(height: 8),
                _resultLine(
                  accent,
                  'Capacity @ 6 ft center',
                  '${result.capacityAt72In.toStringAsFixed(0)} lb',
                ),
                _resultLine(
                  accent,
                  'Capacity @ 7 ft center',
                  '${result.capacityAt84In.toStringAsFixed(0)} lb',
                ),
              ],
            ),
    );
  }

  Widget _buildReferenceCentersCard(Color accent) {
    final ratedCapacity =
        _parseDouble(_quickRatedCapacityController.text) ?? 0.0;
    final ratedCenter =
        _parseDouble(_quickRatedLoadCenterController.text) ?? 0.0;
    final attachWeight =
        _parseDouble(_quickAttachmentWeightController.text) ?? 0.0;
    final attachShift =
        _parseDouble(_quickAttachmentShiftController.text) ?? 0.0;

    final points = <int>[24, 30, 36, 42, 48, 60, 72, 84];
    final ratedMoment = ratedCapacity * ratedCenter;
    final penaltyMoment = attachWeight * attachShift;
    final remainingMoment = math.max(0.0, ratedMoment - penaltyMoment);

    return _sectionCard(
      accent: accent,
      title: 'Reference Capacity Table',
      child: Column(
        children: points.map((center) {
          final capacity =
              center <= 0 ? 0.0 : math.max(0.0, remainingMoment / center);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$center in load center',
                    style: TextStyle(color: accent),
                  ),
                ),
                Text(
                  '${capacity.toStringAsFixed(0)} lb',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartRowsCard(Color accent) {
    return _sectionCard(
      accent: accent,
      title: 'Stored Plate Rows',
      child: _chartRows.isEmpty
          ? Text('No rows added.', style: TextStyle(color: accent))
          : Column(
              children: List.generate(_chartRows.length, (index) {
                final row = _chartRows[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: _terminalBox(accent),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Row ${index + 1}\n'
                          'Max Height: ${row.maxHeightIn.toStringAsFixed(0)} in\n'
                          'Rated Capacity: ${row.ratedCapacityLb.toStringAsFixed(0)} lb\n'
                          'Rated Load Center: ${row.ratedLoadCenterIn.toStringAsFixed(0)} in',
                          style: TextStyle(color: accent),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _chartRows.removeAt(index);
                          });
                          _runChartCalc();
                        },
                        icon: Icon(Icons.delete_outline, color: accent),
                        tooltip: 'Delete row',
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildChartResultCard(Color accent) {
    final result = _chartResult;

    return _sectionCard(
      accent: accent,
      title: 'Chart Calculation Result',
      child: result == null
          ? Text('No result yet.', style: TextStyle(color: accent))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.selectedRow != null) ...[
                  _resultLine(
                    accent,
                    'Selected Row Max Height',
                    '${result.selectedRow!.maxHeightIn.toStringAsFixed(0)} in',
                  ),
                  _resultLine(
                    accent,
                    'Selected Row Rated Capacity',
                    '${result.selectedRow!.ratedCapacityLb.toStringAsFixed(0)} lb',
                  ),
                  _resultLine(
                    accent,
                    'Selected Row Rated Load Center',
                    '${result.selectedRow!.ratedLoadCenterIn.toStringAsFixed(0)} in',
                  ),
                  const SizedBox(height: 8),
                ],
                if (result.warningMessage != null) ...[
                  Text(
                    result.warningMessage!,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _resultLine(
                  accent,
                  'Estimated Max Capacity',
                  '${result.estimatedCapacityLb.toStringAsFixed(0)} lb',
                  big: true,
                ),
                const SizedBox(height: 8),
                _resultLine(
                  accent,
                  'Rated Moment Used',
                  '${result.ratedMoment.toStringAsFixed(1)} lb-in',
                ),
                _resultLine(
                  accent,
                  'Attachment Penalty Moment',
                  '${result.attachmentPenaltyMoment.toStringAsFixed(1)} lb-in',
                ),
                _resultLine(
                  accent,
                  'Remaining Moment',
                  '${result.remainingMoment.toStringAsFixed(1)} lb-in',
                ),
              ],
            ),
    );
  }

  Widget _sectionCard({
    required Color accent,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _terminalBox(accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required Color accent,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: accent),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: accent),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }

  Widget _terminalButton({
    required Color accent,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: accent),
        foregroundColor: accent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _resultLine(
    Color accent,
    String label,
    String value, {
    bool big = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: big ? 16 : 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: big ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _terminalBox(Color accent) {
    return BoxDecoration(
      border: Border.all(color: accent),
      borderRadius: BorderRadius.circular(8),
    );
  }

  void _runQuickCalc() {
    final ratedCapacity =
        _parseDouble(_quickRatedCapacityController.text) ?? 0.0;
    final ratedLoadCenter =
        _parseDouble(_quickRatedLoadCenterController.text) ?? 0.0;
    final actualLoadCenter =
        _parseDouble(_quickActualLoadCenterController.text) ?? 0.0;
    final attachmentWeight =
        _parseDouble(_quickAttachmentWeightController.text) ?? 0.0;
    final attachmentShift =
        _parseDouble(_quickAttachmentShiftController.text) ?? 0.0;

    final result = _calculateCapacity(
      ratedCapacityLb: ratedCapacity,
      ratedLoadCenterIn: ratedLoadCenter,
      actualLoadCenterIn: actualLoadCenter,
      attachmentWeightLb: attachmentWeight,
      attachmentForwardShiftIn: attachmentShift,
    );

    setState(() {
      _quickResult = QuickCalcResult(
        ratedMoment: result.ratedMoment,
        attachmentPenaltyMoment: result.attachmentPenaltyMoment,
        remainingMoment: result.remainingMoment,
        estimatedCapacityLb: result.estimatedCapacityLb,
        capacityAt72In:
            result.remainingMoment <= 0 ? 0 : result.remainingMoment / 72.0,
        capacityAt84In:
            result.remainingMoment <= 0 ? 0 : result.remainingMoment / 84.0,
      );
    });
  }

  void _runChartCalc() {
    if (_chartRows.isEmpty) {
      setState(() {
        _chartResult = const ChartCalcResult(
          selectedRow: null,
          ratedMoment: 0,
          attachmentPenaltyMoment: 0,
          remainingMoment: 0,
          estimatedCapacityLb: 0,
          warningMessage: 'No chart rows available. Add at least one row.',
        );
      });
      return;
    }

    final actualHeight =
        _parseDouble(_chartActualHeightController.text) ?? 0.0;
    final actualLoadCenter =
        _parseDouble(_chartActualLoadCenterController.text) ?? 0.0;
    final attachmentWeight =
        _parseDouble(_chartAttachmentWeightController.text) ?? 0.0;
    final attachmentShift =
        _parseDouble(_chartAttachmentShiftController.text) ?? 0.0;

    final selected = _selectRowForHeight(actualHeight);

    if (selected == null) {
      final tallest = _chartRows
          .map((e) => e.maxHeightIn)
          .fold<double>(0, (a, b) => math.max(a, b));

      setState(() {
        _chartResult = ChartCalcResult(
          selectedRow: null,
          ratedMoment: 0,
          attachmentPenaltyMoment: 0,
          remainingMoment: 0,
          estimatedCapacityLb: 0,
          warningMessage:
              'Requested height exceeds all entered chart rows. Tallest row is ${tallest.toStringAsFixed(0)} in.',
        );
      });
      return;
    }

    final calc = _calculateCapacity(
      ratedCapacityLb: selected.ratedCapacityLb,
      ratedLoadCenterIn: selected.ratedLoadCenterIn,
      actualLoadCenterIn: actualLoadCenter,
      attachmentWeightLb: attachmentWeight,
      attachmentForwardShiftIn: attachmentShift,
    );

    setState(() {
      _chartResult = ChartCalcResult(
        selectedRow: selected,
        ratedMoment: calc.ratedMoment,
        attachmentPenaltyMoment: calc.attachmentPenaltyMoment,
        remainingMoment: calc.remainingMoment,
        estimatedCapacityLb: calc.estimatedCapacityLb,
        warningMessage: null,
      );
    });
  }

  void _addChartRow() {
    final maxHeight = _parseDouble(_rowMaxHeightController.text);
    final ratedCapacity = _parseDouble(_rowRatedCapacityController.text);
    final ratedLoadCenter = _parseDouble(_rowRatedLoadCenterController.text);

    if (maxHeight == null || ratedCapacity == null || ratedLoadCenter == null) {
      _showSnack('Enter valid row values.');
      return;
    }

    if (maxHeight <= 0 || ratedCapacity <= 0 || ratedLoadCenter <= 0) {
      _showSnack('All row values must be greater than zero.');
      return;
    }

    setState(() {
      _chartRows.add(
        ForkliftChartRow(
          maxHeightIn: maxHeight,
          ratedCapacityLb: ratedCapacity,
          ratedLoadCenterIn: ratedLoadCenter,
        ),
      );
      _chartRows.sort((a, b) => a.maxHeightIn.compareTo(b.maxHeightIn));
    });

    _runChartCalc();
  }

  void _sortRows() {
    setState(() {
      _chartRows.sort((a, b) => a.maxHeightIn.compareTo(b.maxHeightIn));
    });
    _runChartCalc();
  }

  void _clearRowsConfirm() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final accent = Theme.of(context).colorScheme.primary;
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Clear all rows?',
            style: TextStyle(color: accent),
          ),
          content: Text(
            'This will remove all stored chart rows.',
            style: TextStyle(color: accent),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: accent)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _chartRows.clear();
                });
                Navigator.of(context).pop();
                _runChartCalc();
              },
              child: Text('Clear', style: TextStyle(color: accent)),
            ),
          ],
        );
      },
    );
  }

  ForkliftChartRow? _selectRowForHeight(double actualHeightIn) {
    final rows = [..._chartRows]
      ..sort((a, b) => a.maxHeightIn.compareTo(b.maxHeightIn));

    for (final row in rows) {
      if (actualHeightIn <= row.maxHeightIn) {
        return row;
      }
    }
    return null;
  }

  _MomentCalcResult _calculateCapacity({
    required double ratedCapacityLb,
    required double ratedLoadCenterIn,
    required double actualLoadCenterIn,
    required double attachmentWeightLb,
    required double attachmentForwardShiftIn,
  }) {
    if (ratedCapacityLb <= 0 ||
        ratedLoadCenterIn <= 0 ||
        actualLoadCenterIn <= 0) {
      return const _MomentCalcResult(
        ratedMoment: 0,
        attachmentPenaltyMoment: 0,
        remainingMoment: 0,
        estimatedCapacityLb: 0,
      );
    }

    final ratedMoment = ratedCapacityLb * ratedLoadCenterIn;
    final attachmentPenaltyMoment =
        math.max(0.0, attachmentWeightLb) *
        math.max(0.0, attachmentForwardShiftIn);
    final remainingMoment = math.max(0.0, ratedMoment - attachmentPenaltyMoment);
    final estimatedCapacityLb =
        math.max(0.0, remainingMoment / actualLoadCenterIn);

    return _MomentCalcResult(
      ratedMoment: ratedMoment,
      attachmentPenaltyMoment: attachmentPenaltyMoment,
      remainingMoment: remainingMoment,
      estimatedCapacityLb: estimatedCapacityLb,
    );
  }

  double? _parseDouble(String text) {
    return double.tryParse(text.trim());
  }

  void _showSnack(String message) {
    final accent = Theme.of(context).colorScheme.primary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          message,
          style: TextStyle(color: accent),
        ),
      ),
    );
  }
}

class ForkliftChartRow {
  const ForkliftChartRow({
    required this.maxHeightIn,
    required this.ratedCapacityLb,
    required this.ratedLoadCenterIn,
  });

  final double maxHeightIn;
  final double ratedCapacityLb;
  final double ratedLoadCenterIn;
}

class QuickCalcResult {
  const QuickCalcResult({
    required this.ratedMoment,
    required this.attachmentPenaltyMoment,
    required this.remainingMoment,
    required this.estimatedCapacityLb,
    required this.capacityAt72In,
    required this.capacityAt84In,
  });

  final double ratedMoment;
  final double attachmentPenaltyMoment;
  final double remainingMoment;
  final double estimatedCapacityLb;
  final double capacityAt72In;
  final double capacityAt84In;
}

class ChartCalcResult {
  const ChartCalcResult({
    required this.selectedRow,
    required this.ratedMoment,
    required this.attachmentPenaltyMoment,
    required this.remainingMoment,
    required this.estimatedCapacityLb,
    required this.warningMessage,
  });

  final ForkliftChartRow? selectedRow;
  final double ratedMoment;
  final double attachmentPenaltyMoment;
  final double remainingMoment;
  final double estimatedCapacityLb;
  final String? warningMessage;
}

class _MomentCalcResult {
  const _MomentCalcResult({
    required this.ratedMoment,
    required this.attachmentPenaltyMoment,
    required this.remainingMoment,
    required this.estimatedCapacityLb,
  });

  final double ratedMoment;
  final double attachmentPenaltyMoment;
  final double remainingMoment;
  final double estimatedCapacityLb;
}
