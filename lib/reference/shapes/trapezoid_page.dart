import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

class TrapezoidPage extends StatefulWidget {
  const TrapezoidPage({super.key});

  @override
  State<TrapezoidPage> createState() => _TrapezoidPageState();
}

class _TrapezoidPageState extends State<TrapezoidPage> {
  final aCtrl = TextEditingController(text: "10");
  final bCtrl = TextEditingController(text: "6");
  final hCtrl = TextEditingController(text: "4");

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void dispose() {
    aCtrl.dispose();
    bCtrl.dispose();
    hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final a = _p(aCtrl);
    final b = _p(bCtrl);
    final h = _p(hCtrl);

    final area = (a == null || b == null || h == null) ? null : ((a + b) / 2.0) * h;

    return TerminalScaffold(
      title: "Trapezoid",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formula:\nA = ((a + b) / 2) × h",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            terminalNumberField(accent: accent, label: "Base a", hint: "units", controller: aCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "Base b", hint: "units", controller: bCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "Height (h)", hint: "units", controller: hCtrl),
            const SizedBox(height: 18),
            terminalResultCard(
              accent: accent,
              lines: [
                if (area == null) "Area (A): —" else "Area (A): ${area.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
