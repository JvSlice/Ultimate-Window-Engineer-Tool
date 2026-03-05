import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class GasItem {
  final String gas;
  final String process;
  final String bestFor;
  final String notes;

  const GasItem({
    required this.gas,
    required this.process,
    required this.bestFor,
    required this.notes,
  });
}

const List<GasItem> gasGuide = [
  GasItem(
    gas: "100% CO₂",
    process: "MIG (GMAW)",
    bestFor: "Steel • deep penetration • budget setups",
    notes: "More spatter. Good for thicker steel. Typical flow ~20–30 CFH (setup dependent).",
  ),
  GasItem(
    gas: "75/25 Argon/CO₂",
    process: "MIG (GMAW)",
    bestFor: "Steel • clean bead • general shop work",
    notes: "Most common for MIG steel. Lower spatter than straight CO₂.",
  ),
  GasItem(
    gas: "100% Argon",
    process: "TIG (GTAW) • MIG aluminum",
    bestFor: "Aluminum • TIG all-around",
    notes: "Standard TIG gas. Also used for MIG aluminum (spool gun).",
  ),
  GasItem(
    gas: "Tri-Mix (He/Ar/CO₂)",
    process: "MIG stainless",
    bestFor: "Stainless MIG",
    notes: "Improves wetting and bead shape. More expensive.",
  ),
  GasItem(
    gas: "Argon/Helium Mix",
    process: "TIG aluminum (sometimes)",
    bestFor: "Thicker aluminum • hotter arc",
    notes: "Helium increases heat input; useful on thick sections.",
  ),
];

class ShieldingGasPage extends StatelessWidget {
  const ShieldingGasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    Widget gasCard(GasItem g) {
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
              g.gas,
              style: TextStyle(color: accent, fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text("Process: ${g.process}", style: TextStyle(color: accent.withValues(alpha: 0.85))),
            const SizedBox(height: 6),
            Text("Best for: ${g.bestFor}", style: TextStyle(color: accent.withValues(alpha: 0.85))),
            const SizedBox(height: 6),
            Text("Notes: ${g.notes}", style: TextStyle(color: accent.withValues(alpha: 0.75))),
          ],
        ),
      );
    }

    return TerminalScaffold(
      title: "Shielding Gas Guide",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Quick reference for common shop gases.\n"
              "We can add flow-rate tips and material-specific picks later.",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            for (final g in gasGuide) ...[
              gasCard(g),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}
