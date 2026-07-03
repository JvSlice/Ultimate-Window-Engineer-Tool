import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../terminal_scaffold.dart';
import 'release_notes_parser.dart';
import 'version_history_page.dart';

class AboutUwePage extends StatelessWidget {
  const AboutUwePage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: 'About UWE',
      child: FutureBuilder<_AboutData>(
        future: _loadData(),
        builder: (context, snapshot) {
          final data = snapshot.data;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: accent, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ultimate Window Engineer',
                      style: TextStyle(
                        color: accent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoLine(
                      label: 'Version',
                      value: data == null ? 'Loading...' : 'v${data.version}',
                      accent: accent,
                    ),
                    _InfoLine(
                      label: 'Build',
                      value: data?.buildNumber ?? 'Loading...',
                      accent: accent,
                    ),
                    _InfoLine(
                      label: 'Release Date',
                      value: data?.releaseDate ?? 'Loading...',
                      accent: accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _AboutButton(
                accent: accent,
                icon: Icons.history,
                label: 'Version History',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VersionHistoryPage(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_AboutData> _loadData() async {
    final info = await PackageInfo.fromPlatform();
    final releaseNotes = await loadReleaseNotes();

    return _AboutData(
      version: info.version,
      buildNumber: info.buildNumber,
      releaseDate: releaseNotes.isEmpty
          ? 'Unknown'
          : releaseNotes.first.releaseDate,
    );
  }
}

class _AboutData {
  final String version;
  final String buildNumber;
  final String releaseDate;

  const _AboutData({
    required this.version,
    required this.buildNumber,
    required this.releaseDate,
  });
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _InfoLine({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        '$label: $value',
        style: TextStyle(color: accent.withValues(alpha: 0.88), fontSize: 14),
      ),
    );
  }
}

class _AboutButton extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _AboutButton({
    required this.accent,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: accent, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
