import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

class RectPage extends StatefulWidget {
  const RectPage({super.key});

  @override
  State<RectPage> createState() => _RectPageState();
}

class _RectPageState extends State<RectPage> {
  final wCtrl = TextEditingController(text: "10");
  final hCtrl = TextEditingController(text: "5");

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void dispose() {
    wCtrl.dispose();
    hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final w = _p(wCtrl);
    final h = _p(hCtrl);

    final area = (w == null || h == null) ? null : w * h;
    final perim = (w == null || h == null) ? null : 2 * (w + h);

    return TerminalScaffold(
      title: "Rectangle",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Formulas:\nA = w × h\nP = 2(w + h)",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            terminalNumberField(accent: accent, label: "Width (w)", hint: "units", controller: wCtrl),
            const SizedBox(height: 12),
            terminalNumberField(accent: accent, label: "Height (h)", hint: "units", controller: hCtrl),
            const SizedBox(height: 18),
            terminalResultCard(
              accent: accent,
              lines: [
                if (area == null) "Area (A): —" else "Area (A): ${area.toStringAsFixed(4)}",
                if (perim == null) "Perimeter (P): —" else "Perimeter (P): ${perim.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
