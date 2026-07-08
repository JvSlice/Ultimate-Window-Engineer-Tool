import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import 'ohms_law_page.dart';
import 'power_law_page.dart';
import 'eletrical_reference_page.dart';
import 'voltage_divider_page.dart';
import 'battery_runtime_page.dart';
import 'awg_reference_page.dart';
import 'appliance_power_reference_page.dart';

class ElectricalToolsPage extends StatelessWidget {
  const ElectricalToolsPage({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final accent = Theme.of(context).colorScheme.primary;

    Widget terminalButton(
      BuildContext context,
      String label,
      VoidCallback onPressed,
    ) {
      return SizedBox(
        width: double.infinity,
        height: size.height * 0.11,
        child: OutlinedButton(
          onPressed: onPressed,
          style:
              OutlinedButton.styleFrom(
                backgroundColor: accent.withValues(alpha: 0.10),
                foregroundColor: accent,
                side: BorderSide(color: accent, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  accent.withValues(alpha: 0.18),
                ),
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: 'Electrical Tools',
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(size.width * 0.05),
          children: [
            terminalButton(
              context,
              'Ohm’s Law Calculator',
              () => openPage(context, const OhmsLawPage()),
            ),
            const SizedBox(height: 12),
            terminalButton(
              context,
              'Power Law Calculator',
              () => openPage(context, const PowerLawPage()),
            ),
            const SizedBox(height: 12),
            terminalButton(
              context,
              'Voltage Divider Calculator',
              () => openPage(context, const VoltageDividerPage()),
            ),
            const SizedBox(height: 12),
            terminalButton(
              context,
              'Battery Runtime Estimator',
              () => openPage(context, const BatteryRuntimePage()),
            ),
            const SizedBox(height: 12),
            terminalButton(
              context,
              'AWG Quick Reference',
              () => openPage(context, const AwgReferencePage()),
            ),
            const SizedBox(height: 12),
            terminalButton(
              context,
              'Common Appliance Power Usage',
              () => openPage(context, const AppliancePowerReferencePage()),
            ),
            const SizedBox(height: 12),
            terminalButton(
              context,
              'Electrical Reference',
              () => openPage(context, const ElectricalReferencePage()),
            ),
            const SizedBox(height: 18),
            Text(
              'Quick electrical math and reference tools for design, shop, and field use.',
              textAlign: TextAlign.center,
              style: TextStyle(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
