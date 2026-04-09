import 'weld_models.dart';

/// HACKABLE:
/// Shared thickness presets for all weld pages.
const List<ThicknessOption> weldThicknessOptions = [
  ThicknessOption(label: '1/16"', inches: 0.0625),
  ThicknessOption(label: '1/8"', inches: 0.1250),
  ThicknessOption(label: '3/16"', inches: 0.1875),
  ThicknessOption(label: '1/4"', inches: 0.2500),
  ThicknessOption(label: '3/8"', inches: 0.3750),
];

const List<WeldMaterial> weldMaterials = [
  WeldMaterial.mildSteel,
  WeldMaterial.stainlessSteel,
  WeldMaterial.aluminum,
];

/// ---------------------------------------------------------------------------
/// MIG DATA
/// ---------------------------------------------------------------------------
/// HACKABLE:
/// These are practical starter values, not code-book absolutes.
/// Tune them to your machines, consumables, and shop preferences.
final Map<WeldKey, MigRecommendation> migData = {
  // Mild Steel
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '1/16"',
  ): const MigRecommendation(
    voltage: '16.0 - 17.5 V',
    wireSpeed: '180 - 240 ipm',
    wireSize: '.023" or .030"',
    shieldingGas: '75/25 Ar/CO₂',
    polarity: 'DCEP',
    notes: 'Good range for thin material. Favor short circuit transfer.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '1/8"',
  ): const MigRecommendation(
    voltage: '17.5 - 19.5 V',
    wireSpeed: '240 - 320 ipm',
    wireSize: '.030"',
    shieldingGas: '75/25 Ar/CO₂',
    polarity: 'DCEP',
    notes: 'General-purpose steel setup with ER70S-6.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '3/16"',
  ): const MigRecommendation(
    voltage: '19.0 - 21.5 V',
    wireSpeed: '300 - 380 ipm',
    wireSize: '.030" or .035"',
    shieldingGas: '75/25 Ar/CO₂',
    polarity: 'DCEP',
    notes: 'Good all-around range. .035" often feels better here.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '1/4"',
  ): const MigRecommendation(
    voltage: '21.0 - 23.5 V',
    wireSpeed: '340 - 450 ipm',
    wireSize: '.035"',
    shieldingGas: '75/25 Ar/CO₂',
    polarity: 'DCEP',
    notes: 'Common fabrication range for ER70S-6 on heavier sections.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '3/8"',
  ): const MigRecommendation(
    voltage: '23.0 - 26.0 V',
    wireSpeed: '400 - 550 ipm',
    wireSize: '.035" or .045"',
    shieldingGas: '75/25 Ar/CO₂',
    polarity: 'DCEP',
    notes: 'Multiple passes likely. Consider prep and heat input.',
  ),

  // Stainless Steel
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '1/16"',
  ): const MigRecommendation(
    voltage: '16.0 - 17.5 V',
    wireSpeed: '170 - 230 ipm',
    wireSize: '.023" or .030"',
    shieldingGas: 'Tri-mix or stainless blend',
    polarity: 'DCEP',
    notes: 'ER308L is a common starting filler choice.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '1/8"',
  ): const MigRecommendation(
    voltage: '17.5 - 19.5 V',
    wireSpeed: '220 - 300 ipm',
    wireSize: '.030"',
    shieldingGas: 'Tri-mix or stainless blend',
    polarity: 'DCEP',
    notes: 'Keep heat controlled to reduce distortion and discoloration.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '3/16"',
  ): const MigRecommendation(
    voltage: '19.0 - 21.0 V',
    wireSpeed: '280 - 360 ipm',
    wireSize: '.030" or .035"',
    shieldingGas: 'Tri-mix or stainless blend',
    polarity: 'DCEP',
    notes: 'ER308L or alloy-match as needed.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '1/4"',
  ): const MigRecommendation(
    voltage: '20.5 - 22.5 V',
    wireSpeed: '320 - 420 ipm',
    wireSize: '.035"',
    shieldingGas: 'Tri-mix or stainless blend',
    polarity: 'DCEP',
    notes:
        'Use interpass control for better appearance and corrosion resistance.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '3/8"',
  ): const MigRecommendation(
    voltage: '22.0 - 25.0 V',
    wireSpeed: '380 - 500 ipm',
    wireSize: '.035" or .045"',
    shieldingGas: 'Tri-mix or stainless blend',
    polarity: 'DCEP',
    notes: 'Likely multi-pass. Verify filler family before production use.',
  ),

  // Aluminum
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '1/16"',
  ): const MigRecommendation(
    voltage: '17.0 - 19.0 V',
    wireSpeed: '250 - 350 ipm',
    wireSize: '.030"',
    shieldingGas: '100% Argon',
    polarity: 'DCEP',
    notes: 'ER4043 is a common general-purpose choice. Cleanliness matters.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '1/8"',
  ): const MigRecommendation(
    voltage: '18.5 - 21.0 V',
    wireSpeed: '325 - 450 ipm',
    wireSize: '.030" or .035"',
    shieldingGas: '100% Argon',
    polarity: 'DCEP',
    notes: 'Push technique and excellent prep help a lot.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '3/16"',
  ): const MigRecommendation(
    voltage: '20.0 - 23.0 V',
    wireSpeed: '400 - 525 ipm',
    wireSize: '.035"',
    shieldingGas: '100% Argon',
    polarity: 'DCEP',
    notes: 'ER4043 or ER5356 depending on application.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '1/4"',
  ): const MigRecommendation(
    voltage: '22.0 - 24.5 V',
    wireSpeed: '475 - 600 ipm',
    wireSize: '.035" or .047"',
    shieldingGas: '100% Argon',
    polarity: 'DCEP',
    notes: 'Heavier aluminum likes good machine output and joint prep.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '3/8"',
  ): const MigRecommendation(
    voltage: '24.0 - 27.0 V',
    wireSpeed: '550 - 700 ipm',
    wireSize: '.047"',
    shieldingGas: '100% Argon',
    polarity: 'DCEP',
    notes: 'Often multi-pass. Preheat policy depends on shop procedure.',
  ),
};

