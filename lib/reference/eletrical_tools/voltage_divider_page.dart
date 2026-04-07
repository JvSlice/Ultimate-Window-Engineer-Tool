import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class VoltageDividerPage extends StatefulWidget {
  const VoltageDividerPage({super.key});

  @override
  State<VoltageDividerPage> createState() => _VoltageDividerPageState();
}

class _VoltageDividerPageState extends State<VoltageDividerPage> {
  final _vinController = TextEditingController();
  final _r1Controller = TextEditingController();
  final _r2Controller = TextEditingController();

  String _result = 'Enter input voltage, R1, and R2.';
  String _detail = '';

  @override
  void dispose() {
    _vinController.dispose();
    _r1Controller.dispose();
    _r2Controller.dispose();
    super.dispose();
  }

  double? _parse(String text) {
    final value = text.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }

  String _fmt(double value) {
    if (value.abs() >= 1000 || (value.abs() < 0.01 && value != 0)) {
      return value.toStringAsExponential(4);
    }
    return value.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _calculate() {
    final vin = _parse(_vinController.text);
    final r1 = _parse(_r1Controller.text);
    final r2 = _parse(_r2Controller.text);

    if (vin == null || r1 == null || r2 == null) {
      setState(() {
        _result = 'Please fill in all fields.';
        _detail = '';
      });
      return;
    }

    if (r1 <= 0 || r2 <= 0) {
      setState(() {
        _result = 'R1 and R2 must be greater than 0.';
        _detail = '';
      });
      return;
    }

    // Hackable comment:
    // Standard unloaded voltage divider:
    // Vout = Vin × (R2 / (R1 + R2))
    final vout = vin * (r2 / (r1 + r2));
    final totalResistance = r1 + r2;
    final dividerCurrent = vin / totalResistance;

    setState(() {
      _result = 'Voltage divider solved.';
      _detail =
          'Vin = ${_fmt(vin)} V\n'
          'R1 = ${_fmt(r1)} Ω\n'
          'R2 = ${_fmt(r2)} Ω\n'
          'Vout = ${_fmt(vout)} V\n'
          'Divider Current = ${_fmt(dividerCurrent)} A\n'
          'Total Resistance = ${_fmt(totalResistance)} Ω';
    });
  }

  void _clearAll() {
    _vinController.clear();
    _r1Controller.clear();
    _r2Controller.clear();

    setState(() {
      _result = 'Enter input voltage, R1, and R2.';
      _detail = '';
    });
  }

  Widget _inputField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TerminalScaffold(
      title: 'Voltage Divider',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _inputField('Input Voltage Vin (V)', 'Example: 12', _vinController),
              _inputField('R1 (Ω)', 'Example: 1000', _r1Controller),
              _inputField('R2 (Ω)', 'Example: 2200', _r2Controller),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _calculate,
                      child: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAll,
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _result,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_detail.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(_detail),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Formula:\n'
                      'Vout = Vin × (R2 / (R1 + R2))\n\n'
                      'This is the ideal unloaded voltage divider.\n'
                      'If you later want, we can add a loaded divider version too.',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
