import 'dart:convert';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

import '../conversions/unit_conversions.dart';

enum KnifeBevelMode { desiredBevel, existingBlock }

enum KnifeGrindType { fullFlat, saber, scandi, hollow, convex, chisel }

enum KnifeUnitSystem { imperial, metric }

enum KnifeGrindingOrientation { left, right }

extension KnifeUnitSystemLabels on KnifeUnitSystem {
  String get lengthUnit => this == KnifeUnitSystem.imperial ? 'in' : 'mm';
}

extension KnifeGrindTypeLabels on KnifeGrindType {
  String get label {
    switch (this) {
      case KnifeGrindType.fullFlat:
        return 'Full flat';
      case KnifeGrindType.saber:
        return 'Saber';
      case KnifeGrindType.scandi:
        return 'Scandi';
      case KnifeGrindType.hollow:
        return 'Hollow / concave';
      case KnifeGrindType.convex:
        return 'Convex';
      case KnifeGrindType.chisel:
        return 'Single-sided / chisel';
    }
  }

  bool get isCurved =>
      this == KnifeGrindType.hollow || this == KnifeGrindType.convex;

  int get groundSides => this == KnifeGrindType.chisel ? 1 : 2;
}

extension KnifeGrindingOrientationLabels on KnifeGrindingOrientation {
  String get label => this == KnifeGrindingOrientation.left ? 'Left' : 'Right';
  double get sign => this == KnifeGrindingOrientation.left ? -1 : 1;
}

class KnifePoint {
  final double x;
  final double y;

  const KnifePoint(this.x, this.y);

  KnifePoint mirrorY() => KnifePoint(x, -y);
}

class KnifeArc {
  final KnifePoint center;
  final double radius;
  final double startAngleRadians;
  final double sweepRadians;
  final List<KnifePoint> points;
  final double tangentAngleDegrees;

  const KnifeArc({
    required this.center,
    required this.radius,
    required this.startAngleRadians,
    required this.sweepRadians,
    required this.points,
    required this.tangentAngleDegrees,
  });
}

class KnifeBevelInput {
  final KnifeBevelMode mode;
  final KnifeGrindType grindType;
  final KnifeGrindingOrientation orientation;
  final double stockThickness;
  final double bladeHeight;
  final double edgeThickness;
  final double desiredBevelHeight;
  final double blockAngleDegrees;
  final double seatOffsetDegrees;
  final double curvatureRadius;

  const KnifeBevelInput({
    required this.mode,
    required this.grindType,
    required this.orientation,
    required this.stockThickness,
    required this.bladeHeight,
    required this.edgeThickness,
    required this.desiredBevelHeight,
    required this.blockAngleDegrees,
    required this.seatOffsetDegrees,
    required this.curvatureRadius,
  });
}

class KnifeBevelResult {
  final double bevelAngleDegrees;
  final double totalIncludedAngleDegrees;
  final double bevelHeight;
  final double actualBladeOrientationDegrees;
  final double blockAngleDegrees;
  final double seatOffsetDegrees;
  final double? requiredBlockAngleDegrees;
  final bool isAchievable;
  final String? note;
  final List<KnifePoint> upperBevelProfile;
  final List<KnifePoint> lowerBevelProfile;
  final KnifeArc? upperArc;
  final KnifeArc? lowerArc;
  final KnifeGrindType geometryClassification;

  const KnifeBevelResult({
    required this.bevelAngleDegrees,
    required this.totalIncludedAngleDegrees,
    required this.bevelHeight,
    required this.actualBladeOrientationDegrees,
    required this.blockAngleDegrees,
    required this.seatOffsetDegrees,
    required this.requiredBlockAngleDegrees,
    required this.isAchievable,
    required this.note,
    required this.upperBevelProfile,
    required this.lowerBevelProfile,
    required this.upperArc,
    required this.lowerArc,
    required this.geometryClassification,
  });
}

