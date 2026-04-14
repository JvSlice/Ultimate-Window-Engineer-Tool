import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/reference/rigging/hardware_reference_page.dart';
import 'package:ultimate_window_engineer_tool/reference/rigging/hitch_type_reference.dart';
import 'package:ultimate_window_engineer_tool/reference/rigging/sling_angle_reference.dart';
import '../../terminal_scaffold.dart';
import 'rigging_load_calculator_page.dart';
import 'wll_calculator_page.dart';
import 'unequal_load_page.dart';
import 'rigging_cog_estimator_page.dart';
import 'rigging_angle_visualizer_page.dart';

class RiggingHomePage extends StatelessWidget {
  const RiggingHomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget terminalButton({
      required String label,
      required VoidCallback onPressed,
      String? subtitle,
    }) {
      return SizedBox(
        width: double.infinity,
        height: size.height * 0.11,
        child: OutlinedButton(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: 'Rigging Tools',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Rigging calculators and reference tools.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              terminalButton(
                label: 'Rigging Load Calculator',
                subtitle: 'Load / legs / angle / hitch effects',
                onPressed: () =>
                    _open(context, const RiggingLoadCalculatorPage()),
              ),
              const SizedBox(height: 12),

              terminalButton(
                label: 'Working Load Limit',
                subtitle: 'Coming soon',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('WLL calculator coming soon.'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              terminalButton(
                label: 'Hardware Reference',
                subtitle: 'Coming soon',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hardware reference coming soon.'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              terminalButton(
                label: 'Unequal Leg Loading',
                subtitle: 'Coming soon',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unequal leg loading tool coming soon.'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              terminalButton(
                label: 'Working Load Limit',
                subtitle: 'Base WLL, adjusted WLL, and pass/fail',
                onPressed: () =>
                    _open(context, const RiggingWllCalculatorPage()),
              ),
              const SizedBox(height: 12),

              terminalButton(
                label: 'Unequal Loading Calculator',
                subtitle: 'Off-center load and imbalance calculator',
                onPressed: () =>
                    _open(context, const RiggingUnequalLoadingPage()),
              ),
              const SizedBox(height: 12),

              terminalButton(
                label: 'Unequal Loading Calculator',
                subtitle: 'Off-center load and imbalance calculator',
                onPressed: () =>
                    _open(context, const RiggingHitchReferencePage()),
              ),
              const SizedBox(height: 12),

              terminalButton(
                label: 'Rigging Hardware Reference',
                subtitle: 'common hardware used for rigging',
                onPressed: () =>
                    _open(context, const RiggingHardwareReferencePage()),
              ),
              const SizedBox(height: 12),

              terminalButton(
                label: 'Riging Angle Quick reference chart',
                subtitle: 'load factor by angle',
                onPressed: () => _open(context, const RiggingAngleChartPage()),
              ),
              const SizedBox(height: 12),
              terminalButton(
                label: 'COG Estimator',
                subtitle: 'Locate center of gravity',
                onPressed: () => _open(context, const RiggingCOGEstimatorPage()),
                ),
              const SizedBox(height: 12),

              terminalButton(    
                label: 'Angle Visualizer',
                subtitle: 'See angle effect on load',
                onPressed: () => _open(context, const RiggingAngleVisualizerPage()),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
