import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '/window_testing_tools/glass_deflection_page.dart';
import 'window_testing_tools/structural_test_math_page.dart';
import '/window_testing_tools/rating_reference_page.dart';
import 'window_testing_tools/test_sequence_reference_page.dart';

class WindowTestingToolsPage extends StatelessWidget {
  const WindowTestingToolsPage({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final size = MediaQuery.of(context).size;

    Widget terminalButton(
      BuildContext context,
      String label,
      VoidCallback onPressed,
    ) {
      return SizedBox(
        width: double.infinity,
        height: size.height * 0.10,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
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
              color: accent,
              fontSize: size.width * 0.018,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: "Window Testing Tools",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Tools and references for structural, water, glass, and rating checks.",
              style: TextStyle(
                color: accent.withValues(alpha: 0.75),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            terminalButton(context, "Glass & Deflection", () {
              openPage(context, const GlassDeflectionPage());
            }),
            const SizedBox(height: 14),

            terminalButton(context, "Structural Test Math", () {
              openPage(context, const StructuralTestMathPage());
            }),
            const SizedBox(height: 14),

            terminalButton(context, "Rating Reference", () {
              openPage(context, const RatingReferencePage());
            }),
            const SizedBox(height: 14),

            terminalButton(context, "Test Sequence Reference", () {
              openPage(context, const TestSequenceReferencePage());
            }),
          ],
        ),
      ),
    );
  }
}
