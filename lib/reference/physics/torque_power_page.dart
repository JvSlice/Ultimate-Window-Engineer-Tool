import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

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

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

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

    final force = _p(forceLbfCtrl);
    final armIn = _p(armInCtrl);
    final torqueFromFA_flin = (force == null || armIn == null) ? null : force * armIn;
    final torqueFromFA_ftlb = (torqueFromFA_flin == null) ? null : torqueFromFA_flin / 12.0;

    final torque = _p(torqueFtlbCtrl);
    final rpm = _p(rpmCtrl);

    // HP = (Torque(ft-lb) * RPM) / 5252
    final hp = (torque == null || rpm == null) ? null : (torque * rpm) / 5252.0;

    // W = HP * 745.699872
    final watts = (hp == null) ? null : hp * 745.699872;

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
            terminalNumberField(accent: accent, label: "Force (lbf)", hint: "lbf", controller: forceLbfCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "Lever arm (in)", hint: "in", controller: armInCtrl),
            const SizedBox(height: 14),
            terminalResultCard(
              accent: accent,
              lines: [
                if (torqueFromFA_flin == null) "Torque: —" else "Torque: ${torqueFromFA_flin.toStringAsFixed(2)} in-lb",
                if (torqueFromFA_ftlb == null) "" else "Torque: ${torqueFromFA_ftlb.toStringAsFixed(2)} ft-lb",
              ].where((s) => s.isNotEmpty).toList(),
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
            terminalNumberField(accent: accent, label: "Torque (ft-lb)", hint: "ft-lb", controller: torqueFtlbCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "Speed (RPM)", hint: "rpm", controller: rpmCtrl),
            const SizedBox(height: 14),
            terminalResultCard(
              accent: accent,
              lines: [
                if (hp == null) "Horsepower: —" else "Horsepower: ${hp.toStringAsFixed(3)} HP",
                if (watts == null) "Watts: —" else "Watts: ${watts.toStringAsFixed(1)} W",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
