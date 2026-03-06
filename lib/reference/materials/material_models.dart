enum MaterialCategory { steel, aluminum, plastic, wood }

enum WeldabilityRating { excellent, good, fair, poor, notRecommended }

class TempRange {
  final int? minF;
  final int? maxF;
  final int? minC;
  final int? maxC;

  const TempRange({this.minF, this.maxF, this.minC, this.maxC});
}

class StrengthProps {
  final double? yieldPsi;
  final double? tensilePsi;
  final double? yieldMpa;
  final double? tensileMpa;

  const StrengthProps({
    this.yieldPsi,
    this.tensilePsi,
    this.yieldMpa,
    this.tensileMpa,
  });
}

class HardnessRange {
  final String? scale; // "HRC", "HB", "Shore D", etc.
  final double? min;
  final double? max;

  const HardnessRange({this.scale, this.min, this.max});
}

class MachineProps {
  final int?
  machinabilityPercent; // free-machining steel = 100 baseline (optional)
  final String? sfmNotes; // "HSS 80-120 SFM, Carbide 250-400 SFM"
  final String? notes;

  const MachineProps({this.machinabilityPercent, this.sfmNotes, this.notes});
}

class HeatTreatProps {
  final TempRange? normalize;
  final TempRange? austenitize;
  final TempRange? quench;
  final TempRange? temper;
  final String? notes;

  const HeatTreatProps({
    this.normalize,
    this.austenitize,
    this.quench,
    this.temper,
    this.notes,
  });
}

class ForgeProps {
  final TempRange? forge;
  final TempRange? weldingHeat; // forge weld range (if relevant)
  final String? notes;

  const ForgeProps({this.forge, this.weldingHeat, this.notes});
}

class MaterialSpec {
  final String name; // "A36", "1018", "1095", "6061-T6", "Delrin (Acetal)"
  final MaterialCategory category;
  final String? commonUse;
  final double densityKgM3; // base storage
  final StrengthProps? strength;
  final HardnessRange? hardness;
  final MachineProps? machining;
  final WeldabilityRating? weldability;
  final String? weldNotes;
  final ForgeProps? forge;
  final HeatTreatProps? heatTreat;
  final TempRange? melting;
  final String? notes;

  const MaterialSpec({
    required this.name,
    required this.category,
    required this.densityKgM3,
    this.commonUse,
    this.strength,
    this.hardness,
    this.machining,
    this.weldability,
    this.weldNotes,
    this.forge,
    this.heatTreat,
    this.melting,
    this.notes,
  });
}
