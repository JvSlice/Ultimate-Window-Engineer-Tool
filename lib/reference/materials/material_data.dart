import 'material_models.dart';

const materials = <MaterialSpec>[
  // ---- Steels ----
    // ---- Steels ----
  MaterialSpec(
    name: "A36 (Structural)",
    category: MaterialCategory.steel,
    densityKgM3: 7850,
    commonUse: "Plate, structural shapes, general fabrication",
    melting: TempRange(minF: 2590, maxF: 2660, minC: 1420, maxC: 1460),
    strength: StrengthProps(
      yieldPsi: 36000,
      tensilePsi: 58000,
    ),
    hardness: HardnessRange(scale: "HB", min: 120, max: 180),
    machining: MachineProps(
      machinabilityPercent: 60,
      sfmNotes: "HSS ~80–120 SFM, Carbide ~250–400 SFM",
      notes: "Scale and condition matter a lot; can feel gummy vs 1018.",
    ),
    weldability: WeldabilityRating.excellent,
    weldNotes: "Very weldable. Common fabrication/structural steel.",
    notes: "Use as a practical structural baseline. Actual properties vary by section/spec.",
  ),

  MaterialSpec(
    name: "1018 (Cold Drawn)",
    category: MaterialCategory.steel,
    densityKgM3: 7870,
    commonUse: "General machining, shafts, brackets, mild structural parts",
    melting: TempRange(minF: 2590, maxF: 2660, minC: 1420, maxC: 1460),
    strength: StrengthProps(
      yieldPsi: 53700,
      tensilePsi: 63800,
    ),
    hardness: HardnessRange(scale: "HB", min: 120, max: 130),
    machining: MachineProps(
      machinabilityPercent: 70,
      sfmNotes: "HSS ~100–140 SFM, Carbide ~300–500 SFM",
      notes: "Machines better than many hot-rolled mild steels.",
    ),
    weldability: WeldabilityRating.excellent,
    weldNotes: "Good weldability and easy shop use.",
    notes: "Cold-drawn values shown; hot-rolled 1018 is softer/lower strength.",
  ),

  MaterialSpec(
    name: "4140 (Normalized)",
    category: MaterialCategory.steel,
    densityKgM3: 7850,
    commonUse: "Shafts, tooling, stronger machine parts, impact-loaded components",
    melting: TempRange(minF: 2590, maxF: 2660, minC: 1420, maxC: 1460),
    strength: StrengthProps(
      yieldPsi: 95000,
      tensilePsi: 148000,
    ),
    hardness: HardnessRange(scale: "HB", min: 190, max: 230),
    machining: MachineProps(
      machinabilityPercent: 65,
      sfmNotes: "HSS ~70–110 SFM, Carbide ~220–400 SFM",
      notes: "Good all-around alloy steel. Tougher than 1018/A36.",
    ),
    heatTreat: HeatTreatProps(
      normalize: TempRange(minF: 1600, maxF: 1650),
      austenitize: TempRange(minF: 1525, maxF: 1575),
      temper: TempRange(minF: 400, maxF: 1200),
      notes: "Oil quench is common; final temper depends heavily on target hardness/toughness.",
    ),
    weldability: WeldabilityRating.fair,
    weldNotes: "Can be welded with preheat and post-weld care; crack risk is higher than mild steel.",
    notes: "Very common machine/alloy steel when you need more strength than 1018.",
  ),

  MaterialSpec(
    name: "5160 (Spring Steel)",
    category: MaterialCategory.steel,
    densityKgM3: 7850,
    commonUse: "Springs, blades, impact tools, leaf-spring repurpose stock",
    melting: TempRange(minF: 2550, maxF: 2650, minC: 1400, maxC: 1455),
    hardness: HardnessRange(scale: "HRC", min: 52, max: 60),
    machining: MachineProps(
      machinabilityPercent: 55,
      sfmNotes: "Annealed: HSS ~60–90 SFM, Carbide ~180–300 SFM",
      notes: "Machines much better annealed than hardened.",
    ),
    forge: ForgeProps(
      forge: TempRange(minF: 1600, maxF: 2200),
      notes: "Very forgable spring steel; avoid forging too cold.",
    ),
    heatTreat: HeatTreatProps(
      austenitize: TempRange(minF: 1500, maxF: 1550),
      temper: TempRange(minF: 350, maxF: 500),
      notes: "Commonly oil quenched; temper depends on desired toughness vs hardness.",
    ),
    weldability: WeldabilityRating.fair,
    weldNotes: "Weldable with care, but preheat/postheat are important and cracking is a concern.",
    notes: "Excellent toughness and popular with bladesmiths and spring applications.",
  ),

  MaterialSpec(
    name: "1095 (High Carbon)",
    category: MaterialCategory.steel,
    densityKgM3: 7850,
    commonUse: "Blades, springs, wear parts, simple high-carbon heat-treat steel",
    melting: TempRange(minF: 2760, maxF: 2760, minC: 1515, maxC: 1515),
    hardness: HardnessRange(scale: "HRC", min: 58, max: 66),
    machining: MachineProps(
      machinabilityPercent: 45,
      sfmNotes: "Annealed: HSS ~50–80 SFM, Carbide ~160–250 SFM",
      notes: "Machines much better annealed; hard condition is much less friendly.",
    ),
    forge: ForgeProps(
      forge: TempRange(minF: 1500, maxF: 2000),
      notes: "Narrower forging window than low-carbon steels; avoid overheating and over-forging cold.",
    ),
    heatTreat: HeatTreatProps(
      austenitize: TempRange(minF: 1475, maxF: 1525),
      temper: TempRange(minF: 350, maxF: 450),
      notes: "Commonly oil quenched; final hardness depends strongly on temper and section size.",
    ),
    weldability: WeldabilityRating.poor,
    weldNotes: "Generally not recommended for welding due to crack risk.",
    notes: "Simple high-carbon steel with high hardness potential and low alloy complexity.",
  ),
    MaterialSpec(
    name: "A500 Grade B",
    category: MaterialCategory.steel,
    densityKgM3: 7800,
    commonUse: "Structural tubing, frames, welded assemblies",
    melting: TempRange(minF: 2590, maxF: 2660, minC: 1420, maxC: 1460),
    strength: StrengthProps(
      yieldPsi: 45700,
      tensilePsi: 58000,
    ),
    hardness: HardnessRange(scale: "HB", min: 120, max: 180),
    machining: MachineProps(
      machinabilityPercent: 60,
      sfmNotes: "HSS ~80–120 SFM, Carbide ~250–400 SFM",
      notes: "Tubing condition and mill scale affect cutting a lot.",
    ),
    weldability: WeldabilityRating.excellent,
    weldNotes: "Very weldable structural tubing steel.",
    notes: "Good default for welded tube structures.",
  ),

  MaterialSpec(
    name: "A572 Grade 50",
    category: MaterialCategory.steel,
    densityKgM3: 7850,
    commonUse: "Higher-strength structural plate and shapes",
    melting: TempRange(minF: 2590, maxF: 2660, minC: 1420, maxC: 1460),
    strength: StrengthProps(
      yieldPsi: 50000,
      tensilePsi: 65300,
    ),
    hardness: HardnessRange(scale: "HB", min: 135, max: 190),
    machining: MachineProps(
      machinabilityPercent: 55,
      sfmNotes: "HSS ~70–110 SFM, Carbide ~220–380 SFM",
      notes: "Higher strength than A36; expect tougher cutting.",
    ),
    weldability: WeldabilityRating.good,
    weldNotes: "Good weldability with proper procedures for thickness and restraint.",
    notes: "Common upgrade from A36 when you want higher yield strength.",
  ),

  MaterialSpec(
    name: "304 Stainless (Annealed)",
    category: MaterialCategory.steel,
    densityKgM3: 8000,
    commonUse: "General corrosion-resistant parts, sheet, food/contact hardware",
    melting: TempRange(minF: 2550, maxF: 2650, minC: 1400, maxC: 1450),
    strength: StrengthProps(
      yieldPsi: 31200,
      tensilePsi: 92800,
    ),
    hardness: HardnessRange(scale: "HRB", min: 70, max: 92),
    machining: MachineProps(
      machinabilityPercent: 45,
      sfmNotes: "HSS ~40–70 SFM, Carbide ~120–250 SFM",
      notes: "Work-hardens badly. Keep feed up, tool sharp, avoid rubbing.",
    ),
    weldability: WeldabilityRating.excellent,
    weldNotes: "Very weldable; common stainless fabrication grade.",
    notes: "General-purpose austenitic stainless.",
  ),

  MaterialSpec(
    name: "316 Stainless (Annealed)",
    category: MaterialCategory.steel,
    densityKgM3: 8000,
    commonUse: "Corrosion-resistant parts, marine/chemical service, food equipment",
    melting: TempRange(minF: 2500, maxF: 2550, minC: 1370, maxC: 1400),
    strength: StrengthProps(
      yieldPsi: 42100,
      tensilePsi: 84100,
    ),
    hardness: HardnessRange(scale: "HRB", min: 75, max: 85),
    machining: MachineProps(
      machinabilityPercent: 36,
      sfmNotes: "HSS ~30–60 SFM, Carbide ~100–220 SFM",
      notes: "Tough, gummy, and work-hardening. More difficult than 304 in many shops.",
    ),
    weldability: WeldabilityRating.excellent,
    weldNotes: "Very weldable; stronger corrosion resistance than 304.",
    notes: "Preferred over 304 for chloride/corrosive environments.",
  ),

  MaterialSpec(
    name: "12L14 (Cold Drawn)",
    category: MaterialCategory.steel,
    densityKgM3: 7850,
    commonUse: "Screw machine parts, bushings, fittings, high-speed machining",
    melting: TempRange(minF: 2590, maxF: 2660, minC: 1420, maxC: 1460),
    strength: StrengthProps(
      yieldPsi: 60200,
      tensilePsi: 78300,
    ),
    hardness: HardnessRange(scale: "HB", min: 150, max: 170),
    machining: MachineProps(
      machinabilityPercent: 160,
      sfmNotes: "HSS ~150–250 SFM, Carbide ~400–700 SFM",
      notes: "Excellent machining steel. Free-machining leaded grade.",
    ),
    weldability: WeldabilityRating.poor,
    weldNotes: "Generally not recommended for welding.",
    notes: "Fantastic for lathe/mill production parts when welding is not needed.",
  ),

  MaterialSpec(
    name: "O1 Tool Steel",
    category: MaterialCategory.steel,
    densityKgM3: 7820,
    commonUse: "Knives, punches, dies, gauges, tooling",
    melting: TempRange(minF: 2590, maxF: 2660, minC: 1420, maxC: 1460),
    hardness: HardnessRange(scale: "HRC", min: 57, max: 64),
    machining: MachineProps(
      machinabilityPercent: 85,
      sfmNotes: "Annealed: HSS ~50–90 SFM, Carbide ~160–280 SFM",
      notes: "Good machinability in annealed state; oil-hardening tool steel.",
    ),
    heatTreat: HeatTreatProps(
      austenitize: TempRange(minF: 1450, maxF: 1500),
      temper: TempRange(minF: 300, maxF: 500),
      notes: "Oil-hardening tool steel. Final temper depends on desired hardness/toughness.",
    ),
    weldability: WeldabilityRating.poor,
    weldNotes: "Generally not recommended for routine welding.",
    notes: "Good dimensional stability and a classic general-purpose tool steel.",
  ),

  MaterialSpec(
    name: "D2 Tool Steel",
    category: MaterialCategory.steel,
    densityKgM3: 7700,
    commonUse: "Wear parts, dies, punches, blades, abrasion-resistant tooling",
    melting: TempRange(minF: 2550, maxF: 2600, minC: 1400, maxC: 1430),
    hardness: HardnessRange(scale: "HRC", min: 60, max: 64),
    machining: MachineProps(
      machinabilityPercent: 55,
      sfmNotes: "Annealed: HSS ~40–70 SFM, Carbide ~120–220 SFM",
      notes: "Much easier to machine annealed than hardened. High wear resistance.",
    ),
    heatTreat: HeatTreatProps(
      austenitize: TempRange(minF: 1800, maxF: 1900),
      temper: TempRange(minF: 300, maxF: 1000),
      notes: "Air-hardening high-carbon high-chromium tool steel.",
    ),
    weldability: WeldabilityRating.poor,
    weldNotes: "Generally not recommended except specialized repair procedures.",
    notes: "Great wear resistance, lower toughness than O1/5160.",
  ),

  
    // ---- Aluminum ----
  MaterialSpec(
    name: "6063-T5",
    category: MaterialCategory.aluminum,
    densityKgM3: 2700,
    commonUse: "Architectural extrusions, window/door framing, railings, trim",
    melting: TempRange(minF: 1140, maxF: 1210, minC: 616, maxC: 654),
    strength: StrengthProps(
      yieldPsi: 16000,
      tensilePsi: 22000,
    ),
    hardness: HardnessRange(scale: "HB", min: 55, max: 65),
    machining: MachineProps(
      machinabilityPercent: 70,
      sfmNotes: "Carbide ~600–1200 SFM, HSS ~200–400 SFM",
      notes: "Extrudes very well, good finish/anodizing response, not as strong as T6.",
    ),
    weldability: WeldabilityRating.good,
    weldNotes: "Weldable, but like other heat-treated aluminums, strength drops in the HAZ.",
    notes: "Good corrosion resistance. Common architectural alloy.",
  ),

  MaterialSpec(
    name: "6063-T6",
    category: MaterialCategory.aluminum,
    densityKgM3: 2700,
    commonUse: "Stronger architectural extrusions, rails, tubing, light structural shapes",
    melting: TempRange(minF: 1140, maxF: 1210, minC: 616, maxC: 654),
    strength: StrengthProps(
      yieldPsi: 25000,
      tensilePsi: 30000,
    ),
    hardness: HardnessRange(scale: "HB", min: 70, max: 80),
    machining: MachineProps(
      machinabilityPercent: 75,
      sfmNotes: "Carbide ~600–1200 SFM, HSS ~200–400 SFM",
      notes: "Stronger than T5, still good finish and corrosion resistance.",
    ),
    weldability: WeldabilityRating.good,
    weldNotes: "Weldable; expect heat-affected zone softening unless re-heat treated.",
    notes: "Typical 6063-T6 values depend on section thickness.",
  ),

  MaterialSpec(
    name: "6005A-T6",
    category: MaterialCategory.aluminum,
    densityKgM3: 2710,
    commonUse: "Structural extrusions, transport, ladders, framing, stronger profiles",
    melting: TempRange(minF: 1085, maxF: 1202, minC: 585, maxC: 650),
    strength: StrengthProps(
      yieldPsi: 32000,
      tensilePsi: 38000,
    ),
    hardness: HardnessRange(scale: "HB", min: 75, max: 90),
    machining: MachineProps(
      machinabilityPercent: 70,
      sfmNotes: "Carbide ~500–1000 SFM, HSS ~180–350 SFM",
      notes: "Good extrusion alloy with better structural strength than 6063.",
    ),
    weldability: WeldabilityRating.good,
    weldNotes: "Good corrosion resistance and reasonable weldability; strength loss in HAZ applies.",
    notes: "Medium-strength, heat-treatable structural extrusion alloy.",
  ),

  MaterialSpec(
    name: "6061-T6",
    category: MaterialCategory.aluminum,
    densityKgM3: 2700,
    commonUse: "General structural aluminum, brackets, machine parts, frames",
    melting: TempRange(minF: 1080, maxF: 1205, minC: 582, maxC: 652),
    strength: StrengthProps(
      yieldPsi: 35000,
      tensilePsi: 42000,
    ),
    hardness: HardnessRange(scale: "HB", min: 90, max: 100),
    machining: MachineProps(
      machinabilityPercent: 90,
      sfmNotes: "Carbide ~600–1200 SFM, HSS ~200–400 SFM",
      notes: "Very common general-purpose alloy; good balance of strength and machinability.",
    ),
    weldability: WeldabilityRating.good,
    weldNotes: "Weldable, but T6 properties are reduced in the heat-affected zone.",
  ),

  MaterialSpec(
    name: "5052-H32",
    category: MaterialCategory.aluminum,
    densityKgM3: 2680,
    commonUse: "Sheet metal, bent parts, enclosures, marine/light corrosion service",
    melting: TempRange(minF: 1125, maxF: 1200, minC: 607, maxC: 649),
    strength: StrengthProps(
      yieldPsi: 28000,
      tensilePsi: 33000,
    ),
    hardness: HardnessRange(scale: "HB", min: 60, max: 70),
    machining: MachineProps(
      machinabilityPercent: 60,
      sfmNotes: "Carbide ~500–1000 SFM, HSS ~150–300 SFM",
      notes: "Best known for formability and corrosion resistance more than machining.",
    ),
    weldability: WeldabilityRating.excellent,
    weldNotes: "Excellent weldability; strong choice for sheet fabrication.",
  ),

  MaterialSpec(
    name: "7075-T6",
    category: MaterialCategory.aluminum,
    densityKgM3: 2810,
    commonUse: "High-strength parts, fixtures, aerospace-style hardware",
    melting: TempRange(minF: 890, maxF: 1175, minC: 477, maxC: 635),
    strength: StrengthProps(
      yieldPsi: 73000,
      tensilePsi: 83000,
    ),
    hardness: HardnessRange(scale: "HB", min: 140, max: 160),
    machining: MachineProps(
      machinabilityPercent: 70,
      sfmNotes: "Carbide ~400–900 SFM, HSS ~120–250 SFM",
      notes: "Very strong, machines well, but poorer corrosion/weld behavior than 6xxx.",
    ),
    weldability: WeldabilityRating.poor,
    weldNotes: "Generally not recommended for welding.",
  ),

  // ---- Plastics ----
  MaterialSpec(
    name: "Delrin (Acetal / POM)",
    category: MaterialCategory.plastic,
    densityKgM3: 1420,
    commonUse: "Bushings, gears, low-friction parts, fixtures, wear strips",
    melting: TempRange(minF: 352, maxF: 352, minC: 178, maxC: 178),
    strength: StrengthProps(
      yieldPsi: 10150,
      yieldMpa: 70.0,
    ),
    hardness: HardnessRange(scale: "Shore D", min: 80, max: 90),
    machining: MachineProps(
      machinabilityPercent: 95,
      sfmNotes: "High SFM with sharp tooling; avoid heat buildup and stringy chips.",
      notes: "Excellent machining plastic. Very dimensionally stable and low friction.",
    ),
    weldability: WeldabilityRating.notRecommended,
    weldNotes: "Usually machined or mechanically fastened rather than welded.",
    notes: "Great default engineering plastic when you want strength + machinability.",
  ),

  MaterialSpec(
    name: "Nylon 6/6",
    category: MaterialCategory.plastic,
    densityKgM3: 1140,
    commonUse: "Bushings, wear pads, spacers, rollers, impact-resistant parts",
    melting: TempRange(minF: 365, maxF: 504, minC: 185, maxC: 262),
    strength: StrengthProps(
      tensilePsi: 9240,
      tensileMpa: 63.7,
    ),
    hardness: HardnessRange(scale: "Shore D", min: 70, max: 85),
    machining: MachineProps(
      machinabilityPercent: 80,
      sfmNotes: "Sharp tools, moderate-to-high SFM, avoid heat and support flexible parts.",
      notes: "Absorbs moisture, so dimensions can change. Tough and wear-resistant.",
    ),
    weldability: WeldabilityRating.notRecommended,
    weldNotes: "Typically machined or mechanically fastened.",
    notes: "Use when toughness matters more than absolute stiffness.",
  ),

  MaterialSpec(
    name: "ABS",
    category: MaterialCategory.plastic,
    densityKgM3: 1040,
    commonUse: "Housings, covers, printed parts, light fixtures, prototyping",
    strength: StrengthProps(
      yieldPsi: 8600,
      yieldMpa: 59.3,
    ),
    hardness: HardnessRange(scale: "Shore D", min: 70, max: 80),
    machining: MachineProps(
      machinabilityPercent: 70,
      sfmNotes: "Use sharp tools and avoid melting/gumming.",
      notes: "Easy to work, but heat buildup can rough up the finish.",
    ),
    weldability: WeldabilityRating.fair,
    weldNotes: "Plastic welding is possible on some ABS forms, depending on setup and part.",
    notes: "No clean true melt point like crystalline plastics; Tg is around 108–109 °C (226–228 °F).",
  ),

  MaterialSpec(
    name: "PLA",
    category: MaterialCategory.plastic,
    densityKgM3: 1240,
    commonUse: "3D printed prototypes, jigs, fixtures, low-temp parts",
    melting: TempRange(minF: 147, maxF: 428, minC: 64, maxC: 220),
    strength: StrengthProps(
      yieldPsi: 6550,
      yieldMpa: 45.2,
    ),
    hardness: HardnessRange(scale: "Shore D", min: 75, max: 85),
    machining: MachineProps(
      machinabilityPercent: 65,
      sfmNotes: "Light cuts, sharp tools, avoid heat.",
      notes: "Brittle compared with ABS/PETG; heat resistance is limited.",
    ),
    weldability: WeldabilityRating.notRecommended,
    weldNotes: "Usually printed, bonded, or mechanically fastened instead of welded.",
    notes: "Property ranges vary a lot between filament brands and print orientation.",
  ),

  MaterialSpec(
    name: "Polycarbonate (PC)",
    category: MaterialCategory.plastic,
    densityKgM3: 1200,
    commonUse: "Guards, impact-resistant covers, clear machine shields",
    strength: StrengthProps(
      yieldPsi: 9060,
      yieldMpa: 62.5,
    ),
    hardness: HardnessRange(scale: "Shore D", min: 75, max: 80),
    machining: MachineProps(
      machinabilityPercent: 70,
      sfmNotes: "Sharp tools, moderate SFM, avoid heat cracking and melting.",
      notes: "Very tough and impact resistant. Better for guards than acrylic in many cases.",
    ),
    weldability: WeldabilityRating.fair,
    weldNotes: "Plastic welding is possible in some cases, but fabrication is often mechanical.",
    notes: "Use Tg/softening behavior rather than a simple melt point; Tg is commonly around 146 °C (295 °F).",
  ),

  MaterialSpec(
    name: "PETG",
    category: MaterialCategory.plastic,
    densityKgM3: 1270,
    commonUse: "Printed parts, clear guards, thermoformed parts, general prototypes",
    strength: StrengthProps(
      yieldPsi: 6960,
      yieldMpa: 48.0,
    ),
    hardness: HardnessRange(scale: "Shore D", min: 70, max: 80),
    machining: MachineProps(
      machinabilityPercent: 70,
      sfmNotes: "Sharp tools, moderate SFM, avoid rubbing and heat buildup.",
      notes: "Good middle ground between PLA ease and ABS toughness.",
    ),
    weldability: WeldabilityRating.fair,
    weldNotes: "Not a common structural welding plastic in shop use.",
    notes: "Often treated more by Tg/softening than a single true melt point in shop reference use.",
  ),

  MaterialSpec(
    name: "HDPE",
    category: MaterialCategory.plastic,
    densityKgM3: 950,
    commonUse: "Cutting boards, tanks, wear surfaces, chemical-resistant parts",
    melting: TempRange(minF: 244, maxF: 279, minC: 118, maxC: 137),
    strength: StrengthProps(
      yieldPsi: 3800,
      yieldMpa: 26.2,
    ),
    hardness: HardnessRange(scale: "Shore D", min: 60, max: 70),
    machining: MachineProps(
      machinabilityPercent: 85,
      sfmNotes: "High SFM possible, but support the work and control chip/stringing.",
      notes: "Soft, tough, and slippery. Great chemical resistance.",
    ),
    weldability: WeldabilityRating.good,
    weldNotes: "Can be plastic welded in many fabrication contexts.",
    notes: "Common utility plastic; softer and less stiff than acetal.",
  ),

  MaterialSpec(
    name: "UHMW-PE",
    category: MaterialCategory.plastic,
    densityKgM3: 930,
    commonUse: "Wear strips, sliders, low-friction liners, impact/abrasion parts",
    melting: TempRange(minF: 271, maxF: 271, minC: 133, maxC: 133),
    strength: StrengthProps(
      yieldPsi: 2900,
      yieldMpa: 20.0,
    ),
    hardness: HardnessRange(scale: "Shore D", min: 63, max: 70),
    machining: MachineProps(
      machinabilityPercent: 85,
      sfmNotes: "Machines easily but can deflect; use sharp tools and good support.",
      notes: "Very slippery and impact resistant, but not very stiff.",
    ),
    weldability: WeldabilityRating.fair,
    weldNotes: "Can be welded in some plastic-fabrication processes.",
    notes: "Excellent wear material; not great when tight stiffness/tolerance is required.",
  ),

  MaterialSpec(
    name: "PVC (Rigid)",
    category: MaterialCategory.plastic,
    densityKgM3: 1400,
    commonUse: "Piping, guards, utility panels, chemical-resistant sheet",
    strength: StrengthProps(
      yieldPsi: 6150,
      yieldMpa: 42.4,
    ),
    hardness: HardnessRange(scale: "Shore D", min: 75, max: 85),
    machining: MachineProps(
      machinabilityPercent: 75,
      sfmNotes: "Sharp tools, moderate SFM, avoid heat and burning.",
      notes: "Rigid PVC machines fairly well in sheet/rod form.",
    ),
    weldability: WeldabilityRating.good,
    weldNotes: "PVC sheet and pipe can be plastic welded in fabrication settings.",
    notes: "Better treated by softening/Tg behavior than a clean metal-style melt point in a quick reference page.",
  ),
  
  // ---- Woods ----
  
  MaterialSpec(
    name: "Pine (Eastern White Pine)",
    category: MaterialCategory.wood,
    densityKgM3: 400,
    commonUse: "Construction, jigs, general woodworking, light-duty fixtures",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "Janka lbf", min: 380, max: 380),
    machining: MachineProps(
      machinabilityPercent: 85,
      sfmNotes: "Very easy to cut; sharp tools reduce tear-out and fuzzy grain.",
      notes: "Soft, light, easy to work. Watch denting and compression under clamps.",
    ),
    weldability: WeldabilityRating.notRecommended,
    notes: "Good utility wood when weight and cost matter more than wear resistance.",
  ),

  MaterialSpec(
    name: "Cedar (Western Red Cedar)",
    category: MaterialCategory.wood,
    densityKgM3: 380,
    commonUse: "Outdoor projects, trim, weather-resistant parts, light structures",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "Janka lbf", min: 350, max: 350),
    machining: MachineProps(
      machinabilityPercent: 85,
      sfmNotes: "Cuts easily; soft fibers can crush or fuzz with dull tooling.",
      notes: "Lightweight, rot resistant, easy to machine, but not a high-strength wood.",
    ),
    weldability: WeldabilityRating.notRecommended,
    notes: "Good for outdoor utility use; softer and weaker than most hardwoods.",
  ),

  MaterialSpec(
    name: "Poplar (Yellow Poplar / Tulipwood)",
    category: MaterialCategory.wood,
    densityKgM3: 450,
    commonUse: "Paint-grade parts, drawer parts, templates, general shop builds",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "Janka lbf", min: 540, max: 540),
    machining: MachineProps(
      machinabilityPercent: 85,
      sfmNotes: "Easy machining; cuts cleanly with sharp tools.",
      notes: "A very friendly hardwood for general shop use, but not highly wear resistant.",
    ),
    weldability: WeldabilityRating.notRecommended,
    notes: "Great low-cost hardwood for utility parts and paint-grade projects.",
  ),

  MaterialSpec(
    name: "Birch (Yellow Birch)",
    category: MaterialCategory.wood,
    densityKgM3: 670,
    commonUse: "Cabinet parts, jigs, fixtures, handles, shop furniture",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "Janka lbf", min: 1260, max: 1260),
    machining: MachineProps(
      machinabilityPercent: 75,
      sfmNotes: "Machines well; sharp tooling helps reduce burn and tear-out.",
      notes: "Dense and stable enough for many shop fixtures and working surfaces.",
    ),
    weldability: WeldabilityRating.notRecommended,
    notes: "Good balance of hardness, cost, and workability.",
  ),

  MaterialSpec(
    name: "Maple (Hard Maple)",
    category: MaterialCategory.wood,
    densityKgM3: 705,
    commonUse: "Benchtops, fixtures, wear surfaces, blocks, tooling bases",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "Janka lbf", min: 1450, max: 1450),
    machining: MachineProps(
      machinabilityPercent: 70,
      sfmNotes: "Machines well with sharp tools; can burn if feeds are too light.",
      notes: "Hard, dense, and durable. Excellent for wear-resistant wood parts.",
    ),
    weldability: WeldabilityRating.notRecommended,
    notes: "Very good shop wood when you need stiffness and surface durability.",
  ),

  MaterialSpec(
    name: "Cherry (Black Cherry)",
    category: MaterialCategory.wood,
    densityKgM3: 560,
    commonUse: "Furniture, handles, trim, shop projects where clean finish matters",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "Janka lbf", min: 950, max: 950),
    machining: MachineProps(
      machinabilityPercent: 80,
      sfmNotes: "Machines very nicely; sands and finishes well.",
      notes: "Stable and pleasant to work, with lower wear resistance than maple or oak.",
    ),
    weldability: WeldabilityRating.notRecommended,
    notes: "Excellent finish wood and still useful for many durable shop parts.",
  ),

  MaterialSpec(
    name: "Walnut (Black Walnut)",
    category: MaterialCategory.wood,
    densityKgM3: 610,
    commonUse: "Furniture, tool handles, trim, medium-duty fixtures",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "Janka lbf", min: 1010, max: 1010),
    machining: MachineProps(
      machinabilityPercent: 80,
      sfmNotes: "Machines cleanly and predictably with sharp tooling.",
      notes: "Good balance of strength, stability, and workability.",
    ),
    weldability: WeldabilityRating.notRecommended,
    notes: "Great all-around hardwood for attractive and durable projects.",
  ),

  MaterialSpec(
    name: "Ash (White Ash)",
    category: MaterialCategory.wood,
    densityKgM3: 690,
    commonUse: "Tool handles, impact-resistant parts, shop handles, bats, shafts",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "Janka lbf", min: 1320, max: 1320),
    machining: MachineProps(
      machinabilityPercent: 75,
      sfmNotes: "Machines well; good choice where toughness matters.",
      notes: "Excellent shock resistance. Great for handles and impact-use parts.",
    ),
    weldability: WeldabilityRating.notRecommended,
    notes: "One of the best woods for handles and parts that see repeated shock.",
  ),

  MaterialSpec(
    name: "Oak (Red Oak)",
    category: MaterialCategory.wood,
    densityKgM3: 700,
    commonUse: "Benches, fixtures, furniture, tough general shop parts",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "Janka lbf", min: 1220, max: 1220),
    machining: MachineProps(
      machinabilityPercent: 70,
      sfmNotes: "Machines well but open grain can splinter/tear with dull tooling.",
      notes: "Strong and common. Open grain can affect finish and edge behavior.",
    ),
    weldability: WeldabilityRating.notRecommended,
    notes: "A solid general hardwood when you want toughness and availability.",
  ),

  MaterialSpec(
    name: "Oak (White Oak)",
    category: MaterialCategory.wood,
    densityKgM3: 770,
    commonUse: "Heavy-duty fixtures, outdoor projects, durable furniture, wear parts",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "Janka lbf", min: 1360, max: 1360),
    machining: MachineProps(
      machinabilityPercent: 68,
      sfmNotes: "Machines well with sharp tooling; denser and tougher than red oak.",
      notes: "Closed pores improve moisture resistance compared with red oak.",
    ),
    weldability: WeldabilityRating.notRecommended,
    notes: "Excellent durable hardwood when you want weight, hardness, and weather resistance.",
  ),

  MaterialSpec(
    name: "Hickory",
    category: MaterialCategory.wood,
    densityKgM3: 830,
    commonUse: "Hammer handles, axe handles, impact tools, very tough wear parts",
    strength: StrengthProps(),
    hardness: HardnessRange(scale: "Janka lbf", min: 1820, max: 1820),
    machining: MachineProps(
      machinabilityPercent: 60,
      sfmNotes: "Tough cutting; use sharp tools, firm setup, and expect higher cutting force.",
      notes: "Extremely tough and shock resistant, but harder on tooling than many woods.",
    ),
    weldability: WeldabilityRating.notRecommended,
    notes: "Top-tier handle wood when you want shock resistance and toughness.",
  ),
];

