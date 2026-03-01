import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';
import 'shapes3d/box_page.dart';
import 'shapes3d/cylinder_page.dart';
import 'shapes3d/sphere_page.dart';
import 'shapes3d/cone_page.dart';
import 'shapes3d/pipe_page.dart';

class Geometry3DPage extends StatelessWidget {
  const Geometry3DPage({super.key});

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
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: BorderSide(color: accent, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.zero,
          ).copyWith(
            overlayColor: WidgetStateProperty.all(accent.withValues(alpha: 0.08)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              fontSize: size.width * 0.018,
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: "3D Shapes",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            terminalButton("1) Box (Rectangular Prism)", () => _open(context, const BoxPage())),
            const SizedBox(height: 14),
            terminalButton("2) Cylinder", () => _open(context, const CylinderPage())),
            const SizedBox(height: 14),
            terminalButton("3) Sphere", () => _open(context, const SpherePage())),
            const SizedBox(height: 14),
            terminalButton("4) Cone", () => _open(context, const ConePage())),
            const SizedBox(height: 14),
            terminalButton("5) Pipe / Tube", () => _open(context, const PipePage())),
          ],
        ),
      ),
    );
  }
}
