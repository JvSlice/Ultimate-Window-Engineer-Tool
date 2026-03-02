import 'package:flutter/foundation.dart';

enum SectionIUnits { inch, mm }

class SectionProps {
  final double area; // in^2 or mm^2
  final double ix;   // in^4 or mm^4
  final double iy;   // in^4 or mm^4
  final double sx;   // in^3 or mm^3
  final double sy;   // in^3 or mm^3
  final double rx;   // in or mm
  final double ry;   // in or mm
  final SectionIUnits units;

  const SectionProps({
    required this.area,
    required this.ix,
    required this.iy,
    required this.sx,
    required this.sy,
    required this.rx,
    required this.ry,
    required this.units,
  });
}

// Global store (simple + works everywhere)
final ValueNotifier<SectionProps?> lastSectionProps = ValueNotifier<SectionProps?>(null);
