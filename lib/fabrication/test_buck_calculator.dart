import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../terminal_scaffold.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    final unitWidth = _readDouble(_unitWidthController);
    final unitHeight = _readDouble(_unitHeightController);
    final caulkJoint = _readDouble(_caulkJointController);
    final materialThickness = _readDouble(_materialThicknessController);

    // ==========================================================
    // HACKABLE FORMULAS
    // These are the only lines you need to edit for a new simple
    // calculator page built from this template.
    // ==========================================================
    final horizontalCut =
        unitWidth + (caulkJoint * 2) + (2 * materialThickness);

    final verticalCut = unitHeight + (caulkJoint * 2);

    // Optional extra outputs. Keep, remove, or expand as needed.
    final outsideWidth = horizontalCut;
    final outsideHeight = verticalCut + (2 * materialThickness);
    final crossMeasurseOut = sqrt(
      (horizontalCut * horizontalCut) + (verticalCut * verticalCut),
    );
    final crossMeasurseIn = sqrt(
      ((unitHeight + (caulkJoint * 2)) * (unitHeight + (caulkJoint * 2))) +
          ((unitWidth + caulkJoint) * (unitWidth + caulkJoint)),
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
                    label: 'Caulk Joint',
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
              _outputCard(
                context,
                title: 'Lumber Cut Sizes',
                rows: [
                  _outputRow('Top Piece', _formatNumber(horizontalCut)),
                  _outputRow('Bottom Piece', _formatNumber(horizontalCut)),
                  _outputRow('Left Side', _formatNumber(verticalCut)),
                  _outputRow('Right Side', _formatNumber(verticalCut)),
                ],
              ),
              const SizedBox(height: 16),
              _outputCard(
                context,
                title: 'Quick Summary',
                rows: [
                  _outputRow('2x Horizontal', _formatNumber(horizontalCut)),
                  _outputRow('2x Vertical', _formatNumber(verticalCut)),
                  _outputRow('Outside Width', _formatNumber(outsideWidth)),
                  _outputRow('Outside Height', _formatNumber(outsideHeight)),
                  _outputRow(
                    "Cross Measure Reference Outside",
                    _formatNumber(crossMeasurseOut),
                  ),
                  _outputRow(
                    "Cross Measure Reference Inside",
                    _formatNumber(crossMeasurseIn),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _infoCard(
                context,
                title: 'Notes',
                child: Text(
                  'Important:\n'
                  'Widths Always Run Full',
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
    required VoidCallback onPressed,
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