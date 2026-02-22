import 'package:flutter/material.dart';
import 'terminal_scaffold.dart';
import 'fabrication/drill_index_page.dart';

// import 'drill_tap_selector_page';
// import 'speeds_feeds';

class FabricateItPage extends StatelessWidget {
  const FabricateItPage({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    const accent = Colors.green;
    return const TerminalScaffold(
      title: 'Fabricate it',
      accent: accent,
      child: _FabricateItBody(accent: accent),
    );
  }
}

class _FabricateItBody extends StatelessWidget {
  final Color accent;
  const _FabricateItBody({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TerminalMenuButton(
                accent: accent,
                label: 'Drill Index',
                sublabel: 'Letter / Number / Fractional',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DrillIndexPage()),
                  );
                },
              ),
              const SizedBox(height: 12),

              TerminalMenuButton(
                accent: accent,
                label: 'Drill & Tap Selector',
                sublabel: 'Tap Drill, Clearance, engagement',
                onPressed: () {
                  //Navigator.push(context, MaterialPageRoute(builder: (_) => const DrillTapSelectorPage()));
                },
              ),
              const SizedBox(height: 12),

              TerminalMenuButton(
                accent: accent,
                label: "Speed & Feeds",
                sublabel: "RPM, IPM Calculator",
                onPressed: () {
                  //Navigator.push(context, MaterialPageRoute(builder: (_) => const SpeedFeedPage()));
                },
              ),

              const Spacer(),
              Opacity(
                opacity: 0.65,
                child: Text(
                  'Fabriaction Tools v0.1',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accent,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TerminalMenuButton extends StatelessWidget {
  final Color accent;
  final String label;
  final String? sublabel;
  final VoidCallback onPressed;

  const TerminalMenuButton({
    super.key,
    required this.accent,
    required this.label,
    required this.onPressed,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: accent, width: 2),
        backgroundColor: accent.withValues(alpha: 0.06),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              fontSize: 16,
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 6),
            Opacity(
              opacity: 0.75,
              child: Text(
                sublabel!,
                style: TextStyle(color: accent, letterSpacing: 1, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
