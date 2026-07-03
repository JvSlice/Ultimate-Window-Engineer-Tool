import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../terminal_scaffold.dart';
import 'release_note.dart';
import 'release_notes_parser.dart';

class VersionHistoryPage extends StatelessWidget {
  const VersionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: 'Version History',
      child: FutureBuilder<_VersionHistoryData>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator(color: accent));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Unable to load release notes.',
                style: TextStyle(color: accent),
              ),
            );
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CurrentVersionPanel(data: data, accent: accent),
              const SizedBox(height: 16),
              ...data.releaseNotes.asMap().entries.map((entry) {
                return _ReleaseNoteCard(
                  note: entry.value,
                  accent: accent,
                  initiallyExpanded: entry.key == 0,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Future<_VersionHistoryData> _loadData() async {
    final info = await PackageInfo.fromPlatform();
    final releaseNotes = await loadReleaseNotes();

    return _VersionHistoryData(
      appName: info.appName.isEmpty ? 'Ultimate Window Engineer' : info.appName,
      version: info.version,
      buildNumber: info.buildNumber,
      releaseNotes: releaseNotes,
    );
  }
}

class _VersionHistoryData {
  final String appName;
  final String version;
  final String buildNumber;
  final List<ReleaseNote> releaseNotes;

  const _VersionHistoryData({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.releaseNotes,
  });

  String get releaseDate =>
      releaseNotes.isEmpty ? 'Unknown' : releaseNotes.first.releaseDate;
}

class _CurrentVersionPanel extends StatelessWidget {
  final _VersionHistoryData data;
  final Color accent;

  const _CurrentVersionPanel({required this.data, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _InfoLine(label: 'Package', value: data.appName, accent: accent),
          _InfoLine(
            label: 'Version',
            value: 'v${data.version}',
            accent: accent,
          ),
          _InfoLine(label: 'Build', value: data.buildNumber, accent: accent),
          _InfoLine(
            label: 'Release Date',
            value: data.releaseDate,
            accent: accent,
          ),
        ],
      ),
    );
  }
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

class _ReleaseNoteCard extends StatelessWidget {
  final ReleaseNote note;
  final Color accent;
  final bool initiallyExpanded;

  const _ReleaseNoteCard({
    required this.note,
    required this.accent,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: accent.withValues(alpha: 0.75), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          iconColor: accent,
          collapsedIconColor: accent,
          title: Text(
            note.version,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Released: ${note.releaseDate}',
            style: TextStyle(color: accent.withValues(alpha: 0.72)),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            if (note.buildNumber.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Build: ${note.buildNumber}',
                  style: TextStyle(color: accent.withValues(alpha: 0.72)),
                ),
              ),
            for (final section in note.sections) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  section.title,
                  style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              for (final entry in section.entries)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '* $entry',
                      style: TextStyle(color: accent.withValues(alpha: 0.88)),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
