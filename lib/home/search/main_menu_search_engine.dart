import 'dart:math' as math;

import 'package:ultimate_window_engineer_tool/conversions/unit_conversions.dart';

import 'search_models.dart';

class MainMenuSearchEngine {
  static final RegExp _splitPattern = RegExp(r'[^a-z0-9]+');

  List<SearchHit> buildHits({
    required String query,
    required List<SearchEntry> entries,
    required void Function(SearchEntry entry) onOpenEntry,
    required void Function() onOpenConvertIt,
  }) {
    final trimmed = query.trim();
    final normalizedQuery = _normalize(trimmed);
    final queryTokens = _tokens(trimmed);

    final hits = <SearchHit>[];

    final conversionMatch = _parseConversionQuery(trimmed);
    if (conversionMatch != null) {
      hits.add(
        SearchHit(
          title: conversionMatch.title,
          category: 'Instant',
          description: conversionMatch.subtitle,
          kindLabel: 'instant',
          onTap: onOpenConvertIt,
        ),
      );
    }

    if (normalizedQuery.isEmpty) return hits;

    final scored = <_ScoredEntry>[];

    for (final entry in entries) {
      final index = _SearchIndex.fromEntry(entry);
      final score = _scoreTarget(
        normalizedQuery: normalizedQuery,
        queryTokens: queryTokens,
        index: index,
      );

      if (score > 0) {
        scored.add(_ScoredEntry(entry: entry, score: score));
      }
    }

    scored.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.entry.title.compareTo(b.entry.title);
    });

    final seen = <String>{};
    for (final entry in scored) {
      if (seen.add(entry.entry.routeId)) {
        hits.add(
          SearchHit(
            title: entry.entry.title,
            category: entry.entry.category,
            description: entry.entry.description,
            kindLabel: 'page',
            onTap: () => onOpenEntry(entry.entry),
          ),
        );
      }
      if (hits.length >= 9) break;
    }

    return hits;
  }

  int _scoreTarget({
    required String normalizedQuery,
    required List<String> queryTokens,
    required _SearchIndex index,
  }) {
    int score = 0;

    if (index.title == normalizedQuery) score += 260;
    if (index.title.startsWith(normalizedQuery)) score += 190;
    if (index.title.contains(normalizedQuery)) score += 120;

    if (index.description == normalizedQuery) score += 130;
    if (index.description.startsWith(normalizedQuery)) score += 80;
    if (index.description.contains(normalizedQuery)) score += 45;

    if (index.category == normalizedQuery) score += 120;
    if (index.category.startsWith(normalizedQuery)) score += 75;
    if (index.category.contains(normalizedQuery)) score += 40;

    if (index.acronym == normalizedQuery) score += 150;
    if (index.acronym.startsWith(normalizedQuery)) score += 70;

    for (final tag in index.tags) {
      if (tag == normalizedQuery) score += 170;
      if (tag.startsWith(normalizedQuery)) score += 95;
      if (tag.contains(normalizedQuery)) score += 50;
    }

    for (final alias in index.aliases) {
      if (alias == normalizedQuery) score += 185;
      if (alias.startsWith(normalizedQuery)) score += 105;
      if (alias.contains(normalizedQuery)) score += 55;
    }

    for (final token in queryTokens) {
      if (token.length < 2) continue;

      final normalizedToken = _normalize(token);
      if (normalizedToken.isEmpty) continue;

      score += _bestTokenScore(normalizedToken, index.titleTokens, labelWeight: 34);
      score += _bestTokenScore(normalizedToken, index.categoryTokens, labelWeight: 20);
      score += _bestTokenScore(normalizedToken, index.descriptionTokens, labelWeight: 18);
      score += _bestTokenScore(normalizedToken, index.tagTokens, labelWeight: 16);
      score += _bestTokenScore(normalizedToken, index.aliasTokens, labelWeight: 22);

      if (_isSubsequence(normalizedToken, index.titleCompact)) score += 10;
      if (_isSubsequence(normalizedToken, index.allTextCompact)) score += 5;
    }

    final matchedTokenCount = queryTokens.where((token) {
      final normalizedToken = _normalize(token);
      if (normalizedToken.length < 2) return false;
      return index.allTokens.any((candidate) => _tokenLooksRelated(normalizedToken, candidate));
    }).length;

    if (queryTokens.isNotEmpty && matchedTokenCount == queryTokens.length) {
      score += 90;
    } else if (matchedTokenCount > 1) {
      score += matchedTokenCount * 22;
    }

    // Small, generic engineering synonym handling. This is intentionally broad,
    // not a per-page keyword list. Add here only when a term helps many tools.
    score += _synonymScore(queryTokens, index);

    return score;
  }

  int _bestTokenScore(
    String queryToken,
    List<String> candidateTokens, {
    required int labelWeight,
  }) {
    int best = 0;

    for (final candidate in candidateTokens) {
      if (candidate.isEmpty) continue;

      if (candidate == queryToken) {
        best = math.max(best, labelWeight * 3);
      } else if (candidate.startsWith(queryToken)) {
        best = math.max(best, labelWeight * 2);
      } else if (candidate.contains(queryToken)) {
        best = math.max(best, labelWeight);
      } else if (queryToken.length >= 4 && _isFuzzyClose(queryToken, candidate)) {
        best = math.max(best, (labelWeight * 0.9).round());
      }
    }

    return best;
  }

  int _synonymScore(List<String> queryTokens, _SearchIndex index) {
    int score = 0;

    const synonymGroups = <List<String>>[
      ['calc', 'calculator', 'calculate', 'calculation', 'math', 'formula', 'solver'],
      ['electric', 'electrical', 'voltage', 'volt', 'volts', 'current', 'amps', 'amp', 'resistance', 'ohm', 'wire'],
      ['weld', 'welding', 'mig', 'tig', 'stick', 'rod', 'electrode'],
      ['glass', 'glazing', 'lite', 'deflection', 'e1300'],
      ['test', 'testing', 'astm', 'pressure', 'structural', 'rating'],
      ['rigging', 'sling', 'lift', 'lifting', 'wll', 'load', 'hitch'],
      ['geometry', 'shape', 'area', 'volume', 'triangle', 'circle', 'rectangle'],
      ['material', 'materials', 'steel', 'aluminum', 'concrete', 'plastic'],
      ['thermal', 'temperature', 'heat', 'expansion', 'uvalue', 'rvalue'],
      ['drill', 'tap', 'thread', 'hole', 'bit'],
    ];

    for (final group in synonymGroups) {
      final queryHitsGroup = queryTokens.any((token) => group.contains(_normalize(token)));
      if (!queryHitsGroup) continue;

      final targetHitsGroup = index.allTokens.any(group.contains);
      if (targetHitsGroup) score += 35;
    }

    return score;
  }

  bool _tokenLooksRelated(String a, String b) {
    return a == b ||
        b.startsWith(a) ||
        b.contains(a) ||
        (a.length >= 4 && _isFuzzyClose(a, b));
  }

  bool _isFuzzyClose(String a, String b) {
    if ((a.length - b.length).abs() > 2) return false;
    return _editDistance(a, b, maxDistance: 2) <= 2;
  }

  int _editDistance(String a, String b, {required int maxDistance}) {
    if ((a.length - b.length).abs() > maxDistance) return maxDistance + 1;

    var previous = List<int>.generate(b.length + 1, (i) => i);

    for (var i = 0; i < a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0);
      current[0] = i + 1;
      var rowMin = current[0];

      for (var j = 0; j < b.length; j++) {
        final cost = a[i] == b[j] ? 0 : 1;
        current[j + 1] = math.min(
          math.min(current[j] + 1, previous[j + 1] + 1),
          previous[j] + cost,
        );
        rowMin = math.min(rowMin, current[j + 1]);
      }

      if (rowMin > maxDistance) return maxDistance + 1;
      previous = current;
    }

    return previous[b.length];
  }

  bool _isSubsequence(String query, String candidate) {
    if (query.isEmpty) return true;
    if (candidate.isEmpty) return false;

    var queryIndex = 0;
    for (var i = 0; i < candidate.length && queryIndex < query.length; i++) {
      if (candidate[i] == query[queryIndex]) queryIndex++;
    }
    return queryIndex == query.length;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('&', ' and ')
        .replaceAll('+', ' plus ')
        .replaceAll('°', '')
        .replaceAll('µ', 'u')
        .replaceAll('Ω', 'ohm')
        .replaceAll('²', '2')
        .replaceAll('³', '3')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  List<String> _tokens(String value) {
    return _normalize(value)
        .split(_splitPattern)
        .where((token) => token.trim().isNotEmpty)
        .toList(growable: false);
  }

  String _compact(String value) => _tokens(value).join();

  String _acronym(String value) {
    return _tokens(value).where((token) => token.isNotEmpty).map((token) => token[0]).join();
  }

  ConversionMatch? _parseConversionQuery(String query) {
    if (query.trim().isEmpty) return null;

    final numericPattern = RegExp(
      r'^\s*([-+]?\d*\.?\d+)\s*([A-Za-z°µΩ²³/·\-\s/]+?)\s*(?:to|into|->|→)\s*([A-Za-z°µΩ²³/·\-\s/]+)\s*$',
      caseSensitive: false,
    );

    final noValuePattern = RegExp(
      r'^\s*([A-Za-z°µΩ²³/·\-\s/]+?)\s*(?:to|into|->|→)\s*([A-Za-z°µΩ²³/·\-\s/]+)\s*$',
      caseSensitive: false,
    );

    final numericMatch = numericPattern.firstMatch(query);
    if (numericMatch != null) {
      final input = double.tryParse(numericMatch.group(1)!);
      final fromRaw = numericMatch.group(2)!;
      final toRaw = numericMatch.group(3)!;

      if (input == null) return null;

      final resolved = _resolveConversionTool(fromRaw, toRaw);
      if (resolved == null) return null;

      final output = resolved.tool.convert(resolved.direction, input);

      return ConversionMatch(
        title: '${_formatInput(input)} ${_prettyUnit(fromRaw)} → $output',
        subtitle: '${resolved.tool.label} • tap to open Convert It',
      );
    }

    final noValueMatch = noValuePattern.firstMatch(query);
    if (noValueMatch != null) {
      final fromRaw = noValueMatch.group(1)!;
      final toRaw = noValueMatch.group(2)!;

      final resolved = _resolveConversionTool(fromRaw, toRaw);
      if (resolved == null) return null;

      return ConversionMatch(
        title:
            'Open ${resolved.tool.label} (${_prettyUnit(fromRaw)} → ${_prettyUnit(toRaw)})',
        subtitle: 'Matched conversion tool • tap to open Convert It',
      );
    }

    return null;
  }

  ResolvedTool? _resolveConversionTool(String fromRaw, String toRaw) {
    final from = _canonicalUnit(fromRaw);
    final to = _canonicalUnit(toRaw);

    for (final tool in conversionTools) {
      final toolFrom = _canonicalUnit(tool.fromUnit);
      final toolTo = _canonicalUnit(tool.toUnit);

      if (from == toolFrom && to == toolTo) {
        return ResolvedTool(tool: tool, direction: Direction.to);
      }
      if (from == toolTo && to == toolFrom) {
        return ResolvedTool(tool: tool, direction: Direction.from);
      }
    }

    return null;
  }

  String _prettyUnit(String raw) {
    return raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _formatInput(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _canonicalUnit(String raw) {
    String s = raw.toLowerCase().trim();

    s = s
        .replaceAll('°', '')
        .replaceAll('µ', 'u')
        .replaceAll('Ω', 'ohm')
        .replaceAll('²', '2')
        .replaceAll('³', '3')
        .replaceAll('·', '')
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll(RegExp(r'\.$'), '');

    const aliases = <String, String>{
      'psi': 'psi',
      'psf': 'psf',
      'pa': 'pa',
      'pascal': 'pa',
      'pascals': 'pa',
      'kpa': 'kpa',
      'mph': 'mph',
      'in': 'in',
      'inch': 'in',
      'inches': 'in',
      'ft': 'ft',
      'foot': 'ft',
      'feet': 'ft',
      'mm': 'mm',
      'cm': 'cm',
      'm': 'm',
      'yd': 'yd',
      'mi': 'mi',
      'km': 'km',
      'kg': 'kg',
      'lb': 'lb',
      'lbs': 'lb',
      'g': 'g',
      'oz': 'oz',
      'n': 'n',
      'kn': 'kn',
      'l': 'l',
      'ml': 'ml',
      'gal': 'gal',
      'floz': 'floz',
      'tsp': 'tsp',
      'tbsp': 'tbsp',
      'cup': 'cups',
      'cups': 'cups',
      'pt': 'pt',
      'qt': 'qt',
      'f': 'f',
      'fahrenheit': 'f',
      'c': 'c',
      'celsius': 'c',
      'k': 'k',
      'kelvin': 'k',
      'v': 'v',
      'a': 'a',
      'ma': 'ma',
      'w': 'w',
      'kw': 'kw',
      'ohm': 'ohm',
      'ohms': 'ohm',
      'kohm': 'kohm',
      'mohm': 'mohm',
      'hz': 'hz',
      'khz': 'khz',
      'm/s': 'm/s',
      'ft/s': 'ft/s',
      'km/h': 'km/h',
      'kph': 'km/h',
      'kmh': 'km/h',
      'hp': 'hp',
      'btu': 'btu',
      'j': 'j',
      'kwh': 'kwh',
      'ftlbf': 'ftlbf',
      'ftlb': 'ftlbf',
      'inlbf': 'inlbf',
      'inlb': 'inlbf',
      'nm': 'nm',
    };

    return aliases[s] ?? s;
  }
}

class _SearchIndex {
  final String title;
  final String category;
  final String description;
  final List<String> tags;
  final List<String> aliases;
  final List<String> titleTokens;
  final List<String> categoryTokens;
  final List<String> descriptionTokens;
  final List<String> tagTokens;
  final List<String> aliasTokens;
  final List<String> allTokens;
  final String titleCompact;
  final String allTextCompact;
  final String acronym;

  _SearchIndex({
    required this.title,
    required this.category,
    required this.description,
    required this.tags,
    required this.aliases,
    required this.titleTokens,
    required this.categoryTokens,
    required this.descriptionTokens,
    required this.tagTokens,
    required this.aliasTokens,
    required this.allTokens,
    required this.titleCompact,
    required this.allTextCompact,
    required this.acronym,
  });

  factory _SearchIndex.fromEntry(SearchEntry entry) {
    final engine = MainMenuSearchEngine();
    final titleTokens = engine._tokens(entry.title);
    final categoryTokens = engine._tokens(entry.category);
    final descriptionTokens = engine._tokens(entry.description);
    final tagTokens = entry.tags.expand(engine._tokens).toList(growable: false);
    final aliasTokens = entry.aliases.expand(engine._tokens).toList(growable: false);
    final routeTokens = engine._tokens(entry.routeId);

    final allTokens = <String>{
      ...titleTokens,
      ...categoryTokens,
      ...descriptionTokens,
      ...tagTokens,
      ...aliasTokens,
      ...routeTokens,
    }.toList(growable: false);

    final allText =
        '${entry.title} ${entry.category} ${entry.description} ${entry.tags.join(' ')} ${entry.aliases.join(' ')} ${entry.routeId}';

    return _SearchIndex(
      title: engine._normalize(entry.title),
      category: engine._normalize(entry.category),
      description: engine._normalize(entry.description),
      tags: entry.tags.map(engine._normalize).toList(growable: false),
      aliases: entry.aliases.map(engine._normalize).toList(growable: false),
      titleTokens: titleTokens,
      categoryTokens: categoryTokens,
      descriptionTokens: descriptionTokens,
      tagTokens: tagTokens,
      aliasTokens: aliasTokens,
      allTokens: allTokens,
      titleCompact: engine._compact(entry.title),
      allTextCompact: engine._compact(allText),
      acronym: engine._acronym(entry.title),
    );
  }
}

class _ScoredEntry {
  final SearchEntry entry;
  final int score;

  const _ScoredEntry({
    required this.entry,
    required this.score,
  });
}
