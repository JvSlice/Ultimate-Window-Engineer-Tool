import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../terminal_scaffold.dart';
import 'fastener_layout_calculator.dart';

enum TestBuckType { single, double }

extension TestBuckTypeLabel on TestBuckType {
  String get label {
    switch (this) {
      case TestBuckType.single:
        return 'Single Buck';
      case TestBuckType.double:
        return 'Double Buck';
    }
  }
}

class TestBuckCalculation {
  final double horizontalCut;
  final double verticalCut;
  final double doubleHorizontalCut;
  final double doubleVerticalCut;
  final double outsideWidth;
  final double outsideHeight;
  final double crossMeasureOutside;
  final double crossMeasureInside;
  final double doubleCrossMeasureOutside;

  const TestBuckCalculation({
    required this.horizontalCut,
    required this.verticalCut,
    required this.doubleHorizontalCut,
    required this.doubleVerticalCut,
    required this.outsideWidth,
    required this.outsideHeight,
    required this.crossMeasureOutside,
    required this.crossMeasureInside,
    required this.doubleCrossMeasureOutside,
  });
}

TestBuckCalculation calculateTestBuck({
  required double unitWidth,
  required double unitHeight,
  required double caulkJoint,
  required double materialThickness,
}) {
  final horizontalCut = unitWidth + (caulkJoint * 2) + (2 * materialThickness);
  final doubleHorizontalCut = horizontalCut + (2 * materialThickness);

  final verticalCut = unitHeight + (caulkJoint * 2);
  final doubleVerticalCut = verticalCut + (2 * materialThickness);

  return TestBuckCalculation(
    horizontalCut: horizontalCut,
    verticalCut: verticalCut,
    doubleHorizontalCut: doubleHorizontalCut,
    doubleVerticalCut: doubleVerticalCut,
    outsideWidth: horizontalCut,
    outsideHeight: verticalCut + (2 * materialThickness),
    crossMeasureOutside: sqrt(
      (horizontalCut * horizontalCut) +
          (verticalCut * verticalCut + (2 * materialThickness)),
    ),
    crossMeasureInside: sqrt(
      ((unitHeight + (caulkJoint * 2)) * (unitHeight + (caulkJoint * 2))) +
          ((unitWidth + caulkJoint) * (unitWidth + caulkJoint)),
    ),
    doubleCrossMeasureOutside: sqrt(
      (doubleHorizontalCut * doubleHorizontalCut) +
          (doubleVerticalCut * doubleVerticalCut + (2 * materialThickness)),
    ),
  );
}

class TestBuckCalculatorPage extends StatefulWidget {
  const TestBuckCalculatorPage({super.key});

  @override
  State<TestBuckCalculatorPage> createState() => _TestBuckCalculatorPageState();
}

class _TestBuckCalculatorPageState extends State<TestBuckCalculatorPage> {
  // ==========================================================
  // HACKABLE DEFAULTS
  // Change these if you want different startup values later.
  // ==========================================================
  static const double _defaultUnitWidth = 36.0;
  static const double _defaultUnitHeight = 60.0;
  static const double _defaultCaulkJoint = 0.50;
  static const double _defaultMaterialThickness = 1.50;

  late final TextEditingController _unitWidthController;
  late final TextEditingController _unitHeightController;
  late final TextEditingController _caulkJointController;
  late final TextEditingController _materialThicknessController;

  TestBuckType _selectedBuckType = TestBuckType.single;

