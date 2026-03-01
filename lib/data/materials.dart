enum MaterialCategory { steel, stainless, aluminum, plastic, wood }

class MaterialSpec {
  final String id;                 // "steel_mild", "al_6061", etc.
  final String name;               // display name
  final MaterialCategory category;

  // Recommended starting SFM
  final double sfmHssDrill;
  final double sfmCarbideDrill;
  final double sfmHssMill;
  final double sfmCarbideMill;

  const MaterialSpec({
    required this.id,
    required this.name,
    required this.category,
    required this.sfmHssDrill,
    required this.sfmCarbideDrill,
    required this.sfmHssMill,
    required this.sfmCarbideMill,
  });
}
