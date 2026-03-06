import 'material_models.dart';

const materials = <MaterialSpec>[
  // ---- Steels ----
  MaterialSpec(
    name: "A36 (Structural)",
    category: MaterialCategory.steel,
    densityKgM3: 7850,
    commonUse: "Plate, structural shapes, general fabrication",
    strength: StrengthProps(yieldPsi: 36000, tensilePsi: 58000),
    hardness: HardnessRange(scale: "HB", min: 120, max: 180),
    machining: MachineProps(
      machinabilityPercent: 60,
      sfmNotes: "HSS ~80–120 SFM, Carbide ~250–400 SFM (varies)",
      notes: "Gummy vs 1018; depends heavily on mill scale & condition.",
    ),
    weldability: WeldabilityRating.excellent,
    weldNotes: "Very weldable; preheat rarely needed unless thick sections.",
    notes: "Properties vary by producer/condition; use conservative values.",
  ),

  MaterialSpec(
    name: "1018 (Mild Steel)",
    category: MaterialCategory.steel,
    densityKgM3: 7850,
    commonUse: "General machining, brackets, shafts (non-critical)",
    strength: StrengthProps(yieldPsi: 54000, tensilePsi: 64000),
    machining: MachineProps(
      machinabilityPercent: 78,
      sfmNotes: "HSS ~100–140 SFM, Carbide ~300–500 SFM",
    ),
    weldability: WeldabilityRating.excellent,
  ),

  MaterialSpec(
    name: "5160 (Spring Steel)",
    category: MaterialCategory.steel,
    densityKgM3: 7850,
    commonUse: "Springs, blades, impact tools",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "HRC", min: 52, max: 60),
    forge: ForgeProps(
      forge: TempRange(minF: 1600, maxF: 2200),
      notes: "Avoid overheating; watch decarb. Good forging steel.",
    ),
    heatTreat: HeatTreatProps(
      austenitize: TempRange(minF: 1500, maxF: 1550),
      quench: TempRange(), // you can store media in notes
      temper: TempRange(minF: 350, maxF: 500),
      notes: "Common: oil quench. Temper depends on desired hardness/toughness.",
    ),
    weldability: WeldabilityRating.fair,
    weldNotes: "Can weld with care; preheat and post-heat recommended; avoid cracking.",
  ),

  MaterialSpec(
    name: "1095 (High Carbon)",
    category: MaterialCategory.steel,
    densityKgM3: 7850,
    commonUse: "Blades, springs, high wear parts",
    hardness: HardnessRange(scale: "HRC", min: 58, max: 66),
    forge: ForgeProps(
      forge: TempRange(minF: 1500, maxF: 2000),
      notes: "Narrow forging window; easy to crack if too cold.",
    ),
    heatTreat: HeatTreatProps(
      austenitize: TempRange(minF: 1475, maxF: 1525),
      temper: TempRange(minF: 350, maxF: 450),
      notes: "Often oil or fast oil; temper based on final target hardness.",
    ),
    weldability: WeldabilityRating.poor,
    weldNotes: "Generally not recommended; high crack risk.",
  ),

  // ---- Aluminum ----
  MaterialSpec(
    name: "6061-T6",
    category: MaterialCategory.aluminum,
    densityKgM3: 2700,
    commonUse: "General structural aluminum, brackets, frames",
    strength: StrengthProps(yieldPsi: 35000, tensilePsi: 42000),
    machining: MachineProps(
      machinabilityPercent: 90,
      sfmNotes: "Carbide ~600–1200 SFM (use chip control).",
      notes: "Avoid built-up edge; use sharp tooling.",
    ),
    weldability: WeldabilityRating.good,
    weldNotes: "Weldable; loses T6 strength in HAZ unless re-heat treated.",
  ),

  MaterialSpec(
    name: "5052-H32",
    category: MaterialCategory.aluminum,
    densityKgM3: 2680,
    commonUse: "Sheet metal, bending, enclosures",
    strength: StrengthProps(yieldPsi: 28000, tensilePsi: 33000),
    machining: MachineProps(machinabilityPercent: 60),
    weldability: WeldabilityRating.excellent,
    weldNotes: "Excellent weldability; great for sheet fabrication.",
  ),

  // ---- Plastics ----
  MaterialSpec(
    name: "Delrin (Acetal / POM)",
    category: MaterialCategory.plastic,
    densityKgM3: 1410,
    commonUse: "Bushings, low-friction parts, fixtures",
    hardness: HardnessRange(scale: "Shore D", min: 80, max: 90),
    machining: MachineProps(
      machinabilityPercent: 95,
      sfmNotes: "High SFM; keep tools sharp; avoid melting (chip evacuation).",
    ),
    weldability: WeldabilityRating.notRecommended,
    weldNotes: "Not typically welded; use mechanical fastening/adhesives where appropriate.",
  ),

  MaterialSpec(
    name: "Nylon (PA6/PA66)",
    category: MaterialCategory.plastic,
    densityKgM3: 1140,
    commonUse: "Wear parts, spacers, low-friction applications",
    hardness: HardnessRange(scale: "Shore D", min: 70, max: 85),
    machining: MachineProps(
      machinabilityPercent: 80,
      notes: "Absorbs moisture; dimensions can change.",
    ),
  ),

  MaterialSpec(
    name: "ABS",
    category: MaterialCategory.plastic,
    densityKgM3: 1040,
    commonUse: "Housings, fixtures, prints (functional prototypes)",
    hardness: HardnessRange(scale: "Shore D", min: 70, max: 80),
    machining: MachineProps(notes: "Avoid heat buildup; melts/gums if tool is dull."),
  ),

  MaterialSpec(
    name: "PLA (3D Print)",
    category: MaterialCategory.plastic,
    densityKgM3: 1240,
    commonUse: "3D printed prototypes, jigs (low-temp)",
    hardness: HardnessRange(scale: "Shore D", min: 75, max: 85),
    machining: MachineProps(notes: "Brittle; better for light duty/jigs."),
  ),

  // ---- Woods ----
  MaterialSpec(
    name: "Pine (Softwood)",
    category: MaterialCategory.wood,
    densityKgM3: 500,
    commonUse: "Construction, jigs, general woodworking",
    machining: MachineProps(notes: "Easy cutting; watch tear-out with dull tools."),
    weldability: WeldabilityRating.notRecommended,
  ),

  MaterialSpec(
    name: "Oak (Hardwood)",
    category: MaterialCategory.wood,
    densityKgM3: 740,
    commonUse: "Furniture, durable structures, shop fixtures",
    machining: MachineProps(notes: "Harder; sharp tooling recommended."),
  ),
];
