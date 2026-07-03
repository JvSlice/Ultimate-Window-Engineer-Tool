import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/conversions/unit_conversions.dart';

class SearchEntry {
  final String title;
  final String category;
  final String description;
  final List<String> tags;
  final List<String> aliases;
  final String routeId;
  final Widget Function(BuildContext context) builder;

  const SearchEntry({
    required this.title,
    required this.category,
    required this.description,
    required this.tags,
    required this.aliases,
    required this.routeId,
    required this.builder,
  });
}

class SearchHit {
  final String title;
  final String category;
  final String description;
  final String kindLabel;
  final VoidCallback onTap;

  const SearchHit({
    required this.title,
    required this.category,
    required this.description,
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