  @override
  void initState() {
    super.initState();

    _unitWidthController = TextEditingController(
      text: _formatNumber(_defaultUnitWidth),
    );
    _unitHeightController = TextEditingController(
      text: _formatNumber(_defaultUnitHeight),
    );
    _caulkJointController = TextEditingController(
      text: _formatNumber(_defaultCaulkJoint),
    );
    _materialThicknessController = TextEditingController(
      text: _formatNumber(_defaultMaterialThickness),
    );

    _unitWidthController.addListener(_onInputChanged);
    _unitHeightController.addListener(_onInputChanged);
    _caulkJointController.addListener(_onInputChanged);
    _materialThicknessController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _unitWidthController.dispose();
    _unitHeightController.dispose();
    _caulkJointController.dispose();
    _materialThicknessController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {});
  }

  double _readDouble(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0.0;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    final text = value.toStringAsFixed(3);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _resetDefaults() {
    _unitWidthController.text = _formatNumber(_defaultUnitWidth);
    _unitHeightController.text = _formatNumber(_defaultUnitHeight);
    _caulkJointController.text = _formatNumber(_defaultCaulkJoint);
    _materialThicknessController.text = _formatNumber(
      _defaultMaterialThickness,
    );
  }

  bool _hasValidUnitDimensions() {
    return _readDouble(_unitWidthController) > 0 &&
        _readDouble(_unitHeightController) > 0;
  }

  void _openFastenerLayout() {
    if (!_hasValidUnitDimensions()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FastenerLayoutCalculatorPage(
          initialWidth: _readDouble(_unitWidthController),
          initialHeight: _readDouble(_unitHeightController),
          sourceMessage: 'Loaded dimensions from Test Buck Calculator.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    final unitWidth = _readDouble(_unitWidthController);
    final unitHeight = _readDouble(_unitHeightController);
    final caulkJoint = _readDouble(_caulkJointController);
    final materialThickness = _readDouble(_materialThicknessController);

    final calculation = calculateTestBuck(
      unitWidth: unitWidth,
      unitHeight: unitHeight,
      caulkJoint: caulkJoint,
      materialThickness: materialThickness,
    );

    return TerminalScaffold(
      title: 'Test Buck Calculator',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buckTypeCard(context),
              const SizedBox(height: 16),
              _inputCard(
                context,
                title: 'Inputs',
                children: [
                  _numberField(
                    label: 'Unit Width',
                    controller: _unitWidthController,
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    label: 'Unit Height',
                    controller: _unitHeightController,
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    label: 'Caulk Joint inches per side',
                    controller: _caulkJointController,
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    label: 'Material Thickness',
                    controller: _materialThicknessController,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _terminalActionButton(
                        context: context,
                        label: 'Reset Defaults',
                        onPressed: _resetDefaults,
                      ),
                      _terminalActionButton(
                        context: context,
                        label: 'Open Fastener Layout',
                        onPressed: _hasValidUnitDimensions()
                            ? _openFastenerLayout
                            : null,
                      ),

                      // ======================================================
                      // TEMPLATE BUTTON SLOT
                      // Copy one of these for future simple calculators.
                      // Uncomment and change label/onPressed when needed.
                      // ======================================================
                      /*
                      _terminalActionButton(
                        context: context,
                        label: 'Another Action',
                        onPressed: () {
                          // Add custom action here.
                        },
                      ),
                      */
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._resultCards(context, calculation),
              const SizedBox(height: 16),
              _infoCard(
                context,
                title: 'Notes',
                child: Text(
                  'Important:\n'
                  'Widths Always Run Full\n'
                  'Version 1.4',
                  style: TextStyle(color: accent, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buckTypeCard(BuildContext context) {
    return _inputCard(
      context,
      title: 'Buck Type',
      children: [
        Row(
          children: [
            _buckTypeButton(TestBuckType.single),
            const SizedBox(width: 12),
            _buckTypeButton(TestBuckType.double),
          ],
        ),
      ],
    );
  }

  Widget _buckTypeButton(TestBuckType type) {
    final accent = Theme.of(context).colorScheme.primary;
    final selected = _selectedBuckType == type;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedBuckType = type;
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 2),
          backgroundColor: selected
              ? accent.withValues(alpha: 0.15)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(type.label, textAlign: TextAlign.center),
      ),
    );
  }

  List<Widget> _resultCards(
    BuildContext context,
    TestBuckCalculation calculation,
  ) {
    switch (_selectedBuckType) {
      case TestBuckType.single:
        return _singleBuckResultCards(context, calculation);
      case TestBuckType.double:
        return _doubleBuckResultCards(context, calculation);
    }
  }

  List<Widget> _singleBuckResultCards(
    BuildContext context,
    TestBuckCalculation calculation,
  ) {
    return [
      _outputCard(
        context,
        title: 'Single Buck Lumber Cut Sizes',
        rows: [
          _outputRow('Top Piece', _formatNumber(calculation.horizontalCut)),
          _outputRow('Bottom Piece', _formatNumber(calculation.horizontalCut)),
          _outputRow('Left Side', _formatNumber(calculation.verticalCut)),
          _outputRow('Right Side', _formatNumber(calculation.verticalCut)),
        ],
      ),
      const SizedBox(height: 16),
      _outputCard(
        context,
        title: 'Single Buck Quick Summary',
        rows: [
          _outputRow('2x Horizontal', _formatNumber(calculation.horizontalCut)),
          _outputRow('2x Vertical', _formatNumber(calculation.verticalCut)),
          _outputRow('Outside Width', _formatNumber(calculation.outsideWidth)),
          _outputRow(
            'Outside Height',
            _formatNumber(calculation.outsideHeight),
          ),
          _outputRow(
            'Cross Measure Reference Outside',
            _formatNumber(calculation.crossMeasureOutside),
          ),
          _outputRow(
            'Cross Measure Reference Inside',
            _formatNumber(calculation.crossMeasureInside),
          ),
        ],
      ),
    ];
  }

  List<Widget> _doubleBuckResultCards(
    BuildContext context,
    TestBuckCalculation calculation,
  ) {
    return [
      _outputCard(
        context,
        title: 'Inner Buck Lumber Cut Sizes',
        rows: [
          _outputRow(
            'Inner Buck Top Piece',
            _formatNumber(calculation.horizontalCut),
          ),
          _outputRow(
            'Inner Buck Bottom Piece',
            _formatNumber(calculation.horizontalCut),
          ),
          _outputRow(
            'Inner Buck Left Side',
            _formatNumber(calculation.verticalCut),
          ),
          _outputRow(
            'Inner Buck Right Side',
            _formatNumber(calculation.verticalCut),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _outputCard(
        context,
        title: 'Outer Buck Lumber Cut Sizes',
        rows: [
          _outputRow(
            'Outer Buck Top Piece',
            _formatNumber(calculation.doubleHorizontalCut),
          ),
          _outputRow(
            'Outer Buck Bottom Piece',
            _formatNumber(calculation.doubleHorizontalCut),
          ),
          _outputRow(
            'Outer Buck Left Side',
            _formatNumber(calculation.doubleVerticalCut),
          ),
          _outputRow(
            'Outer Buck Right Side',
            _formatNumber(calculation.doubleVerticalCut),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _outputCard(
        context,
        title: 'Double Buck Quick Summary',
        rows: [
          _outputRow(
            '2x Inner Buck Horizontal',
            _formatNumber(calculation.horizontalCut),
          ),
          _outputRow(
            '2x Inner Buck Vertical',
            _formatNumber(calculation.verticalCut),
          ),
          _outputRow(
            '2x Outer Buck Horizontal',
            _formatNumber(calculation.doubleHorizontalCut),
          ),
          _outputRow(
            '2x Outer Buck Vertical',
            _formatNumber(calculation.doubleVerticalCut),
          ),
          _outputRow(
            'Inner Buck Cross Measure Reference Outside',
            _formatNumber(calculation.crossMeasureOutside),
          ),
          _outputRow(
            'Inner Buck Cross Measure Reference Inside',
            _formatNumber(calculation.crossMeasureInside),
          ),
          _outputRow(
            'Outer Buck Cross Measure Reference Outside',
            _formatNumber(calculation.doubleCrossMeasureOutside),
          ),
        ],
      ),
    ];
  }

  Widget _infoCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: accent),
        borderRadius: BorderRadius.circular(12),
      ),
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
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _inputCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return _infoCard(
      context,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _outputCard(
    BuildContext context, {
    required String title,
    required List<Widget> rows,
  }) {
    return _infoCard(
      context,
      title: title,
      child: Column(children: rows),
    );
  }

  Widget _outputRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _terminalActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final accent = Theme.of(context).colorScheme.primary;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: accent),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }
}

//import 'test_buck_calculator_page.dart';
//terminalButton(
//context,
//'Test Buck Calculator',
//() => openPage(context, const TestBuckCalculatorPage()),
//),