/// Straight bevel angle follows atan(reduction / bevel height).
/// A double-sided grind shares stock reduction between both sides. A chisel
/// grind uses the full reduction on one side. Curved profiles use a true circle
/// through the edge and bevel termination; radius is the wheel radius for
/// hollow grinds and the chosen model radius for convex grinds.
KnifeBevelResult? calculateKnifeBevel(KnifeBevelInput input) {
  final dimensions = [
    input.stockThickness,
    input.bladeHeight,
    input.edgeThickness,
  ];
  if (dimensions.any((value) => !value.isFinite || value <= 0) ||
      input.edgeThickness >= input.stockThickness ||
      !input.blockAngleDegrees.isFinite ||
      !input.seatOffsetDegrees.isFinite ||
      (input.grindType.isCurved &&
          (!input.curvatureRadius.isFinite || input.curvatureRadius <= 0))) {
    return null;
  }

  final reduction = input.stockThickness - input.edgeThickness;
  final sideReduction = reduction / input.grindType.groundSides;
  final orientationSign = input.orientation.sign;
  final actualOrientation =
      orientationSign * input.blockAngleDegrees + input.seatOffsetDegrees;

  late final double bevelHeight;
  late final double bevelAngle;
  late final double blockAngle;
  KnifeArc? upperArc;
  KnifeArc? lowerArc;

  if (input.mode == KnifeBevelMode.desiredBevel) {
    bevelHeight = input.desiredBevelHeight;
    if (!bevelHeight.isFinite || bevelHeight <= 0) return null;

    if (input.grindType.isCurved) {
      final upperStart = _upperEdgePoint(input);
      final upperEnd = KnifePoint(bevelHeight, input.stockThickness / 2);
      upperArc = _circleThroughPoints(
        start: upperStart,
        end: upperEnd,
        radius: input.curvatureRadius,
        hollow: input.grindType == KnifeGrindType.hollow,
      );
      if (upperArc == null) return null;

      if (input.grindType.groundSides == 2) {
        lowerArc = KnifeArc(
          center: upperArc.center.mirrorY(),
          radius: upperArc.radius,
          startAngleRadians: -upperArc.startAngleRadians,
          sweepRadians: -upperArc.sweepRadians,
          points: upperArc.points.reversed.map((p) => p.mirrorY()).toList(),
          tangentAngleDegrees: upperArc.tangentAngleDegrees,
        );
      }
      bevelAngle = upperArc.tangentAngleDegrees.abs();
    } else {
      bevelAngle = _degrees(math.atan2(sideReduction, bevelHeight));
    }

    if (bevelAngle <= 0 || bevelAngle >= 90) return null;
    blockAngle = orientationSign * (bevelAngle - input.seatOffsetDegrees);
  } else {
    bevelAngle = actualOrientation.abs();
    if (bevelAngle <= 0 || bevelAngle >= 90) return null;

    if (input.grindType.isCurved) {
      final start = _upperEdgePoint(input);
      final radius = input.curvatureRadius;
      final alpha = orientationSign * actualOrientation * math.pi / 180;
      final endX = _circleEndX(
        start: start,
        faceY: input.stockThickness / 2,
        radius: radius,
        tangentAngleRadians: alpha,
        hollow: input.grindType == KnifeGrindType.hollow,
      );
      if (endX == null || endX <= 0) return null;
      bevelHeight = endX;
      upperArc = _circleThroughPoints(
        start: start,
        end: KnifePoint(bevelHeight, input.stockThickness / 2),
        radius: radius,
        hollow: input.grindType == KnifeGrindType.hollow,
      );
      if (upperArc == null) return null;
      if (input.grindType.groundSides == 2) {
        lowerArc = KnifeArc(
          center: upperArc.center.mirrorY(),
          radius: upperArc.radius,
          startAngleRadians: -upperArc.startAngleRadians,
          sweepRadians: -upperArc.sweepRadians,
          points: upperArc.points.reversed.map((p) => p.mirrorY()).toList(),
          tangentAngleDegrees: upperArc.tangentAngleDegrees,
        );
      }
    } else {
      bevelHeight = sideReduction / math.tan(_radians(bevelAngle));
    }
    blockAngle = input.blockAngleDegrees;
  }

  if (!bevelHeight.isFinite || bevelHeight <= 0) return null;
  final upperProfile = upperArc?.points ?? _straightProfile(input, bevelHeight);
  final lowerProfile = input.grindType.groundSides == 2
      ? (lowerArc?.points ??
            upperProfile.reversed.map((p) => p.mirrorY()).toList())
      : [
          KnifePoint(0, -input.stockThickness / 2),
          KnifePoint(input.bladeHeight, -input.stockThickness / 2),
        ];

  final classification = classifyKnifeGrind(bevelHeight, input.bladeHeight);
  final achievable = bevelHeight <= input.bladeHeight;
  final note = achievable
      ? null
      : 'Bevel termination is beyond the blade height; this setup cannot form the requested grind.';

  return KnifeBevelResult(
    bevelAngleDegrees: bevelAngle,
    totalIncludedAngleDegrees: input.grindType.groundSides == 2
        ? bevelAngle * 2
        : bevelAngle,
    bevelHeight: bevelHeight,
    actualBladeOrientationDegrees: input.mode == KnifeBevelMode.existingBlock
        ? actualOrientation
        : orientationSign * bevelAngle,
    blockAngleDegrees: blockAngle,
    seatOffsetDegrees: input.seatOffsetDegrees,
    requiredBlockAngleDegrees: input.mode == KnifeBevelMode.desiredBevel
        ? blockAngle.abs()
        : null,
    isAchievable: achievable,
    note: note,
    upperBevelProfile: upperProfile,
    lowerBevelProfile: lowerProfile,
    upperArc: upperArc,
    lowerArc: lowerArc,
    geometryClassification: classification,
  );
}

