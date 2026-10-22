import 'package:flutter/material.dart';

import '../terminal_scaffold.dart';
import '../widgets/terminal_fields.dart';
import 'forge_calculator.dart';

class ForgeCalculatorPage extends StatefulWidget {
  const ForgeCalculatorPage({super.key});

  @override
  State<ForgeCalculatorPage> createState() => _ForgeCalculatorPageState();
}

class _ForgeCalculatorPageState extends State<ForgeCalculatorPage> {
  final _finishedHeight = TextEditingController(text: '0.25');
  final _finishedWidth = TextEditingController(text: '0.25');
  final _finishedLength = TextEditingController(text: '9');
  final _stockHeight = TextEditingController(text: '0.25');
  final _stockWidth = TextEditingController(text: '2');
  final _loss = TextEditingController(text: '10');
  ForgeUnitSystem _units = ForgeUnitSystem.imperial;

  List<TextEditingController> get _dimensions => [
    _finishedHeight,
    _finishedWidth,
    _finishedLength,
    _stockHeight,
    _stockWidth,
  ];

  @override
  void dispose() {
    for (final controller in [..._dimensions, _loss]) {
      controller.dispose();
    }
    super.dispose();
  }

  ForgeResult? get _result {
    final values = _dimensions
        .map((controller) => parseForgeDimension(controller.text, _units))
        .toList();
    final loss = double.tryParse(_loss.text.trim());
    if (values.any((value) => value == null) || loss == null) return null;
    return calculateForgeCutoff(
      finishedHeight: values[0]!,
      finishedWidth: values[1]!,
      finishedLength: values[2]!,
      stockHeight: values[3]!,
      stockWidth: values[4]!,
      lossPercent: loss,
    );
  }

  void _changeUnits(ForgeUnitSystem next) {
    if (next == _units) return;
    final previous = _units;
    for (final controller in _dimensions) {
      final value = parseForgeDimension(controller.text, previous);
      if (value == null || !value.isFinite) continue;
      final converted = convertForgeLength(value, previous, next);
      controller.text = _trim(converted, 8);
    }
    setState(() => _units = next);
  }

  void _reset() {
    _finishedHeight.text = '0.25';
    _finishedWidth.text = '0.25';
    _finishedLength.text = '9';
    _stockHeight.text = '0.25';
    _stockWidth.text = '2';
    _loss.text = '10';
    setState(() => _units = ForgeUnitSystem.imperial);
  }

  String _trim(double value, int places) {
    return value.toStringAsFixed(places).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _length(double value) {
    final decimal = '${_trim(value, 3)} ${_units.lengthUnit}';
    if (_units == ForgeUnitSystem.metric) return decimal;
    return '$decimal  (≈ ${formatForgeFraction(value)} in, nearest 1/64)';
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final result = _result;
    final unit = _units.lengthUnit;

    return TerminalScaffold(
      title: 'Forge Calculator',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Find the starting stock cutoff length for a rectangular forging.',
            style: TextStyle(color: accent),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (final system in ForgeUnitSystem.values)
                ChoiceChip(
                  label: Text(
                    system == ForgeUnitSystem.imperial
                        ? 'Imperial (in)'
                        : 'Metric (mm)',
                  ),
                  selected: _units == system,
                  selectedColor: accent.withValues(alpha: 0.2),
                  side: BorderSide(color: accent),
                  labelStyle: TextStyle(color: accent),
                  onSelected: (_) => _changeUnits(system),
                ),
            ],
          ),
          const SizedBox(height: 18),
          _heading('Finished material', accent),
          _field('Height / thickness ($unit)', _finishedHeight, accent),
          _field('Width ($unit)', _finishedWidth, accent),
          _field('Length ($unit)', _finishedLength, accent),
          const SizedBox(height: 14),
          _heading('Starting stock', accent),
          _field('Height / thickness ($unit)', _stockHeight, accent),
          _field('Width ($unit)', _stockWidth, accent),
          const SizedBox(height: 14),
          _heading('Allowance', accent),
          _field('Material loss (%)', _loss, accent, isLoss: true),
          const SizedBox(height: 8),
          Text(
            'Loss can be 0% through less than 100%. '
            'Inch dimensions accept decimals or fractions such as 1/4 and 1 1/2.',
            style: TextStyle(color: accent.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent),
              ),
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(height: 20),
          _heading('Results', accent),
          if (result == null)
            terminalResultCard(
              accent: accent,
              lines: const [
                'Enter positive dimensions and a material loss from 0% to less than 100%.',
              ],
            )
          else
            terminalResultCard(
              accent: accent,
              lines: [
                'Theoretical cutoff length: ${_length(result.theoreticalLength)}',
                'Recommended cutoff length: ${_length(result.recommendedLength)}',
                'Additional length for loss: ${_length(result.additionalLength)}',
                'Finished material volume: ${_trim(result.finishedVolume, 3)} ${_units.volumeUnit}',
              ],
            ),
          const SizedBox(height: 18),
          _heading('Engineering notes', accent),
          Text(
            'Assumes a rectangular cross-section, uniform material, and constant volume '
            'before material loss. Finished volume = height × width × length. '
            'Theoretical cutoff = finished volume ÷ starting stock area. '
            'Recommended cutoff = theoretical cutoff ÷ (1 − loss % ÷ 100).\n\n'
            'Actual forging results depend on scale loss, trimming, and forging technique. '
            'Fractional-inch values are approximate display values; use the decimal result for precision.',
            style: TextStyle(color: accent, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _heading(String text, Color accent) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: TextStyle(
        color: accent,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller,
    Color accent, {
    bool isLoss = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: terminalNumberField(
      accent: accent,
      label: label,
      hint: isLoss ? '%' : _units.lengthUnit,
      controller: controller,
      keyboardType: !isLoss && _units == ForgeUnitSystem.imperial
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
    ),
  );
}
