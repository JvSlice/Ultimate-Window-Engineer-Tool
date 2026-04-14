import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';

class ForkliftSuspendedBoomCalculatorPage extends StatefulWidget {
  const ForkliftSuspendedBoomCalculatorPage({super.key});

  @override
  State<ForkliftSuspendedBoomCalculatorPage> createState() =>
      _ForkliftSuspendedBoomCalculatorPageState();
}

class _ForkliftSuspendedBoomCalculatorPageState
    extends State<ForkliftSuspendedBoomCalculatorPage> {
  // ============================================================
  // RATED PLATE / HEIGHT ROW INPUTS
  // ============================================================
  final TextEditingController _rowMaxHeightController =
      TextEditingController(text: '189');
  final TextEditingController _rowRatedCapacityController =
      TextEditingController(text: '9400');
  final TextEditingController _rowRatedLoadCenterController =
      TextEditingController(text: '24');

  final List<ForkliftBoomChartRow> _chartRows = [
    const ForkliftBoomChartRow(
      maxHeightIn: 189,
      ratedCapacityLb: 9400,
      ratedLoadCenterIn: 24,
    ),
  ];

  // ============================================================
  // LIVE CALC INPUTS
  // ============================================================
  final TextEditingController _actualLiftHeightController =
      TextEditingController(text: '120');

  final TextEditingController _boomWeightController =
      TextEditingController(text: '500');
  final TextEditingController _boomCgForwardController =
      TextEditingController(text: '24');

  final TextEditingController _hookHorizontalReachController =
      TextEditingController(text: '36');

  final TextEditingController _hoistRiggingWeightController =
      TextEditingController(text: '100');

  final TextEditingController _suspendedLoadWeightController =
      TextEditingController(text: '1000');

  final TextEditingController _verticalDropController =
      TextEditingController(text: '24');

  SuspendedBoomCalcResult? _result;

  @override
  void initState() {
    super.initState();
    _runCalc();
  }

  @override
  void dispose() {
    _rowMaxHeightController.dispose();
    _rowRatedCapacityController.dispose();
    _rowRatedLoadCenterController.dispose();

    _actualLiftHeightController.dispose();
    _boomWeightController.dispose();
    _boomCgForwardController.dispose();
    _hookHorizontalReachController.dispose();
    _hoistRiggingWeightController.dispose();
    _suspendedLoadWeightController.dispose();
    _verticalDropController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

    return TerminalScaffold(
      title: 'Forklift Suspended Boom',
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(accent, textTheme),
              const SizedBox(height: 12),
              _buildCalcInputsCard(accent),
              const SizedBox(height: 12),
              _buildPlateRowBuilderCard(accent),
              const SizedBox(height: 12),
              _buildStoredRowsCard(accent),
              const SizedBox(height: 12),
              _buildResultCard(accent),
            ],
          ),
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
            'Suspended load / mini-crane estimate',
            style: textTheme.titleMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This page estimates forward moment for a forklift using a rated boom with a hoist or suspended load.\n'
            'Static forward moment is driven mainly by horizontal reach.\n'
            'Vertical drop is tracked for reference and warnings only in this version.\n'
            'Always verify against OEM data, boom ratings, and site safety requirements.',
            style: textTheme.bodyMedium?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcInputsCard(Color accent) {
    return _sectionCard(
      accent: accent,
      title: 'Suspended Boom Inputs',
      child: Column(
        children: [
          _numberField(
            controller: _actualLiftHeightController,
            label: 'Actual Lift Height (in)',
            accent: accent,
          ),
          const SizedBox(height: 10),
          _numberField(
            controller: _boomWeightController,
            label: 'Boom / Attachment Weight (lb)',
            accent: accent,
          ),
          const SizedBox(height: 10),
          _numberField(
            controller: _boomCgForwardController,
            label: 'Boom / Attachment CG Forward (in)',
            accent: accent,
          ),
          const SizedBox(height: 10),
          _numberField(
            controller: _hookHorizontalReachController,
            label: 'Hook Horizontal Reach from Fork Face (in)',
            accent: accent,
          ),
          const SizedBox(height: 10),
          _numberField(
            controller: _hoistRiggingWeightController,
            label: 'Hoist + Hook + Rigging Weight (lb)',
            accent: accent,
          ),
          const SizedBox(height: 10),
          _numberField(
            controller: _suspendedLoadWeightController,
            label: 'Suspended Load Weight (lb)',
            accent: accent,
          ),
          const SizedBox(height: 10),
          _numberField(
            controller: _verticalDropController,
            label: 'Vertical Drop Below Boom Tip (in)',
            accent: accent,
          ),
          const SizedBox(height: 12),
          _terminalButton(
            accent: accent,
            label: 'Run Suspended Boom Calc',
            onPressed: _runCalc,
          ),
        ],
      ),
    );
  }

  Widget _buildPlateRowBuilderCard(Color accent) {
    return _sectionCard(
      accent: accent,
      title: 'Rated Plate Row Builder',
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
    );
  }

  Widget _buildStoredRowsCard(Color accent) {
    return _sectionCard(
      accent: accent,
      title: 'Stored Plate Rows',
      child: _chartRows.isEmpty
          ? Text(
              'No rows added.',
              style: TextStyle(color: accent),
            )
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
                          _runCalc();
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

  Widget _buildResultCard(Color accent) {
    final result = _result;

    return _sectionCard(
      accent: accent,
      title: 'Result',
      child: result == null
          ? Text(
              'No result yet.',
              style: TextStyle(color: accent),
            )
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
                _resultLine(
                  accent,
                  'Hook Horizontal Reach',
                  '${result.hookHorizontalReachIn.toStringAsFixed(1)} in',
                ),
                _resultLine(
                  accent,
                  'Vertical Drop Below Boom Tip',
                  '${result.verticalDropBelowBoomTipIn.toStringAsFixed(1)} in',
                ),
                const SizedBox(height: 8),
                _resultLine(
                  accent,
                  'Rated Moment',
                  '${result.ratedMoment.toStringAsFixed(1)} lb-in',
                ),
                _resultLine(
                  accent,
                  'Boom Moment',
                  '${result.boomMoment.toStringAsFixed(1)} lb-in',
                ),
                _resultLine(
                  accent,
                  'Rigging Moment',
                  '${result.riggingMoment.toStringAsFixed(1)} lb-in',
                ),
                _resultLine(
                  accent,
                  'Load Moment',
                  '${result.loadMoment.toStringAsFixed(1)} lb-in',
                ),
                _resultLine(
                  accent,
                  'Total Used Moment',
                  '${result.totalUsedMoment.toStringAsFixed(1)} lb-in',
                  big: true,
                ),
                _resultLine(
                  accent,
                  'Remaining Moment',
                  '${result.remainingMoment.toStringAsFixed(1)} lb-in',
                ),
                const SizedBox(height: 8),
                _resultLine(
                  accent,
                  'Max Allowable Suspended Load',
                  '${result.maxAllowableLoadLb.toStringAsFixed(0)} lb',
                  big: true,
                ),
                _resultLine(
                  accent,
                  'Entered Suspended Load',
                  '${result.enteredLoadWeightLb.toStringAsFixed(0)} lb',
                ),
                _resultLine(
                  accent,
                  'Status',
                  result.isWithinMoment
                      ? 'WITHIN ESTIMATED MOMENT'
                      : 'OVER ESTIMATED MOMENT',
                  big: true,
                ),
                if (result.warningMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    result.warningMessage!,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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

  void _runCalc() {
    final actualHeight =
        _parseDouble(_actualLiftHeightController.text) ?? 0.0;
    final boomWeight =
        _parseDouble(_boomWeightController.text) ?? 0.0;
    final boomCgForward =
        _parseDouble(_boomCgForwardController.text) ?? 0.0;
    final hookReach =
        _parseDouble(_hookHorizontalReachController.text) ?? 0.0;
    final hoistRiggingWeight =
        _parseDouble(_hoistRiggingWeightController.text) ?? 0.0;
    final loadWeight =
        _parseDouble(_suspendedLoadWeightController.text) ?? 0.0;
    final verticalDrop =
        _parseDouble(_verticalDropController.text) ?? 0.0;

    if (_chartRows.isEmpty) {
      setState(() {
        _result = const SuspendedBoomCalcResult(
          selectedRow: null,
          hookHorizontalReachIn: 0,
          verticalDropBelowBoomTipIn: 0,
          ratedMoment: 0,
          boomMoment: 0,
          riggingMoment: 0,
          loadMoment: 0,
          totalUsedMoment: 0,
          remainingMoment: 0,
          maxAllowableLoadLb: 0,
          enteredLoadWeightLb: 0,
          isWithinMoment: false,
          warningMessage: 'No chart rows available. Add at least one row.',
        );
      });
      return;
    }

    if (hookReach <= 0) {
      _showSnack('Hook horizontal reach must be greater than zero.');
      setState(() {
        _result = null;
      });
      return;
    }

    final selectedRow = _selectRowForHeight(actualHeight);

    if (selectedRow == null) {
      final tallest = _chartRows
          .map((e) => e.maxHeightIn)
          .fold<double>(0, (a, b) => math.max(a, b));

      setState(() {
        _result = SuspendedBoomCalcResult(
          selectedRow: null,
          hookHorizontalReachIn: hookReach,
          verticalDropBelowBoomTipIn: verticalDrop,
          ratedMoment: 0,
          boomMoment: 0,
          riggingMoment: 0,
          loadMoment: 0,
          totalUsedMoment: 0,
          remainingMoment: 0,
          maxAllowableLoadLb: 0,
          enteredLoadWeightLb: loadWeight,
          isWithinMoment: false,
          warningMessage:
              'Requested height exceeds all entered chart rows. Tallest row is ${tallest.toStringAsFixed(0)} in.',
        );
      });
      return;
    }

    final ratedMoment =
        selectedRow.ratedCapacityLb * selectedRow.ratedLoadCenterIn;

    final boomMoment =
        math.max(0.0, boomWeight) * math.max(0.0, boomCgForward);
    final riggingMoment =
        math.max(0.0, hoistRiggingWeight) * math.max(0.0, hookReach);
    final loadMoment =
        math.max(0.0, loadWeight) * math.max(0.0, hookReach);

    final totalUsedMoment = boomMoment + riggingMoment + loadMoment;
    final remainingMomentBeforeLoad = ratedMoment - boomMoment - riggingMoment;
    final maxAllowableLoadLb =
        hookReach > 0 ? math.max(0.0, remainingMomentBeforeLoad / hookReach) : 0.0;

    final isWithinMoment = loadWeight <= maxAllowableLoadLb;

    String? warningMessage;
    if (!isWithinMoment) {
      warningMessage =
          'Entered suspended load exceeds the estimated remaining forward moment at this reach.';
    } else if (verticalDrop > 0) {
      warningMessage =
          'Vertical drop is tracked for reference. Static forward moment is based mainly on horizontal reach, but deeper suspended loads can increase swing and control risk.';
    }

    setState(() {
      _result = SuspendedBoomCalcResult(
        selectedRow: selectedRow,
        hookHorizontalReachIn: hookReach,
        verticalDropBelowBoomTipIn: verticalDrop,
        ratedMoment: ratedMoment,
        boomMoment: boomMoment,
        riggingMoment: riggingMoment,
        loadMoment: loadMoment,
        totalUsedMoment: totalUsedMoment,
        remainingMoment: math.max(0.0, ratedMoment - totalUsedMoment),
        maxAllowableLoadLb: maxAllowableLoadLb,
        enteredLoadWeightLb: loadWeight,
        isWithinMoment: isWithinMoment,
        warningMessage: warningMessage,
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
        ForkliftBoomChartRow(
          maxHeightIn: maxHeight,
          ratedCapacityLb: ratedCapacity,
          ratedLoadCenterIn: ratedLoadCenter,
        ),
      );
      _chartRows.sort((a, b) => a.maxHeightIn.compareTo(b.maxHeightIn));
    });

    _runCalc();
  }

  void _sortRows() {
    setState(() {
      _chartRows.sort((a, b) => a.maxHeightIn.compareTo(b.maxHeightIn));
    });
    _runCalc();
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
                _runCalc();
              },
              child: Text('Clear', style: TextStyle(color: accent)),
            ),
          ],
        );
      },
    );
  }

  ForkliftBoomChartRow? _selectRowForHeight(double actualHeightIn) {
    final rows = [..._chartRows]
      ..sort((a, b) => a.maxHeightIn.compareTo(b.maxHeightIn));

    for (final row in rows) {
      if (actualHeightIn <= row.maxHeightIn) {
        return row;
      }
    }
    return null;
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

class ForkliftBoomChartRow {
  const ForkliftBoomChartRow({
    required this.maxHeightIn,
    required this.ratedCapacityLb,
    required this.ratedLoadCenterIn,
  });

  final double maxHeightIn;
  final double ratedCapacityLb;
  final double ratedLoadCenterIn;
}

class SuspendedBoomCalcResult {
  const SuspendedBoomCalcResult({
    required this.selectedRow,
    required this.hookHorizontalReachIn,
    required this.verticalDropBelowBoomTipIn,
    required this.ratedMoment,
    required this.boomMoment,
    required this.riggingMoment,
    required this.loadMoment,
    required this.totalUsedMoment,
    required this.remainingMoment,
    required this.maxAllowableLoadLb,
    required this.enteredLoadWeightLb,
    required this.isWithinMoment,
    required this.warningMessage,
  });

  final ForkliftBoomChartRow? selectedRow;
  final double hookHorizontalReachIn;
  final double verticalDropBelowBoomTipIn;
  final double ratedMoment;
  final double boomMoment;
  final double riggingMoment;
  final double loadMoment;
  final double totalUsedMoment;
  final double remainingMoment;
  final double maxAllowableLoadLb;
  final double enteredLoadWeightLb;
  final bool isWithinMoment;
  final String? warningMessage;
}
