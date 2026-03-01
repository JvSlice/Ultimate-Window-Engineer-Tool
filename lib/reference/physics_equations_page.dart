import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';
import 'physics/torque_power_page.dart';
import 'physics/cantilever_beam_page.dart';
import 'physics/pulleys_page.dart';
import 'physics/velocity_page.dart';

class PhysicsEquationsPage extends StatelessWidget {
  const PhysicsEquationsPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final accent = Theme.of(context).colorScheme.primary;

    Widget terminalButton(String label, VoidCallback onPressed) {
      return SizedBox(
        width: double.infinity,
        height: size.height * 0.10,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: BorderSide(color: accent, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.zero,
          ).copyWith(
            overlayColor: WidgetStateProperty.all(accent.withValues(alpha: 0.08)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              fontSize: size.width * 0.018,
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: "Physics (Engineering)",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            terminalButton("Torque & Power", () => _open(context, const TorquePowerPage())),
            const SizedBox(height: 14),
            terminalButton("Cantilever Beam", () => _open(context, const CantileverBeamPage())),
            const SizedBox(height: 14),
            terminalButton("Pulleys (Coming Soon)", () => _open(context, const PulleysPage())),
            const SizedBox(height: 14),
            terminalButton("Velocity & Accel (Coming Soon)", () => _open(context, const VelocityPage())),
          ],
        ),
      ),
    );
  }
}
