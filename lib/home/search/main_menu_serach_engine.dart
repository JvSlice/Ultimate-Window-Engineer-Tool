import 'package:ultimate_window_engineer_tool/conversions/unit_conversions.dart';

import 'search_models.dart';

class MainMenuSearchEngine {
  List<SearchHit> buildHits({
    required String query,
    required List<SearchTarget> targets,
    required void Function(SearchTarget target) onOpenTarget,
    required void Function() onOpenConvertIt,
  }) {
    final trimmed = query.trim();
    final lower = trimmed.toLowerCase();

    final hits = <SearchHit>[];

    final conversionMatch = _parseConversionQuery(trimmed);
    if (conversionMatch != null) {
      hits.add(
        SearchHit(
          title: conversionMatch.title,
          subtitle: conversionMatch.subtitle,
          kindLabel: 'instant',
          onTap: onOpenConvertIt,
        ),
      );
    }

    final scored = <MapEntry<SearchTarget, int>>[];

    for (final target in targets) {
      int score = 0;

      final label = target.label.toLowerCase();
      final subtitle = target.subtitle.toLowerCase();

      if (label == lower) score += 140;
      if (label.startsWith(lower)) score += 90;
      if (label.contains(lower)) score += 48;
      if (subtitle.contains(lower)) score += 18;

      for (final keyword in target.keywords) {
        final k = keyword.toLowerCase();

        if (k == lower) score += 110;
        if (k.startsWith(lower)) score += 55;
        if (k.contains(lower)) score += 24;
      }

      final parts =
          lower.split(RegExp(r'\s+')).where((part) => part.trim().isNotEmpty);

      for (final part in parts) {
        if (label.contains(part)) score += 13;
        if (subtitle.contains(part)) score += 6;

        for (final keyword in target.keywords) {
          if (keyword.toLowerCase().contains(part)) {
            score += 9;
          }
        }
      }

      if (lower.contains('e1300') && label.contains('astm e1300')) {
        score += 120;
      }
      if (lower.contains('tap') && label.contains('drill & tap')) {
        score += 70;
      }
      if (lower.contains('awg') && label.contains('awg')) {
        score += 85;
      }
      if (lower.contains('glass') && label.contains('glass')) {
        score += 50;
      }
      if (lower.contains('deflection') && label.contains('deflection')) {
        score += 50;
      }
      if (lower.contains('ohm') && label.contains('ohms')) {
        score += 70;
      }
      if (lower.contains('triangle') && label.contains('triangle')) {
        score += 45;
      }
      if (lower.contains('weld') && label.contains('weld')) {
        score += 55;
      }
      if (lower.contains('tig') && label.contains('tig')) {
        score += 65;
      }
      if (lower.contains('stick') && label.contains('stick')) {
        score += 65;
      }
      if (lower.contains('gas') && label.contains('gas')) {
        score += 35;
      }
      if (lower.contains('battery') && label.contains('battery')) {
        score += 60;
      }
      if (lower.contains('torque') && label.contains('torque')) {
        score += 60;
      }
      if (lower.contains('beam') && label.contains('beam')) {
        score += 60;
      }
      if (lower.contains('geometry') && label.contains('geometry')) {
        score += 50;
      }

      if (score > 0) {
        scored.add(MapEntry(target, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));

    final seen = <String>{};
    for (final entry in scored) {
      if (seen.add(entry.key.label)) {
        hits.add(
          SearchHit(
            title: entry.key.label,
            subtitle: entry.key.subtitle,
            kindLabel: 'page',
            onTap: () => onOpenTarget(entry.key),
          ),
        );
      }
      if (hits.length >= 9) break;
    }

    return hits;
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
      'cfm/ft2': 'cfm/ft2',
      'cfm/ft^2': 'cfm/ft2',
      'cfmft2': 'cfm/ft2',
      'l/min/m2': 'l/min/m2',
      'l/min/m^2': 'l/min/m2',
      'lminm2': 'l/min/m2',
      'mph': 'mph',
      'in': 'in',
      'inch': 'in',
      'inches': 'in',
      'ft': 'ft',
      'foot': 'ft',
      'feet': 'ft',
      'mm': 'mm',
      'millimeter': 'mm',
      'millimeters': 'mm',
      'cm': 'cm',
      'centimeter': 'cm',
      'centimeters': 'cm',
      'm': 'm',
      'meter': 'm',
      'meters': 'm',
      'yd': 'yd',
      'yard': 'yd',
      'yards': 'yd',
      'mi': 'mi',
      'mile': 'mi',
      'miles': 'mi',
      'km': 'km',
      'kilometer': 'km',
      'kilometers': 'km',
      'um': 'um',
      'micron': 'um',
      'microns': 'um',
      'in2': 'in2',
      'in^2': 'in2',
      'sqin': 'in2',
      'cm2': 'cm2',
      'cm^2': 'cm2',
      'sqcm': 'cm2',
      'ft2': 'ft2',
      'ft^2': 'ft2',
      'sqft': 'ft2',
      'm2': 'm2',
      'm^2': 'm2',
      'sqm': 'm2',
      'yd2': 'yd2',
      'yd^2': 'yd2',
      'sqyd': 'yd2',
      'acre': 'acres',
      'acres': 'acres',
      'kg': 'kg',
      'kilogram': 'kg',
      'kilograms': 'kg',
      'lb': 'lb',
      'lbs': 'lb',
      'pound': 'lb',
      'pounds': 'lb',
      'g': 'g',
      'gram': 'g',
      'grams': 'g',
      'oz': 'oz',
      'ounce': 'oz',
      'ounces': 'oz',
      'n': 'n',
      'newton': 'n',
      'newtons': 'n',
      'kn': 'kn',
      'kilonewton': 'kn',
      'kilonewtons': 'kn',
      'lbf': 'lbf',
      'l': 'l',
      'liter': 'l',
      'liters': 'l',
      'litre': 'l',
      'litres': 'l',
      'ml': 'ml',
      'milliliter': 'ml',
      'milliliters': 'ml',
      'millilitre': 'ml',
      'millilitres': 'ml',
      'gal': 'gal',
      'gallon': 'gal',
      'gallons': 'gal',
      'floz': 'floz',
      'fl.oz': 'floz',
      'in3': 'in3',
      'in^3': 'in3',
      'ft3': 'ft3',
      'ft^3': 'ft3',
      'm3': 'm3',
      'm^3': 'm3',
      'tsp': 'tsp',
      'teaspoon': 'tsp',
      'teaspoons': 'tsp',
      'tbsp': 'tbsp',
      'tablespoon': 'tbsp',
      'tablespoons': 'tbsp',
      'cup': 'cups',
      'cups': 'cups',
      'pt': 'pt',
      'pint': 'pt',
      'pints': 'pt',
      'qt': 'qt',
      'quart': 'qt',
      'quarts': 'qt',
      'f': 'f',
      'fahrenheit': 'f',
      'c': 'c',
      'celsius': 'c',
      'k': 'k',
      'kelvin': 'k',
      'v': 'v',
      'volt': 'v',
      'volts': 'v',
      'mv': 'mv',
      'millivolt': 'mv',
      'millivolts': 'mv',
      'a': 'a',
      'amp': 'a',
      'amps': 'a',
      'ampere': 'a',
      'amperes': 'a',
      'ma': 'ma',
      'milliamp': 'ma',
      'milliamps': 'ma',
      'w': 'w',
      'watt': 'w',
      'watts': 'w',
      'kw': 'kw',
      'kilowatt': 'kw',
      'kilowatts': 'kw',
      'ohm': 'ohm',
      'ohms': 'ohm',
      'kohm': 'kohm',
      'kilohm': 'kohm',
      'kilohms': 'kohm',
      'mohm': 'mohm',
      'megohm': 'mohm',
      'megohms': 'mohm',
      'hz': 'hz',
      'hertz': 'hz',
      'khz': 'khz',
      'kilohertz': 'khz',
      'm/s': 'm/s',
      'ms': 'm/s',
      'ft/s': 'ft/s',
      'fps': 'ft/s',
      'km/h': 'km/h',
      'kph': 'km/h',
      'kmh': 'km/h',
      'hp': 'hp',
      'horsepower': 'hp',
      'btu': 'btu',
      'j': 'j',
      'joule': 'j',
      'joules': 'j',
      'kwh': 'kwh',
      'ftlbf': 'ftlbf',
      'ftlb': 'ftlbf',
      'inlbf': 'inlbf',
      'inlb': 'inlbf',
      'nm': 'nm',
      'newtonmeter': 'nm',
      'newtonmeters': 'nm',
    };

    return aliases[s] ?? s;
  }
}
