import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class OhmsLawPage extends StatefulWidget {
  const OhmsLawPage({super.key});

  @override
  State<OhmsLawPage> createState() => _OhmsLawPageState();
}

class _OhmsLawPageState extends State<OhmsLawPage> {
  final _voltageController = TextEditingController();
  final _currentController = TextEditingController();
  final _resistanceController = TextEditingController();

  String _result = 'Enter any two values to solve for the third.';
  String _detail = '';

  @override
  void dispose() {
    _voltageController.dispose();
    _currentController.dispose();
    _resistanceController.dispose();
    super.dispose();
  }

  double? _parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  String _fmt(double value) {
    if (value.abs() >= 1000 || value.abs() < 0.01) {
      return value.toStringAsExponential(4);
    }
    return value.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _calculate() {
    final v = _parse(_voltageController.text);
    final i = _parse(_currentController.text);
    final r = _parse(_resistanceController.text);

    final valuesEntered = [v, i, r].where((e) => e != null).length;

    if (valuesEntered != 2) {
      setState(() {
        _result = 'Please enter exactly two values.';
        _detail = 'Use volts, amps, and ohms.';
      });
      return;
    }

    if ((i != null && i == 0) || (r != null && r == 0)) {
      setState(() {
        _result = 'Current and resistance must be greater than 0 when used as divisors.';
        _detail = '';
      });
      return;
    }

    double solvedV = v ?? 0;
    double solvedI = i ?? 0;
    double solvedR = r ?? 0;

    String solvedFor = '';

    if (v == null && i != null && r != null) {
      solvedV = i * r;
      solvedFor = 'Voltage';
      _voltageController.text = _fmt(solvedV);
    } else if (i == null && v != null && r != null) {
      solvedI = v / r;
      solvedFor = 'Current';
      _currentController.text = _fmt(solvedI);
    } else if (r == null && v != null && i != null) {
      solvedR = v / i;
      solvedFor = 'Resistance';
      _resistanceController.text = _fmt(solvedR);
    }

    final power = solvedV * solvedI;

    setState(() {
      _result = '$solvedFor solved successfully.';
      _detail =
          'V = ${_fmt(solvedV)} V\n'
          'I = ${_fmt(solvedI)} A\n'
          'R = ${_fmt(solvedR)} Ω\n'
          'P = ${_fmt(power)} W';
    });
  }

  void _clearAll() {
    _voltageController.clear();
    _currentController.clear();
    _resistanceController.clear();

    setState(() {
      _result = 'Enter any two values to solve for the third.';
      _detail = '';
    });
  }

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
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
      title: 'Ohm’s Law',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _inputField(
                label: 'Voltage (V)',
                hint: 'Example: 12',
                controller: _voltageController,
              ),
              _inputField(
                label: 'Current (A)',
                hint: 'Example: 2.5',
                controller: _currentController,
              ),
              _inputField(
                label: 'Resistance (Ω)',
                hint: 'Example: 4.8',
                controller: _resistanceController,
              ),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Common formulas:\n'
                      'V = I × R\n'
                      'I = V ÷ R\n'
                      'R = V ÷ I\n'
                      'P = V × I',
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
