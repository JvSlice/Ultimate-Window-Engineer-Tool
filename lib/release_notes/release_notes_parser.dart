import 'package:flutter/services.dart';

import 'release_note.dart';

Future<List<ReleaseNote>> loadReleaseNotes() async {
  final markdown = await rootBundle.loadString('assets/release_notes.md');
  return parseReleaseNotes(markdown);
}

List<ReleaseNote> parseReleaseNotes(String markdown) {
  final notes = <ReleaseNote>[];
  final lines = markdown.split(RegExp(r'\r?\n'));

  String? version;
  String releaseDate = '';
  String buildNumber = '';
  final sections = <ReleaseNoteSection>[];
  String? sectionTitle;
  var sectionEntries = <String>[];

  void flushSection() {
    if (sectionTitle == null) return;
    sections.add(
      ReleaseNoteSection(title: sectionTitle!, entries: sectionEntries),
    );
    sectionTitle = null;
    sectionEntries = <String>[];
  }

  void flushRelease() {
    if (version == null) return;
    flushSection();
    notes.add(
      ReleaseNote(
        version: version!,
        releaseDate: releaseDate,
        buildNumber: buildNumber,
        sections: List.unmodifiable(sections),
      ),
    );
    version = null;
    releaseDate = '';
    buildNumber = '';
    sections.clear();
  }

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('# ')) continue;

    if (line.startsWith('## ')) {
      flushRelease();
      version = line.substring(3).trim();
      continue;
    }

    if (line.startsWith('### ')) {
      flushSection();
      sectionTitle = line.substring(4).trim();
      continue;
    }

    if (line.startsWith('Released:')) {
      releaseDate = line.substring('Released:'.length).trim();
      continue;
    }

    if (line.startsWith('Build:')) {
      buildNumber = line.substring('Build:'.length).trim();
      continue;
    }

    if (line.startsWith('* ')) {
      sectionEntries.add(line.substring(2).trim());
    }
  }

  flushRelease();
  return List.unmodifiable(notes);
}
