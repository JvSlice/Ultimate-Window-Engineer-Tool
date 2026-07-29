import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

class RatingReferencePage extends StatelessWidget {
  const RatingReferencePage({super.key});

  Widget _ratingCard({
    required Color accent,
    required String title,
    required String useCase,
    required String notes,
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
          const SizedBox(height: 8),
          Text(
            "Typical use:",
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            useCase,
            style: TextStyle(
              color: accent.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Notes:",
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            notes,
            style: TextStyle(
              color: accent.withValues(alpha: 0.78),
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
      title: "Rating Reference",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            terminalResultCard(
              accent: accent,
              lines: const [
                "Important:",
                "Performance class should not be assigned from PSF alone.",
                "Class depends on product type, gateway size, test results, and standard requirements.",
                "The below references are based on the AAMA 101/A440-22",
                "Intended for reference only besure to check offical documents for latest details",
              ],
            ),

            const SizedBox(height: 16),

            Text(
              "Performance Class Overview",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),

            _ratingCard(
              accent: accent,
              title: "R",
              useCase:
                  "Residential-style products and lighter-duty applications.",
              notes:
                  "Used where loading, size, and duty expectations are lower. Generally the lightest performance class in the set.\n"
                  "ASD/DP: 15.04 PSF\n"
                  "Deflection: Report Only\n"
                  "Structural Pressure (Overload): 22.56 PSF\n"
                  "Water(minimum):2.92 PSF\n"
                  "Water performace is 15% of ASD/DP\n"
                  "Air: +/- 1.57 PSF Allowed .3 cfm/sqft \n"
                  "Gateway Sizes(inches):\n"
                  "Fixed:\n"
                  "Awings,Hopers,Projected:\n"
                  "Casement:\n"
                  "dual Action (tilt turn):\n"
                  "Slding Window:\n"
                  "Sliding Door:\n"
                  "Terrace Door: Not available",

            ),

            _ratingCard(
              accent: accent,
              title: "LC",
              useCase:
                  "Light commercial applications and heavier-duty residential conditions.",
              notes:
                  "Typically used when the product needs more strength and durability than basic residential class products.\n"
                  "ASD/DP: 25.06 PSF\n"
                  "Deflection: Report Only\n"
                  "Structural Pressure (Overload): 37.59 PSF\n"
                  "Water(Minimum):3.76 PSF\n"
                  "Water performace is 15% of ASD/DP\n"
                  "Air: +/- 1.57 PSF Allowed .3 cfm/sqft\n "
                  "Gateway Sizes:\n"
                  "Fixed: 55.125 x 55.125\n"
                  "Awings,Hopers,Projected: 47.24 x 31.50\n"
                  "Casement: 31.50 x 59.06\n"
                  "dual Action (tilt turn): 47.24 x 59.06\n"
                  "Slding Window: 70.87 x 55.12\n"
                  "Sliding Door: 86.61 x 82.68\n"
                  "Folding Door: 86.61 x 82.68\n"
                  "Terrace Door: Not available",
            ),

            _ratingCard(
              accent: accent,
              title: "CW",
              useCase:
                  "Commercial window applications with higher structural and performance demands.",
              notes:
                  "Often used for larger products or more demanding building conditions than LC/R classes.\n"
                  "ASD/DP: 30.08 PSF\n"
                  "Deflection: L/175\n"
                  "Structural Pressure (Overload): 45.11 PSF\n"
                  "Water(Minimum):4.59 PSF\n "
                  "Water performace is 20% of ASD/DP\n"
                  "Air: +/- 1.57 PSF Allowed .2 cfm/sqft\n"
                   "Gateway Sizes(inches):\n"
                  "Fixed:59.06 x 59.06\n"
                  "Awings,Hopers,Projected: 47.24 x 31.50\n"
                  "Casement: 31.50 x 59.06\n"
                  "dual Action (tilt turn): 47.24 x 70.87\n"
                  "Slding Window: 70.87 x 59.06\n"
                  "Sliding Door: 94.49 x 82.68\n"
                  "Folding Door: 94.49 x 82.68\n"
                  "Terrace Door:Not available",
            ),


            _ratingCard(
              accent: accent,
              title: "AW",
              useCase:
                  "Architectural window applications with the highest duty expectations in this class group.",
              notes:
                  "Typically tied to more demanding commercial/architectural service conditions, larger sizes, heavier use, and more severe test expectations.\n"
                  "ASD/DP: 40.10 PSF\n"
                  "Deflection: L/175\n"
                  "Structural Pressure (Overload): 60.15 PSF\n"
                  "Water(Minimum):8.15 PSF\n"
                  "Water performace is 20% of ASD/DP\n"
                  "Air:\n"
                  "+ 6.24  PSF (infiltration) Allowed .3 cfm/sqft\n "
                  "-1.57 PSF (exfiltration) Allowed .2 cfm/sqft\n"
                  "Gateway Sizes(inches):\n"
                  "Fixed: 59.06 x 998.43"
                  "Awings,Hopers,Projected: 59.06 x 35.43\n"
                  "Casement:35.43 x 59.06\n"
                  "dual Action (tilt turn): 47.24 x 70.87\n"
                  "Slding Window: 98.43 x 87.74\n"
                  "Sliding Door:122.05 x 94.49\n"
                  "folding Door: Not available\n"
                  "Terrace Door: 47.24 x 95.67",
            ),

            const SizedBox(height: 10),

            Text(
              "What matters besides pressure?",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            terminalResultCard(
              accent: accent,
              lines: const [
                "Performance class depends on more than pressure:",
                "• Product type",
                "• Gateway size",
                "• Structural test performance",
                "• Permanent set / deformation limits",
                "• Water resistance requirements",
                "• Air infiltration requirements",
                "• Other procedural / product-specific requirements",
              ],
            ),

            const SizedBox(height: 14),

            Text(
              "Quick pressure reference",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            terminalResultCard(
              accent: accent,
              lines: const [
                "Helpful reminders:",
                "• Design Pressure (DP) is not the same thing as final class assignment.",
                "• Overload / proof load is commonly based on DP × 1.5.",
                "• Water pressure is often referenced as a percentage of DP depending on spec/test basis.",
                "• Final rating must follow the governing standard and tested configuration.",
              ],
            ),

            const SizedBox(height: 14),

            Text(
              "Recommended use in this app",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            terminalResultCard(
              accent: accent,
              lines: const [
                "Use this page as a class guide, not a class calculator.",
                "Use Structural Test Math for:",
                "• DP ↔ overload",
                "• PSF ↔ water pressure",
                "Use Test Sequence Reference for:",
                "• structural sequence",
                "• air sequence",
                "• water sequence",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
