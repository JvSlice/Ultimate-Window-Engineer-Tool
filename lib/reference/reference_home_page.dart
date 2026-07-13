import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';
import 'physics_equations_page.dart';
import 'geometry_page.dart';
import 'materials/material_reference_page.dart';
import 'eletrical_tools/eletrical_tools_page.dart';
import 'forklift_load_calculator_page.dart';
import 'forklift_suspended_boom_calculator_page.dart';
import 'fastener_torque_chart_page.dart';
import 'rigging/rigging_home_page.dart';

class ReferenceHomePage extends StatelessWidget {
  const ReferenceHomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final accent = Theme.of(context).colorScheme.primary;

    Widget terminalButton(String label, VoidCallback onPressed) {
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: accent,
              ),
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: "Reference It",
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          terminalButton("Physics Equations", () {
            _open(context, const PhysicsEquationsPage());
          }),
          const SizedBox(height: 14),
          terminalButton("Geometry", () {
            _open(context, const GeometryPage());
          }),
          const SizedBox(height: 14),
          terminalButton("Material Properties", () {
            _open(context, const MaterialReferencePage());
          }),
          const SizedBox(height: 14),
          terminalButton("Electrical Tools", () {
            _open(context, const ElectricalToolsPage());
          }),
          const SizedBox(height: 14),
          terminalButton("Fork Lift Load Calculator", () {
            _open(context, const ForkliftLoadCalculatorPage());
          }),
          const SizedBox(height: 14),
          terminalButton("Fork Lift Suspended Boom Calculator", () {
            _open(context, const ForkliftSuspendedBoomCalculatorPage());
          }),
          const SizedBox(height: 14),
          terminalButton("Rigging Tools", () {
            _open(context, const RiggingHomePage());
          }),
          const SizedBox(height: 14),
          terminalButton("Fastener Torque Chart", () {
            _open(context, const FastenerTorqueChartPage());
          }),
        ],
      ),
    );
  }
}