KnifeGrindType classifyKnifeGrind(double bevelHeight, double bladeHeight) {
  final coverage = bevelHeight / bladeHeight;
  if (coverage >= 0.95) return KnifeGrindType.fullFlat;
  if (coverage >= 0.35) return KnifeGrindType.saber;
  return KnifeGrindType.scandi;
}

double knifePresetHeight(KnifeGrindType type, double bladeHeight) {
  switch (type) {
    case KnifeGrindType.fullFlat:
      return bladeHeight;
    case KnifeGrindType.saber:
      return bladeHeight * 0.70;
    case KnifeGrindType.scandi:
      return bladeHeight * 0.30;
    case KnifeGrindType.hollow:
    case KnifeGrindType.convex:
    case KnifeGrindType.chisel:
      return bladeHeight * 0.50;
  }
}

double convertKnifeLength(
  double value,
  KnifeUnitSystem from,
  KnifeUnitSystem to,
) {
  if (from == to) return value;
  return from == KnifeUnitSystem.imperial
      ? inchesToMillimeters(value)
      : millimetersToInches(value);
}

KnifePoint _upperEdgePoint(KnifeBevelInput input) {
  if (input.grindType.groundSides == 2) {
    return KnifePoint(0, input.edgeThickness / 2);
  }
  return KnifePoint(0, -input.stockThickness / 2 + input.edgeThickness);
}

List<KnifePoint> _straightProfile(KnifeBevelInput input, double height) {
  final start = _upperEdgePoint(input);
  return [
    start,
    KnifePoint(height, input.stockThickness / 2),
    KnifePoint(input.bladeHeight, input.stockThickness / 2),
  ];
}

