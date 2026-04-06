import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class ElectricalReferencePage extends StatelessWidget {
  const ElectricalReferencePage({super.key});

  Widget refCard(BuildContext context, String title, String body) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(body),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TerminalScaffold(
      title: 'Electrical Reference',
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            refCard(
              context,
              'Ohm’s Law',
              'Voltage (V) = Current (I) × Resistance (R)\n'
              'Current (I) = Voltage (V) ÷ Resistance (R)\n'
              'Resistance (R) = Voltage (V) ÷ Current (I)',
            ),
            refCard(
              context,
              'Power Law',
              'Power (P) = Voltage (V) × Current (I)\n'
              'Voltage (V) = Power (P) ÷ Current (I)\n'
              'Current (I) = Power (P) ÷ Voltage (V)',
            ),
            refCard(
              context,
              'Common Units',
              'Voltage = volts (V)\n'
              'Current = amps (A)\n'
              'Resistance = ohms (Ω)\n'
              'Power = watts (W)',
            ),
            refCard(
              context,
              'Series Circuits',
              'Current stays the same.\n'
              'Voltages add.\n'
              'Resistances add.',
            ),
            refCard(
              context,
              'Parallel Circuits',
              'Voltage stays the same.\n'
              'Current splits across branches.\n'
              'Equivalent resistance decreases.',
            ),
            refCard(
              context,
              'Helpful Reminder',
              'For quick field math:\n'
              '12 V × 2 A = 24 W\n'
              '120 V × 0.5 A = 60 W\n'
              '24 V ÷ 6 Ω = 4 A',
            ),
          ],
        ),
      ),
    );
  }
}
