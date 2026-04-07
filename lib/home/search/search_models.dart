import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/conversions/unit_conversions.dart';

class SearchTarget {
  final String label;
  final String subtitle;
  final List<String> keywords;
  final Widget Function(BuildContext context) builder;

  const SearchTarget({
    required this.label,
    required this.subtitle,
    required this.keywords,
    required this.builder,
  });
}

class SearchHit {
  final String title;
  final String subtitle;
  final String kindLabel;
  final VoidCallback onTap;

  const SearchHit({
    required this.title,
    required this.subtitle,
    required this.kindLabel,
    required this.onTap,
  });
}

class ResolvedTool {
  final ConversionTool tool;
  final Direction direction;

  const ResolvedTool({
    required this.tool,
    required this.direction,
  });
}

class ConversionMatch {
  final String title;
  final String subtitle;

  const ConversionMatch({
    required this.title,
    required this.subtitle,
  });
}
