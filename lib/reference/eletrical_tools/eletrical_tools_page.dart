import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import 'ohms_law_page.dart';
import 'power_law_page.dart';
import 'electrical_reference_page.dart';
import 'voltage_divider_page.dart';
import 'battery_runtime_page.dart';
import 'awg_reference_page.dart';

class ElectricalToolsPage extends StatelessWidget {
  const ElectricalToolsPage({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget terminalButton(
      BuildContext context,
      String label,
      VoidCallback onPressed,
    ) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.010),
        child: SizedBox(
          width: double.infinity,
          height: size.height * 0.085,
          child: OutlinedButton(
            onPressed: onPressed,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.043,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: 'Electrical Tools',
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              terminalButton(
                context,
                'Ohm’s Law Calculator',
                () => openPage(context, const OhmsLawPage()),
              ),
              terminalButton(
                context,
                'Power Law Calculator',
                () => openPage(context, const PowerLawPage()),
              ),
              terminalButton(
                context,
                'Voltage Divider Calculator',
                () => openPage(context, const VoltageDividerPage()),
              ),
              terminalButton(
                context,
                'Battery Runtime Estimator',
                () => openPage(context, const BatteryRuntimePage()),
              ),
              terminalButton(
                context,
                'AWG Quick Reference',
                () => openPage(context, const AwgReferencePage()),
              ),
              terminalButton(
                context,
                'Electrical Reference',
                () => openPage(context, const ElectricalReferencePage()),
              ),
              const Spacer(),
              Text(
                'Quick electrical math and reference tools for design, shop, and field use.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
