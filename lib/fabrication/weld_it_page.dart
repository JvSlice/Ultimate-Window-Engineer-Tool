import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart'; // for terminalResultCard if you want it
import 'stick_rods_page.dart';
import 'tig_tungsten_page.dart';
import 'shielding_gas_page.dart';

class WeldItPage extends StatelessWidget {
  const WeldItPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    Widget terminalNavButton(String label, VoidCallback onPressed) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: BorderSide(color: accent, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(accent.withValues(alpha: 0.08)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: "Weld It",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Quick welding reference tools.\nPick a topic:",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),

            terminalNavButton("Stick (SMAW) Rods: type • size • amps", () {
              _open(context, const StickRodsPage());
            }),
            const SizedBox(height: 12),

            terminalNavButton("TIG Tungsten: type • size • best use", () {
              _open(context, const TigTungstenPage());
            }),
            const SizedBox(height: 12),

            terminalNavButton("Shielding Gas: type • application", () {
              _open(context, const ShieldingGasPage());
            }),
          ],
        ),
      ),
    );
  }
}
