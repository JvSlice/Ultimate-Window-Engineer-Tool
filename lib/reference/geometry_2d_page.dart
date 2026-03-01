import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';
import 'shapes/rect_page.dart';
import 'shapes/circle_page.dart';
import 'shapes/right_triangle_page.dart';
import 'shapes/annulus_page.dart';
import 'shapes/trapezoid_page.dart';

class Geometry2DPage extends StatelessWidget {
  const Geometry2DPage({super.key});

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
      title: "2D Shapes",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            terminalButton("1) Rectangle", () => _open(context, const RectPage())),
            const SizedBox(height: 14),
            terminalButton("2) Circle", () => _open(context, const CirclePage())),
            const SizedBox(height: 14),
            terminalButton("3) Right Triangle", () => _open(context, const RightTrianglePage())),
            const SizedBox(height: 14),
            terminalButton("4) Annulus (Ring)", () => _open(context, const AnnulusPage())),
            const SizedBox(height: 14),
            terminalButton("5) Trapezoid", () => _open(context, const TrapezoidPage())),
          ],
        ),
      ),
    );
  }
}
