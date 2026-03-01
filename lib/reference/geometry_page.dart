import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';
import 'geometry_2d_page.dart';
import 'geometry_3d_page.dart';
import 'geometry_shop_page.dart';

class GeometryPage extends StatelessWidget {
  const GeometryPage({super.key});

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
      title: "Geometry",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            terminalButton("2D Shapes", () => _open(context, const Geometry2DPage())),
            const SizedBox(height: 14),
            terminalButton("3D Shapes", () => _open(context, const Geometry3DPage())),
            const SizedBox(height: 14),
            terminalButton("Shop Geometry", () => _open(context, const GeometryShopPage())),
          ],
        ),
      ),
    );
  }
}
