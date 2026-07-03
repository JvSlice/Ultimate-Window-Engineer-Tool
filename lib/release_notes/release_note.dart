class ReleaseNote {
  final String version;
  final String releaseDate;
  final String buildNumber;
  final List<ReleaseNoteSection> sections;

  const ReleaseNote({
    required this.version,
    required this.releaseDate,
    required this.buildNumber,
    required this.sections,
  });
}

class ReleaseNoteSection {
  final String title;
  final List<String> entries;

  const ReleaseNoteSection({required this.title, required this.entries});
}
