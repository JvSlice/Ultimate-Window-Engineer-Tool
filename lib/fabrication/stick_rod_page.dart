import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class StickRod {
  final String rod;
  final String bestFor;
  final String polarity;
  final String notes;
  final Map<String, String> ampsBySize; // "3/32" -> "60–90A"

  const StickRod({
    required this.rod,
    required this.bestFor,
    required this.polarity,
    required this.notes,
    required this.ampsBySize,
  });
}

const List<StickRod> stickRods = [
  StickRod(
    rod: "E6010",
    bestFor: "Root passes • dirty/rusty steel • pipe • deep penetration",
    polarity: "DCEP (DC+), some run DCEN depending rod/brand",
    notes: "Fast-freeze. Usually requires DC machine (not ideal on AC buzzbox).",
    ampsBySize: {
      "3/32": "40–85 A",
      "1/8": "75–125 A",
      "5/32": "110–170 A",
    },
  ),
  StickRod(
    rod: "E6011",
    bestFor: "Similar to 6010 but works on AC • general repair",
    polarity: "AC or DCEP (DC+)",
    notes: "Fast-freeze. Good for less-clean material.",
    ampsBySize: {
      "3/32": "40–90 A",
      "1/8": "75–130 A",
      "5/32": "110–175 A",
    },
  ),
  StickRod(
    rod: "E6013",
    bestFor: "Light fabrication • thin material • nice bead",
    polarity: "AC, DCEN, or DCEP (varies)",
    notes: "Easy rod. Moderate penetration. Good for sheet/clean steel.",
    ampsBySize: {
      "3/32": "60–90 A",
      "1/8": "90–130 A",
      "5/32": "120–180 A",
    },
  ),
  StickRod(
    rod: "E7018",
    bestFor: "Structural • stronger welds • smooth bead",
    polarity: "DCEP (DC+), also available in AC version (7018AC)",
    notes: "Low-hydrogen. Keep dry (rod oven / sealed).",
    ampsBySize: {
      "3/32": "70–110 A",
      "1/8": "100–160 A",
      "5/32": "140–220 A",
    },
  ),
];

class StickRodsPage extends StatelessWidget {
  const StickRodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    Widget cardFor(StickRod r) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent, width: 2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.rod,
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text("Best for: ${r.bestFor}", style: TextStyle(color: accent.withValues(alpha: 0.85))),
            const SizedBox(height: 6),
            Text("Polarity: ${r.polarity}", style: TextStyle(color: accent.withValues(alpha: 0.85))),
            const SizedBox(height: 6),
            Text("Notes: ${r.notes}", style: TextStyle(color: accent.withValues(alpha: 0.75))),
            const SizedBox(height: 10),
            Text("Typical amps (ballpark):", style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            ...r.ampsBySize.entries.map((e) {
              return Text("• ${e.key}: ${e.value}", style: TextStyle(color: accent.withValues(alpha: 0.85)));
            }),
          ],
        ),
      );
    }

    return TerminalScaffold(
      title: "Stick Rods (SMAW)",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Ballpark settings only — machine, joint, position, and technique matter.\n"
              "Use this as a fast starting point.",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            for (final r in stickRods) ...[
              cardFor(r),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}
