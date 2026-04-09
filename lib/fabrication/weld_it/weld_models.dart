import 'package:flutter/foundation.dart';

/// HACKABLE:
/// Central weld material list shared by all weld calculators.
enum WeldMaterial { mildSteel, stainlessSteel, aluminum }

extension WeldMaterialX on WeldMaterial {
  String get label {
    switch (this) {
      case WeldMaterial.mildSteel:
        return 'Mild Steel';
      case WeldMaterial.stainlessSteel:
        return 'Stainless Steel';
      case WeldMaterial.aluminum:
        return 'Aluminum';
    }
  }
}

/// HACKABLE:
/// Simple preset thickness model so the UI can stay clean.
/// "inches" is used for any sorting / comparisons later if you want to expand.
@immutable
class ThicknessOption {
  final String label;
  final double inches;

  const ThicknessOption({required this.label, required this.inches});

  @override
  String toString() => label;
}

/// HACKABLE:
/// Key used for lookup tables.
@immutable
class WeldKey {
  final WeldMaterial material;
  final String thicknessLabel;

  const WeldKey({required this.material, required this.thicknessLabel});

  @override
  bool operator ==(Object other) {
    return other is WeldKey &&
        other.material == material &&
        other.thicknessLabel == thicknessLabel;
  }

  @override
  int get hashCode => Object.hash(material, thicknessLabel);
}

/// MIG recommendation model.
@immutable
class MigRecommendation {
  final String voltage;
  final String wireSpeed;
  final String wireSize;
  final String shieldingGas;
  final String polarity;
  final String notes;

  const MigRecommendation({
    required this.voltage,
    required this.wireSpeed,
    required this.wireSize,
    required this.shieldingGas,
    required this.polarity,
    required this.notes,
  });
}

/// Stick recommendation model.
@immutable
class StickRecommendation {
  final String polarity;
  final String rodChoices;
  final String amps;
  final String notes;

  const StickRecommendation({
    required this.polarity,
    required this.rodChoices,
    required this.amps,
    required this.notes,
  });
}

/// TIG recommendation model.
@immutable
class TigRecommendation {
  final String polarity;
  final String amps;
  final String tungstenType;
  final String tungstenSize;
  final String filler;
  final String notes;

  const TigRecommendation({
    required this.polarity,
    required this.amps,
    required this.tungstenType,
    required this.tungstenSize,
    required this.filler,
    required this.notes,
  });
}
