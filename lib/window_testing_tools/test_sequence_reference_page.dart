import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class TestSequenceReferencePage extends StatelessWidget {
  const TestSequenceReferencePage({super.key});

  Widget sectionCard({
    required Color accent,
    required String title,
    required List<String> steps,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "• $step",
                style: TextStyle(
                  color: accent.withValues(alpha: 0.82),
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Test Sequence Reference",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Quick reference only. Follow the governing standard, lab procedure, and product-specific requirements.",
              style: TextStyle(
                color: accent.withValues(alpha: 0.75),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            sectionCard(
              accent: accent,
              title: "Structural Test Sequence",
              steps: const [
                "Confirm product configuration, size, specimen prep, and instrumentation.",
                "Record span/reference dimensions needed for deflection and permanent set.",
                "Apply design pressure to the required direction and hold per procedure.",
                "Measure and record maximum deflection under load.",
                "Remove load and allow recovery per procedure.",
                "Measure permanent set and compare to allowable limit.",
                "Apply overload / proof load as required.",
                "Inspect for glass breakage, hardware failure, frame damage, disengagement, or other failure.",
                "Document pass/fail for deflection, permanent set, and structural integrity.",
              ],
            ),

            sectionCard(
              accent: accent,
              title: "Water Test Sequence",
              steps: const [
                "Confirm correct test pressure basis and any code/standard cap being used.",
                "Set spray system and chamber conditions per procedure.",
                "Apply water uniformly at required spray rate.",
                "Apply required air pressure differential for the water test.",
                "Observe and document any water penetration at defined failure locations/criteria.",
                "Record pressure used, duration, observations, and pass/fail result.",
              ],
            ),

            sectionCard(
              accent: accent,
              title: "Air Infiltration Sequence",
              steps: const [
                "Prepare specimen and verify sealing / instrumentation.",
                "Set required test pressure differential.",
                "Measure air leakage / infiltration rate.",
                "Compare measured result against applicable limit for the product and standard.",
                "Document setup, pressure, measured leakage, and pass/fail.",
              ],
            ),

            sectionCard(
              accent: accent,
              title: "Deflection / Permanent Set Reminders",
              steps: const [
                "L/175 style checks should use the correct span/reference dimension for the member being evaluated.",
                "Permanent set checks should use the correct percentage limit and measured recovery procedure.",
                "Always document exactly where deflection was measured.",
                "Use consistent units throughout the test record.",
              ],
            ),

            sectionCard(
              accent: accent,
              title: "Rating / Qualification Reminders",
              steps: const [
                "Performance class is not assigned from PSF alone.",
                "Gateway size, product type, and full test results matter.",
                "Structural, water, and air results all need to align with the governing standard.",
                "Use this page as a lab/shop reference, not a substitute for the standard.",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