/// ---------------------------------------------------------------------------
/// STICK DATA
/// ---------------------------------------------------------------------------
final Map<WeldKey, StickRecommendation> stickData = {
  // Mild Steel
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '1/16"',
  ): const StickRecommendation(
    polarity: 'AC or DCEP',
    rodChoices: '6011 (small dia), 6013',
    amps: '35 - 65 A',
    notes: 'Very thin for stick. Use caution to avoid burn-through.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '1/8"',
  ): const StickRecommendation(
    polarity: '6010/6011: DCEP or AC, 7018: DCEP',
    rodChoices: '6010, 6011, 6013, 7018',
    amps: '75 - 110 A',
    notes: '1/8" 7018 is a common general-purpose option.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '3/16"',
  ): const StickRecommendation(
    polarity: 'DCEP preferred',
    rodChoices: '7018, 6010, 6011',
    amps: '90 - 140 A',
    notes: '7018 works well for clean shop fabrication.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '1/4"',
  ): const StickRecommendation(
    polarity: 'DCEP preferred',
    rodChoices: '7018, 6010',
    amps: '110 - 160 A',
    notes: '1/8" or 5/32" rod depending on joint and position.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '3/8"',
  ): const StickRecommendation(
    polarity: 'DCEP preferred',
    rodChoices: '7018, 6010',
    amps: '130 - 210 A',
    notes: 'Likely multiple passes for structural-quality work.',
  ),

  // Stainless Steel
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '1/16"',
  ): const StickRecommendation(
    polarity: 'DCEP',
    rodChoices: '308L-16 small dia',
    amps: '40 - 70 A',
    notes: 'Thin stainless is often better suited to TIG.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '1/8"',
  ): const StickRecommendation(
    polarity: 'DCEP',
    rodChoices: '308L-16',
    amps: '70 - 100 A',
    notes: 'Use alloy-matching rod when required by procedure.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '3/16"',
  ): const StickRecommendation(
    polarity: 'DCEP',
    rodChoices: '308L-16, 309L-16 where appropriate',
    amps: '85 - 120 A',
    notes: '309 is often chosen for dissimilar joints or buttering work.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '1/4"',
  ): const StickRecommendation(
    polarity: 'DCEP',
    rodChoices: '308L-16, 309L-16',
    amps: '95 - 135 A',
    notes: 'Control interpass heat to limit discoloration.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '3/8"',
  ): const StickRecommendation(
    polarity: 'DCEP',
    rodChoices: '308L-16, 309L-16',
    amps: '110 - 160 A',
    notes: 'Multiple passes likely. Verify filler and procedure needs.',
  ),

  // Aluminum
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '1/16"',
  ): const StickRecommendation(
    polarity: 'Specialized / uncommon',
    rodChoices: 'Aluminum stick electrodes exist but are niche',
    amps: 'Varies widely',
    notes:
        'General recommendation: use MIG or TIG instead of stick for aluminum.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '1/8"',
  ): const StickRecommendation(
    polarity: 'Specialized / uncommon',
    rodChoices: 'Aluminum stick electrodes exist but are niche',
    amps: 'Varies widely',
    notes: 'Practical shop recommendation: MIG or TIG is usually preferred.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '3/16"',
  ): const StickRecommendation(
    polarity: 'Specialized / uncommon',
    rodChoices: 'Aluminum stick electrodes exist but are niche',
    amps: 'Varies widely',
    notes: 'Most shops will choose MIG or TIG for better results.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '1/4"',
  ): const StickRecommendation(
    polarity: 'Specialized / uncommon',
    rodChoices: 'Aluminum stick electrodes exist but are niche',
    amps: 'Varies widely',
    notes: 'Use as a last-resort field process, not first-choice shop process.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '3/8"',
  ): const StickRecommendation(
    polarity: 'Specialized / uncommon',
    rodChoices: 'Aluminum stick electrodes exist but are niche',
    amps: 'Varies widely',
    notes: 'General recommendation remains MIG or TIG.',
  ),
};

