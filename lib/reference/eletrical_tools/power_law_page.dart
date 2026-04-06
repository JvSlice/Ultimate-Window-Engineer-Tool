import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class PowerLawPage extends StatefulWidget {
  const PowerLawPage({super.key});

  @override
  State<PowerLawPage> createState() => _PowerLawPageState();
}

class _PowerLawPageState extends State<PowerLawPage> {
  final _powerController = TextEditingController();
  final _voltageController = TextEditingController();
  final _currentController = TextEditingController();

  String _result = 'Enter any two values to solve for the third.';
  String _detail = '';

  @override
  void dispose() {
    _powerController.dispose();
    _voltageController.dispose();
    _currentController.dispose();
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
    final p = _parse(_powerController.text);
    final v = _parse(_voltageController.text);
    final i = _parse(_currentController.text);

    final valuesEntered = [p, v, i].where((e) => e != null).length;

    if (valuesEntered != 2) {
      setState(() {
        _result = 'Please enter exactly two values.';
        _detail = 'Use watts, volts, and amps.';
      });
      return;
    }

    if ((v != null && v == 0) || (i != null && i == 0)) {
      setState(() {
        _result = 'Voltage and current must be greater than 0 when used as divisors.';
        _detail = '';
      });
      return;
    }

    double solvedP = p ?? 0;
    double solvedV = v ?? 0;
    double solvedI = i ?? 0;

    String solvedFor = '';

    if (p == null && v != null && i != null) {
      solvedP = v * i;
      solvedFor = 'Power';
      _powerController.text = _fmt(solvedP);
    } else if (v == null && p != null && i != null) {
      solvedV = p / i;
      solvedFor = 'Voltage';
      _voltageController.text = _fmt(solvedV);
    } else if (i == null && p != null && v != null) {
      solvedI = p / v;
      solvedFor = 'Current';
      _currentController.text = _fmt(solvedI);
    }

    setState(() {
      _result = '$solvedFor solved successfully.';
      _detail =
          'P = ${_fmt(solvedP)} W\n'
          'V = ${_fmt(solvedV)} V\n'
          'I = ${_fmt(solvedI)} A';
    });
  }

  void _clearAll() {
    _powerController.clear();
    _voltageController.clear();
    _currentController.clear();

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
      title: 'Power Law',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _inputField(
                label: 'Power (W)',
                hint: 'Example: 60',
                controller: _powerController,
              ),
              _inputField(
                label: 'Voltage (V)',
                hint: 'Example: 120',
                controller: _voltageController,
              ),
              _inputField(
                label: 'Current (A)',
                hint: 'Example: 0.5',
                controller: _currentController,
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
                      'P = V × I\n'
                      'V = P ÷ I\n'
                      'I = P ÷ V',
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
