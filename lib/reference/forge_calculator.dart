import '../conversions/unit_conversions.dart';

enum ForgeUnitSystem { imperial, metric }

extension ForgeUnitSystemLabel on ForgeUnitSystem {
  String get lengthUnit => this == ForgeUnitSystem.imperial ? 'in' : 'mm';
  String get volumeUnit => this == ForgeUnitSystem.imperial ? 'in³' : 'mm³';
}

class ForgeResult {
  final double finishedVolume;
  final double theoreticalLength;
  final double recommendedLength;

  const ForgeResult({
    required this.finishedVolume,
    required this.theoreticalLength,
    required this.recommendedLength,
  });

  double get additionalLength => recommendedLength - theoreticalLength;
}

/// Dimensions must use the same length unit. The result uses that unit and
/// its cubic equivalent; loss is a percent of the starting stock volume.
ForgeResult? calculateForgeCutoff({
  required double finishedHeight,
  required double finishedWidth,
  required double finishedLength,
  required double stockHeight,
  required double stockWidth,
  required double lossPercent,
}) {
  final dimensions = [
    finishedHeight,
    finishedWidth,
    finishedLength,
    stockHeight,
    stockWidth,
  ];
  if (dimensions.any((value) => !value.isFinite || value <= 0) ||
      !lossPercent.isFinite ||
      lossPercent < 0 ||
      lossPercent >= 100) {
    return null;
  }

  final volume = finishedHeight * finishedWidth * finishedLength;
  final theoretical = volume / (stockHeight * stockWidth);
  final recommended = theoretical / (1 - lossPercent / 100);
  if (!volume.isFinite || !theoretical.isFinite || !recommended.isFinite) {
    return null;
  }
  return ForgeResult(
    finishedVolume: volume,
    theoreticalLength: theoretical,
    recommendedLength: recommended,
  );
}

double convertForgeLength(
  double value,
  ForgeUnitSystem from,
  ForgeUnitSystem to,
) {
  if (from == to) return value;
  return from == ForgeUnitSystem.imperial
      ? inchesToMillimeters(value)
      : millimetersToInches(value);
}

/// Accept decimal values in either system and common shop fractions in inches.
double? parseForgeDimension(String text, ForgeUnitSystem units) {
  final input = text.trim();
  final decimal = double.tryParse(input);
  if (decimal != null) return decimal;
  if (units != ForgeUnitSystem.imperial) return null;

  final match = RegExp(r'^(?:(\d+)\s+)?(\d+)\s*/\s*(\d+)$').firstMatch(input);
  if (match == null) return null;
  final whole = int.tryParse(match.group(1) ?? '0');
  final numerator = int.tryParse(match.group(2)!);
  final denominator = int.tryParse(match.group(3)!);
  if (whole == null ||
      numerator == null ||
      denominator == null ||
      denominator == 0) {
    return null;
  }
  return whole + numerator / denominator;
}

/// Shop approximation to the nearest 1/64 inch. Decimal values remain primary.
String formatForgeFraction(double inches) {
  final whole = inches.floor();
  final numerator = ((inches - whole) * 64).round();
  if (numerator == 0) return '$whole';
  if (numerator == 64) return '${whole + 1}';
  var divisor = 1;
  for (var candidate = 2; candidate <= 64; candidate *= 2) {
    if (numerator % candidate == 0) divisor = candidate;
  }
  final fraction = '${numerator ~/ divisor}/${64 ~/ divisor}';
  return whole == 0 ? fraction : '$whole $fraction';
}