KnifeArc? _circleThroughPoints({
  required KnifePoint start,
  required KnifePoint end,
  required double radius,
  required bool hollow,
}) {
  final dx = end.x - start.x;
  final dy = end.y - start.y;
  final chord = math.sqrt(dx * dx + dy * dy);
  if (!chord.isFinite || chord <= 0 || radius < chord / 2) return null;

  final midpoint = KnifePoint((start.x + end.x) / 2, (start.y + end.y) / 2);
  final offset = math.sqrt(radius * radius - chord * chord / 4);
  final normalX = -dy / chord;
  final normalY = dx / chord;
  final side = hollow ? 1.0 : -1.0;
  final center = KnifePoint(
    midpoint.x + side * normalX * offset,
    midpoint.y + side * normalY * offset,
  );

  final startAngle = math.atan2(start.y - center.y, start.x - center.x);
  final endAngle = math.atan2(end.y - center.y, end.x - center.x);
  var sweep = endAngle - startAngle;
  if (hollow) {
    while (sweep < 0) {
      sweep += 2 * math.pi;
    }
    while (sweep > 2 * math.pi) {
      sweep -= 2 * math.pi;
    }
  } else {
    while (sweep > 0) {
      sweep -= 2 * math.pi;
    }
    while (sweep < -2 * math.pi) {
      sweep += 2 * math.pi;
    }
  }
  if (sweep.abs() > math.pi + 1e-8) return null;

  final tangent = startAngle + (hollow ? math.pi / 2 : -math.pi / 2);
  final points = List<KnifePoint>.generate(25, (index) {
    final angle = startAngle + sweep * index / 24;
    return KnifePoint(
      center.x + radius * math.cos(angle),
      center.y + radius * math.sin(angle),
    );
  });
  return KnifeArc(
    center: center,
    radius: radius,
    startAngleRadians: startAngle,
    sweepRadians: sweep,
    points: points,
    tangentAngleDegrees: _degrees(tangent),
  );
}

double? _circleEndX({
  required KnifePoint start,
  required double faceY,
  required double radius,
  required double tangentAngleRadians,
  required bool hollow,
}) {
  final side = hollow ? 1.0 : -1.0;
  final dy = faceY - start.y;
  final centerY = side * radius * math.cos(tangentAngleRadians);
  final radicand = radius * radius - math.pow(dy - centerY, 2);
  if (radicand < 0) return null;
  final centerX = -side * radius * math.sin(tangentAngleRadians);
  final x = centerX + math.sqrt(radicand);
  return x.isFinite ? x : null;
}

double _degrees(double radians) => radians * 180 / math.pi;
double _radians(double degrees) => degrees * math.pi / 180;

class SavedKnifeGrindingBlock {
  final String id;
  final String name;
  final double angleDegrees;
  final KnifeGrindingOrientation orientation;
  final double seatOffsetDegrees;

  const SavedKnifeGrindingBlock({
    required this.id,
    required this.name,
    required this.angleDegrees,
    required this.orientation,
    required this.seatOffsetDegrees,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'angleDegrees': angleDegrees,
    'orientation': orientation.name,
    'seatOffsetDegrees': seatOffsetDegrees,
  };

  static SavedKnifeGrindingBlock? fromJson(Object? value) {
    if (value is! Map) return null;
    final id = value['id'];
    final name = value['name'];
    final angle = value['angleDegrees'];
    final offset = value['seatOffsetDegrees'];
    if (id is! String || name is! String || angle is! num || offset is! num) {
      return null;
    }
    final orientation =
        value['orientation'] == KnifeGrindingOrientation.left.name
        ? KnifeGrindingOrientation.left
        : KnifeGrindingOrientation.right;
    return SavedKnifeGrindingBlock(
      id: id,
      name: name,
      angleDegrees: angle.toDouble(),
      orientation: orientation,
      seatOffsetDegrees: offset.toDouble(),
    );
  }
}

class KnifeGrindingBlockStore {
  static const _storageKey = 'knife_bevel_saved_blocks_v1';

  Future<List<SavedKnifeGrindingBlock>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .map(SavedKnifeGrindingBlock.fromJson)
          .whereType<SavedKnifeGrindingBlock>()
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  Future<void> save(List<SavedKnifeGrindingBlock> blocks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(blocks.map((block) => block.toJson()).toList()),
    );
  }
}
