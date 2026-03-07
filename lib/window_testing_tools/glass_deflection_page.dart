import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

class GlassDeflectionPage extends StatefulWidget {
  const GlassDeflectionPage({super.key});

  @override
  State<GlassDeflectionPage> createState() => _GlassDeflectionPageState();
}

class _GlassDeflectionPageState extends State<GlassDeflectionPage> {
  // L/175 inputs
  final spanCtrl = TextEditingController(text: "");
  final measuredDeflectionCtrl = TextEditingController(text: "");

  // Permanent set inputs
  final permanentSetCtrl = TextEditingController(text: "");

  double? allowableDeflection;
  double? measuredDeflection;
  bool? deflectionPass;

  double? allowablePermanentSet;
  double? measuredPermanentSet;
  bool? permanentSetPass;

  String? warning;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final span = _p(spanCtrl);
    final defl = _p(measuredDeflectionCtrl);
    final perm = _p(permanentSetCtrl);

    setState(() {
      allowableDeflection = null;
      measuredDeflection = null;
      deflectionPass = null;

      allowablePermanentSet = null;
      measuredPermanentSet = null;
      permanentSetPass = null;

      warning = null;

      if (span == null || span <= 0) {
        warning = "Enter a valid span L.";
        return;
      }

      // L/175
      allowableDeflection = span / 175.0;
      measuredDeflection = defl;

      if (defl != null) {
        deflectionPass = defl <= allowableDeflection!;
      }

      // Add warning if L/175 exceeds 0.75"
      if (allowableDeflection! > 0.75) {
        warning =
            'Calculated L/175 allowable exceeds 0.75". Review project / code-specific requirements.';
      }

      // Permanent set = 0.2% of L = 0.002 × L
      allowablePermanentSet = span * 0.002;
      measuredPermanentSet = perm;

      if (perm != null) {
        permanentSetPass = perm <= allowablePermanentSet!;
      }
    });
  }

  @override
  void dispose() {
    spanCtrl.dispose();
    measuredDeflectionCtrl.dispose();
    permanentSetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Glass & Deflection",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            terminalResultCard(
              accent: accent,
              lines: const [
                "ASTM E1300:",
                "Full ASTM E1300 glass load determination is not built into this page yet.",
                "Use this page now for deflection / permanent set checks and add E1300 logic later.",
              ],
            ),

            const SizedBox(height: 16),

            OutlinedButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AstmE1300Page(),
      ),
    );
  },
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: accent, width: 2),
  ),
  child: Text(
    "ASTM E1300 Glass Calculator",
    style: TextStyle(color: accent),
  ),
),
            const SizedBox(height: 16),

            Text(
              "Deflection Check",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "Allowable deflection = L / 175",
              style: TextStyle(
                color: accent.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 14),

            terminalNumberField(
              accent: accent,
              label: 'Span L (in)',
              hint: 'Enter span in inches',
              controller: spanCtrl,
            ),
            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: 'Measured Deflection (in)',
              hint: 'Optional measured value',
              controller: measuredDeflectionCtrl,
            ),

            const SizedBox(height: 22),

            Text(
              "Permanent Set Check",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "Allowable permanent set = 0.002 × L",
              style: TextStyle(
                color: accent.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 14),

            terminalNumberField(
              accent: accent,
              label: 'Measured Permanent Set (in)',
              hint: 'Optional measured value',
              controller: permanentSetCtrl,
            ),

            const SizedBox(height: 16),

            terminalCalcButton(
              accent: accent,
              onPressed: _calculate,
            ),

            const SizedBox(height: 18),

            if (warning != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  warning!,
                  style: TextStyle(
                    color: accent.withValues(alpha: 0.90),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            terminalResultCard(
              accent: accent,
              lines: [
                "Allowable Deflection (L/175): ${allowableDeflection == null ? '—' : allowableDeflection!.toStringAsFixed(4)} in",
                "Measured Deflection: ${measuredDeflection == null ? '—' : measuredDeflection!.toStringAsFixed(4)} in",
                "Deflection Result: ${deflectionPass == null ? '—' : (deflectionPass! ? 'PASS' : 'FAIL')}",
              ],
            ),

            const SizedBox(height: 14),

            terminalResultCard(
              accent: accent,
              lines: [
                "Allowable Permanent Set (0.002 × L): ${allowablePermanentSet == null ? '—' : allowablePermanentSet!.toStringAsFixed(4)} in",
                "Measured Permanent Set: ${measuredPermanentSet == null ? '—' : measuredPermanentSet!.toStringAsFixed(4)} in",
                "Permanent Set Result: ${permanentSetPass == null ? '—' : (permanentSetPass! ? 'PASS' : 'FAIL')}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}


