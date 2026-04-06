import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';
import 'physics_equations_page.dart';
import 'geometry_page.dart';
import 'materials/material_reference_page.dart';
import 'eletrical_tools/eletrical_reference_page.dart';

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
        height: size.height * 0.10,
        child: OutlinedButton(
          onPressed: onPressed,
          style:
              OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  accent.withValues(alpha: 0.08),
                ),
              ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.018,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: accent,
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: "Reference It",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            terminalButton("Eletrical References", () {
              _open(context, const ElectricalReferencePage());
            }),
          ],
        ),
      ),
    );
  }
}