/// ---------------------------------------------------------------------------
/// TIG DATA
/// ---------------------------------------------------------------------------
final Map<WeldKey, TigRecommendation> tigData = {
  // Mild Steel
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '1/16"',
  ): const TigRecommendation(
    polarity: 'DCEN',
    amps: '50 - 90 A',
    tungstenType: '2% Lanthanated',
    tungstenSize: '1/16"',
    filler: 'ER70S-2 or ER70S-6',
    notes: 'Excellent range for thin clean steel.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '1/8"',
  ): const TigRecommendation(
    polarity: 'DCEN',
    amps: '90 - 140 A',
    tungstenType: '2% Lanthanated',
    tungstenSize: '3/32"',
    filler: 'ER70S-2 or ER70S-6',
    notes: 'Good general-purpose TIG setup for mild steel.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '3/16"',
  ): const TigRecommendation(
    polarity: 'DCEN',
    amps: '130 - 180 A',
    tungstenType: '2% Lanthanated',
    tungstenSize: '3/32"',
    filler: 'ER70S-2',
    notes: '3/32" tungsten still works well in many machines at this range.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '1/4"',
  ): const TigRecommendation(
    polarity: 'DCEN',
    amps: '180 - 230 A',
    tungstenType: '2% Lanthanated',
    tungstenSize: '1/8"',
    filler: 'ER70S-2',
    notes: 'Joint prep matters a lot as thickness increases.',
  ),
  const WeldKey(
    material: WeldMaterial.mildSteel,
    thicknessLabel: '3/8"',
  ): const TigRecommendation(
    polarity: 'DCEN',
    amps: '250 - 320 A',
    tungstenType: '2% Lanthanated',
    tungstenSize: '1/8"',
    filler: 'ER70S-2',
    notes: 'Heavy section TIG. Preheat / multi-pass may be useful.',
  ),

  // Stainless
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '1/16"',
  ): const TigRecommendation(
    polarity: 'DCEN',
    amps: '45 - 85 A',
    tungstenType: '2% Lanthanated',
    tungstenSize: '1/16"',
    filler: 'ER308L',
    notes: 'Keep heat low for appearance and corrosion performance.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '1/8"',
  ): const TigRecommendation(
    polarity: 'DCEN',
    amps: '80 - 130 A',
    tungstenType: '2% Lanthanated',
    tungstenSize: '3/32"',
    filler: 'ER308L',
    notes: 'Most common starter setup for basic stainless TIG work.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '3/16"',
  ): const TigRecommendation(
    polarity: 'DCEN',
    amps: '120 - 170 A',
    tungstenType: '2% Lanthanated',
    tungstenSize: '3/32"',
    filler: 'ER308L or ER309L',
    notes: '309 may be preferred for some dissimilar joints.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '1/4"',
  ): const TigRecommendation(
    polarity: 'DCEN',
    amps: '160 - 220 A',
    tungstenType: '2% Lanthanated',
    tungstenSize: '1/8"',
    filler: 'ER308L or ER309L',
    notes: 'Use interpass control if appearance matters.',
  ),
  const WeldKey(
    material: WeldMaterial.stainlessSteel,
    thicknessLabel: '3/8"',
  ): const TigRecommendation(
    polarity: 'DCEN',
    amps: '230 - 300 A',
    tungstenType: '2% Lanthanated',
    tungstenSize: '1/8"',
    filler: 'ER308L or ER309L',
    notes: 'Heavy-section TIG. Multi-pass likely.',
  ),

  // Aluminum
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '1/16"',
  ): const TigRecommendation(
    polarity: 'AC',
    amps: '60 - 100 A',
    tungstenType: '2% Lanthanated or Zirconiated',
    tungstenSize: '1/16"',
    filler: 'ER4043 or ER5356',
    notes: 'Clean oxide thoroughly before welding.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '1/8"',
  ): const TigRecommendation(
    polarity: 'AC',
    amps: '120 - 170 A',
    tungstenType: '2% Lanthanated or Zirconiated',
    tungstenSize: '3/32"',
    filler: 'ER4043 or ER5356',
    notes: 'A very common aluminum TIG range.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '3/16"',
  ): const TigRecommendation(
    polarity: 'AC',
    amps: '170 - 220 A',
    tungstenType: '2% Lanthanated or Zirconiated',
    tungstenSize: '3/32" or 1/8"',
    filler: 'ER4043 or ER5356',
    notes: 'Machine output and AC balance settings matter more here.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '1/4"',
  ): const TigRecommendation(
    polarity: 'AC',
    amps: '220 - 300 A',
    tungstenType: '2% Lanthanated or Zirconiated',
    tungstenSize: '1/8"',
    filler: 'ER4043 or ER5356',
    notes: 'Heavy aluminum often benefits from excellent prep and fit-up.',
  ),
  const WeldKey(
    material: WeldMaterial.aluminum,
    thicknessLabel: '3/8"',
  ): const TigRecommendation(
    polarity: 'AC',
    amps: '300 - 380 A',
    tungstenType: '2% Lanthanated or Zirconiated',
    tungstenSize: '5/32"',
    filler: 'ER4043 or ER5356',
    notes: 'Very heavy TIG section. Multi-pass and high-output machine likely.',
  ),
};
