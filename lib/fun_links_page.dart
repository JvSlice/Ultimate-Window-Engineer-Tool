import 'package:flutter/material.dart';
import 'terminal_scaffold.dart';

class FunLinksPage extends StatelessWidget {
  const FunLinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    Widget funButton(String label, String url) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: OutlinedButton(
          onPressed: () {
            // For now this is just a placeholder.
            // Later we can wire this to launch URLs directly.
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: Colors.black,
                title: Text(label, style: TextStyle(color: accent)),
                content: Text(url, style: TextStyle(color: accent)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close", style: TextStyle(color: accent)),
                  ),
                ],
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: accent, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(color: accent, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: "Fun Links",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Other projects, experiments, and games.",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            funButton(
              "Revenge of the Wookiee",
              "https://jvslice.github.io/Revenge-Of-The-Wookiee/",
            ),
            funButton(
              "Empire Flight",
              "https://jvslice.github.io/Empire-Flight/",
            ),
            funButton(
              "Dejarik / Holo Grid",
              "https://jvslice.github.io/Dejarik-Holo-Grid/",
            ),
          ],
        ),
      ),
    );
  }
}
