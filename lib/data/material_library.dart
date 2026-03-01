import 'materials.dart';

const List<MaterialSpec> materialLibrary = [
  // STEEL
  MaterialSpec(
    id: "steel_mild",
    name: "Mild Steel (1018/1020)",
    category: MaterialCategory.steel,
    sfmHssDrill: 80,
    sfmCarbideDrill: 250,
    sfmHssMill: 90,
    sfmCarbideMill: 300,
  ),
  MaterialSpec(
    id: "steel_alloy",
    name: "Alloy Steel (4140 prehard)",
    category: MaterialCategory.steel,
    sfmHssDrill: 50,
    sfmCarbideDrill: 180,
    sfmHssMill: 60,
    sfmCarbideMill: 220,
  ),

  // STAINLESS
  MaterialSpec(
    id: "ss_304",
    name: "304 Stainless",
    category: MaterialCategory.stainless,
    sfmHssDrill: 40,
    sfmCarbideDrill: 150,
    sfmHssMill: 50,
    sfmCarbideMill: 180,
  ),
  MaterialSpec(
    id: "ss_316",
    name: "316 Stainless",
    category: MaterialCategory.stainless,
    sfmHssDrill: 35,
    sfmCarbideDrill: 140,
    sfmHssMill: 45,
    sfmCarbideMill: 170,
  ),

  // ALUMINUM
  MaterialSpec(
    id: "al_6061",
    name: "6061 Aluminum",
    category: MaterialCategory.aluminum,
    sfmHssDrill: 250,
    sfmCarbideDrill: 800,
    sfmHssMill: 300,
    sfmCarbideMill: 900,
  ),
  MaterialSpec(
    id: "al_7075",
    name: "7075 Aluminum",
    category: MaterialCategory.aluminum,
    sfmHssDrill: 200,
    sfmCarbideDrill: 700,
    sfmHssMill: 250,
    sfmCarbideMill: 800,
  ),

  // PLASTIC
  MaterialSpec(
    id: "plastic_general",
    name: "Plastic (general)",
    category: MaterialCategory.plastic,
    sfmHssDrill: 200,
    sfmCarbideDrill: 600,
    sfmHssMill: 250,
    sfmCarbideMill: 700,
  ),

  // WOOD
  MaterialSpec(
    id: "wood_hard",
    name: "Hardwood",
    category: MaterialCategory.wood,
    sfmHssDrill: 300,
    sfmCarbideDrill: 800,
    sfmHssMill: 400,
    sfmCarbideMill: 1000,
  ),
];
