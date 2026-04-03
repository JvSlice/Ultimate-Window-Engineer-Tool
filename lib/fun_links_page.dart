import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'terminal_scaffold.dart';

class FunLinksPage extends StatelessWidget {
  const FunLinksPage({super.key});

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open: $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    Widget funButton(String label, String url) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: OutlinedButton(
          onPressed: () => _openLink(context, url),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: accent, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w800),
                ),
              ),
              Icon(Icons.open_in_new, color: accent),
            ],
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
              "Other projects, games, and experiments.",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            funButton(
              "Revenge of the Wookiee",
              "https://jvslice.github.io/Revenge-Of-The-Wookiee/",
            ),
            funButton(
              "Flight Fight",
              "https://jvslice.github.io/Flight_Fight/",
            ),
            funButton(
              "Holo Chess / Dejarik",
              "https://jvslice.github.io/HoloChess/",
            ),
          ],
        ),
      ),
    );
  }
}
