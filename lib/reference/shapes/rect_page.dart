import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

class RectPage extends StatefulWidget {
  const RectPage({super.key});

  @override
  State<RectPage> createState() => _RectPageState();
}

class _RectPageState extends State<RectPage> {
  final wCtrl = TextEditingController(text: "10");
  final hCtrl = TextEditingController(text: "5");

  double? _area;
  double? _perim;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  void _calculate() {
    final w = _p(wCtrl);
    final h = _p(hCtrl);

    setState(() {
      if (w == null || h == null) {
        _area = null;
        _perim = null;
      } else {
        _area = w * h;
        _perim = 2 * (w + h);
      }
    });
  }

  @override
  void dispose() {
    wCtrl.dispose();
    hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

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

            terminalNumberField(
              accent: accent,
              label: "Width (w)",
              hint: "units",
              controller: wCtrl,
            ),
            const SizedBox(height: 12),

            terminalNumberField(
              accent: accent,
              label: "Height (h)",
              hint: "units",
              controller: hCtrl,
            ),

            const SizedBox(height: 16),

            terminalCalcButton(
              accent: accent,
              onPressed: _calculate,
            ),

            const SizedBox(height: 18),

            terminalResultCard(
              accent: accent,
              lines: [
                "Area (A): ${_area == null ? '—' : _area!.toStringAsFixed(4)}",
                "Perimeter (P): ${_perim == null ? '—' : _perim!.toStringAsFixed(4)}",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
