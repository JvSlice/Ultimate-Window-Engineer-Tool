class ProgrammingReferenceItem {
  final String title;
  final String summary;
  final String whenToUse;
  final String commonMistake;
  final String code;
  final List<String> tags;

  const ProgrammingReferenceItem({
    required this.title,
    required this.summary,
    required this.whenToUse,
    required this.commonMistake,
    required this.code,
    required this.tags,
  });

  bool matches(String query) {
    if (query.trim().isEmpty) return true;
    final q = query.toLowerCase();

    return title.toLowerCase().contains(q) ||
        summary.toLowerCase().contains(q) ||
        whenToUse.toLowerCase().contains(q) ||
        commonMistake.toLowerCase().contains(q) ||
        code.toLowerCase().contains(q) ||
        tags.any((tag) => tag.toLowerCase().contains(q));
  }
}
