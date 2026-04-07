import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

class TorquePowerPage extends StatefulWidget {
  const TorquePowerPage({super.key});

  @override
  State<TorquePowerPage> createState() => _TorquePowerPageState();
}

class _TorquePowerPageState extends State<TorquePowerPage> {
  // Torque from force & lever arm
  final forceLbfCtrl = TextEditingController(text: "50");
  final armInCtrl = TextEditingController(text: "12");

  // Power from torque & rpm
  final torqueFtlbCtrl = TextEditingController(text: "50");
  final rpmCtrl = TextEditingController(text: "1750");

  double? torqueInLb;
  double? torqueFtLb;
  double? horsepower;
  double? watts;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final force = _p(forceLbfCtrl);
    final armIn = _p(armInCtrl);

    final torque = _p(torqueFtlbCtrl);
    final rpm = _p(rpmCtrl);

    setState(() {
      torqueInLb = null;
      torqueFtLb = null;
      horsepower = null;
      watts = null;

      if (force != null && armIn != null) {
        torqueInLb = force * armIn;
        torqueFtLb = torqueInLb! / 12.0;
      }

      if (torque != null && rpm != null) {
        horsepower = (torque * rpm) / 5252.0;
        watts = horsepower! * 745.699872;
      }
    });
  }

  @override
  void dispose() {
    forceLbfCtrl.dispose();
    armInCtrl.dispose();
    torqueFtlbCtrl.dispose();
    rpmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Torque & Power",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Torque from force:",
              style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 6),

            Text(
              "T = F × r\n(T in-lb) = lbf × in\n(T ft-lb) = (in-lb) ÷ 12",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),

            const SizedBox(height: 14),

            terminalNumberField(
              accent: accent,
              label: "Force (lbf)",
              hint: "lbf",
              controller: forceLbfCtrl,
            ),

            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Lever arm (in)",
              hint: "in",
              controller: armInCtrl,
            ),

            const SizedBox(height: 14),

            terminalResultCard(
              accent: accent,
              lines: [
                "Torque: ${torqueInLb == null ? '—' : torqueInLb!.toStringAsFixed(2)} in-lb",
                "Torque: ${torqueFtLb == null ? '—' : torqueFtLb!.toStringAsFixed(2)} ft-lb",
              ],
            ),

            const SizedBox(height: 26),

            Text(
              "Power from torque & RPM:",
              style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 6),

            Text(
              "HP = (T × RPM) ÷ 5252\nW = HP × 745.70",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),

            const SizedBox(height: 14),

            terminalNumberField(
              accent: accent,
              label: "Torque (ft-lb)",
              hint: "ft-lb",
              controller: torqueFtlbCtrl,
            ),

            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Speed (RPM)",
              hint: "rpm",
              controller: rpmCtrl,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: terminalCalcButton(
                accent: accent,
                onPressed: _calculate,
              ),
            ),

            const SizedBox(height: 18),

            terminalResultCard(
              accent: accent,
              lines: [
                "Horsepower: ${horsepower == null ? '—' : horsepower!.toStringAsFixed(3)} HP",
                "Watts: ${watts == null ? '—' : watts!.toStringAsFixed(1)} W",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
