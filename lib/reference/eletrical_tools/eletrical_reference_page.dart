import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class ElectricalReferencePage extends StatelessWidget {
  const ElectricalReferencePage({super.key});

  Widget refPanel(BuildContext context, String title, String body) {
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.06),
          border: Border.all(color: accent, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(body),
              ],
            ),
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
            refPanel(
              context,
              'Ohm’s Law',
              'Voltage (V) = Current (I) × Resistance (R)\n'
                  'Current (I) = Voltage (V) ÷ Resistance (R)\n'
                  'Resistance (R) = Voltage (V) ÷ Current (I)',
            ),
            refPanel(
              context,
              'Power Law',
              'Power (P) = Voltage (V) × Current (I)\n'
                  'Voltage (V) = Power (P) ÷ Current (I)\n'
                  'Current (I) = Power (P) ÷ Voltage (V)',
            ),
            refPanel(
              context,
              'Voltage Divider',
              'Vout = Vin × (R2 / (R1 + R2))\n'
                  'Use for simple unloaded resistor divider circuits.',
            ),
            refPanel(
              context,
              'Battery Runtime',
              'Runtime (hours) = Usable Ah ÷ Load Current\n'
                  'This is an estimate. Real runtime varies with temperature, chemistry, age, and discharge rate.',
            ),
            refPanel(
              context,
              'Common Units',
              'Voltage = volts (V)\n'
                  'Current = amps (A)\n'
                  'Resistance = ohms (Ω)\n'
                  'Power = watts (W)\n'
                  'Capacity = amp-hours (Ah)',
            ),
            refPanel(
              context,
              'Series Circuits',
              'Current stays the same.\n'
                  'Voltages add.\n'
                  'Resistances add.',
            ),
            refPanel(
              context,
              'Parallel Circuits',
              'Voltage stays the same.\n'
                  'Current splits across branches.\n'
                  'Equivalent resistance decreases.',
            ),
            refPanel(
              context,
              'AWG Reminder',
              'Smaller AWG number means a larger wire.\n'
                  'Larger wire usually means lower resistance and less voltage drop.',
            ),
          ],
        ),
      ),
    );
  }
}
