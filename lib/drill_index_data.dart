//import 'package:flutter/material.dart';

enum DrillKind { fraction, number, letter, metric }

class DrillSize {
  final String name;
  final double decimal;
  final double metric;
  final DrillKind kind;

  const DrillSize({
    required this.name,
    required this.decimal,
    required this.metric,
    required this.kind,
  });
}

const List<DrillSize> drillIndex = [
  //Fraction
  DrillSize(
    name: "1/16",
    decimal: 0.0625,
    metric: 1.587,
    kind: DrillKind.fraction,
  ),
  DrillSize(
    name: "1/64",
    decimal: 0.015625,
    metric: 0.396875,
    kind: DrillKind.fraction,
  ),
  DrillSize(
    name: "1/32",
    decimal: 0.03125,
    metric: 0.79375,
    kind: DrillKind.fraction,
  ),
  DrillSize(
    name: "3/64",
    decimal: 0.046875,
    metric: 1.190625,
    kind: DrillKind.fraction,
  ),
  DrillSize(
    name: "5/64",
    decimal: 0.078125,
    metric: 1.984325,
    kind: DrillKind.fraction,
  ),

  //Number
  DrillSize(
    name: "#40",
    decimal: 0.0980,
    metric: 2.499,
    kind: DrillKind.number,
  ),

  // Letter
  DrillSize(name: "A", decimal: 0.2340, metric: 5.944, kind: DrillKind.letter),

  // Metric
  DrillSize(
    name: "0.05 mm",
    decimal: 0.0019,
    metric: 0.05,
    kind: DrillKind.metric,
  ),
  DrillSize(
    name: "0.06 mm",
    decimal: 0.0024,
    metric: 0.06,
    kind: DrillKind.metric,
  ),
  DrillSize(
    name: "0.07 mm",
    decimal: 0.0028,
    metric: 0.07,
    kind: DrillKind.metric,
  ),
  DrillSize(
    name: "0.08 mm",
    decimal: 0.0032,
    metric: 0.08,
    kind: DrillKind.metric,
  ),
  DrillSize(
    name: "0.10 mm",
    decimal: 0.0039,
    metric: 0.10,
    kind: DrillKind.metric,
  ),
  DrillSize(
    name: "0.11 mm",
    decimal: 0.0043,
    metric: 0.11,
    kind: DrillKind.metric,
  ),
  DrillSize(
    name: "0.12 mm",
    decimal: 0.0047,
    metric: 0.12,
    kind: DrillKind.metric,
  ),
  DrillSize(
    name: "0.13 mm",
    decimal: 0.0051,
    metric: 0.13,
    kind: DrillKind.metric,
  ),
  DrillSize(
    name: "0.14 mm",
    decimal: 0.0055,
    metric: 0.14,
    kind: DrillKind.metric,
  ),
  DrillSize(
    name: "0.24 mm",
    decimal: 0.0094,
    metric: 0.24,
    kind: DrillKind.metric,
  ),
  DrillSize(
    name: "6.0 mm",
    decimal: 0.2362,
    metric: 6.0,
    kind: DrillKind.metric,
  ),
  DrillSize(
    name: "1 mm",
    decimal: 0.039370079,
    metric: 1.0,
    kind: DrillKind.metric,
  ),
];

enum DrillFilter { all, fraction, number, letter, metric }

String filterLabel(DrillFilter f) {
  switch (f) {
    case DrillFilter.all:
      return "All";
    case DrillFilter.fraction:
      return "Fraction";
    case DrillFilter.number:
      return "Number";
    case DrillFilter.letter:
      return "Letter";
    case DrillFilter.metric:
      return "Metric";
  }
}
