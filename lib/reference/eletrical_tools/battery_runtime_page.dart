import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class BatteryRuntimePage extends StatefulWidget {
  const BatteryRuntimePage({super.key});

  @override
  State<BatteryRuntimePage> createState() => _BatteryRuntimePageState();
}

class _BatteryRuntimePageState extends State<BatteryRuntimePage> {
  final _batteryAhController = TextEditingController();
  final _loadAController = TextEditingController();
  final _usablePercentController = TextEditingController(text: '100');

  String _result = 'Enter battery Ah and load current.';
  String _detail = '';

  @override
  void dispose() {
    _batteryAhController.dispose();
    _loadAController.dispose();
    _usablePercentController.dispose();
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

  String _hoursToHoursMinutes(double hours) {
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();
    return '${wholeHours}h ${minutes}m';
  }

  void _calculate() {
    final batteryAh = _parse(_batteryAhController.text);
    final loadA = _parse(_loadAController.text);
    final usablePercent = _parse(_usablePercentController.text);

    if (batteryAh == null || loadA == null || usablePercent == null) {
      setState(() {
        _result = 'Please fill in all fields.';
        _detail = '';
      });
      return;
    }

    if (batteryAh <= 0 || loadA <= 0) {
      setState(() {
        _result = 'Battery Ah and load current must be greater than 0.';
        _detail = '';
      });
      return;
    }

    if (usablePercent <= 0 || usablePercent > 100) {
      setState(() {
        _result = 'Usable battery percent must be between 0 and 100.';
        _detail = '';
      });
      return;
    }

    // Hackable comment:
    // Runtime = usable battery capacity / load current
    // usable capacity = batteryAh × (usablePercent / 100)
    final usableAh = batteryAh * (usablePercent / 100.0);
    final runtimeHours = usableAh / loadA;

    setState(() {
      _result = 'Estimated runtime calculated.';
      _detail =
          'Battery Capacity = ${_fmt(batteryAh)} Ah\n'
          'Load Current = ${_fmt(loadA)} A\n'
          'Usable Capacity = ${_fmt(usableAh)} Ah\n'
          'Estimated Runtime = ${_fmt(runtimeHours)} hours\n'
          'Approx Time = ${_hoursToHoursMinutes(runtimeHours)}';
    });
  }

  void _clearAll() {
    _batteryAhController.clear();
    _loadAController.clear();
    _usablePercentController.text = '100';

    setState(() {
      _result = 'Enter battery Ah and load current.';
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
      title: 'Battery Runtime',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _inputField('Battery Capacity (Ah)', 'Example: 50', _batteryAhController),
              _inputField('Load Current (A)', 'Example: 5', _loadAController),
              _inputField('Usable Battery (%)', 'Example: 80', _usablePercentController),
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
                      'Runtime (hours) = Usable Ah ÷ Load Current\n\n'
                      'Example:\n'
                      '50 Ah battery at 80% usable = 40 Ah usable\n'
                      '40 Ah ÷ 5 A = 8 hours',
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
