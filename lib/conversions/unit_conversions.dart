import 'dart:math';

enum ConversionCategory {
  pressureAir,
  length,
  massForce,
  volume,
  temperature,
  cooking,
  electrical,
}

enum Direction { to, from }

String categoryLabel(ConversionCategory c) {
  switch (c) {
    case ConversionCategory.pressureAir:
      return "Pressure / Air";
    case ConversionCategory.length:
      return "Length";
    case ConversionCategory.massForce:
      return "Mass / Force";
    case ConversionCategory.volume:
      return "Volume";
    case ConversionCategory.temperature:
      return "Temp";
    case ConversionCategory.cooking:
      return "Cooking";
    case ConversionCategory.electrical:
      return "Electrical";
  }
}

class ConversionTool {
  final String label;
  final ConversionCategory category;
  final String toUnit;
  final String fromUnit;
  final double Function(double input) toFn;
  final double Function(double input) fromFn;

  const ConversionTool({
    required this.label,
    required this.category,
    required this.toUnit,
    required this.fromUnit,
    required this.toFn,
    required this.fromFn,
  });

  String convert(Direction direction, double input) {
    final value = direction == Direction.to ? toFn(input) : fromFn(input);
    final unit = direction == Direction.to ? toUnit : fromUnit;
    return "${value.toStringAsFixed(3)} $unit";
  }
}

final List<ConversionTool> conversionTools = [
  // Pressure / Air
  ConversionTool(
    label: "Wind Speed ↔ PSF",
    category: ConversionCategory.pressureAir,
    toUnit: "psf",
    fromUnit: "mph",
    toFn: (input) => 0.00256 * pow(input, 2).toDouble(),
    fromFn: (input) => sqrt(input / 0.00256),
  ),
  ConversionTool(
    label: "PSI ↔ PSF",
    category: ConversionCategory.pressureAir,
    toUnit: "psf",
    fromUnit: "psi",
    toFn: (input) => input * 144,
    fromFn: (input) => input / 144,
  ),
  ConversionTool(
    label: "PSF ↔ Pa",
    category: ConversionCategory.pressureAir,
    toUnit: "Pa",
    fromUnit: "psf",
    toFn: (input) => input * 47.88025898,
    fromFn: (input) => input / 47.88025898,
  ),
  ConversionTool(
    label: "CFM/ft² ↔ L/min/m²",
    category: ConversionCategory.pressureAir,
    toUnit: "L/min/m²",
    fromUnit: "CFM/ft²",
    toFn: (input) => input * 5.08,
    fromFn: (input) => input / 5.08,
  ),

  // Length
  ConversionTool(
    label: "Inches ↔ Centimeters",
    category: ConversionCategory.length,
    toUnit: "cm",
    fromUnit: "in",
    toFn: (input) => input * 2.54,
    fromFn: (input) => input / 2.54,
  ),
  ConversionTool(
    label: "Feet ↔ Inches",
    category: ConversionCategory.length,
    toUnit: "in",
    fromUnit: "ft",
    toFn: (input) => input * 12,
    fromFn: (input) => input / 12,
  ),
  ConversionTool(
    label: "Millimeters ↔ Inches",
    category: ConversionCategory.length,
    toUnit: "in",
    fromUnit: "mm",
    toFn: (input) => input / 25.4,
    fromFn: (input) => input * 25.4,
  ),
  ConversionTool(
    label: "Feet ↔ Meters",
    category: ConversionCategory.length,
    toUnit: "m",
    fromUnit: "ft",
    toFn: (input) => input * 0.3048,
    fromFn: (input) => input / 0.3048,
  ),
  ConversionTool(
    label: "Meters ↔ Yards",
    category: ConversionCategory.length,
    toUnit: "yd",
    fromUnit: "m",
    toFn: (input) => input * 1.09361,
    fromFn: (input) => input / 1.09361,
  ),

  // Mass / Force
  ConversionTool(
    label: "Kilograms ↔ Pounds",
    category: ConversionCategory.massForce,
    toUnit: "lb",
    fromUnit: "kg",
    toFn: (input) => input * 2.20462,
    fromFn: (input) => input / 2.20462,
  ),
  ConversionTool(
    label: "Newtons ↔ lbf",
    category: ConversionCategory.massForce,
    toUnit: "lbf",
    fromUnit: "N",
    toFn: (input) => input * 0.224809,
    fromFn: (input) => input / 0.224809,
  ),
  ConversionTool(
    label: "kN ↔ lbf",
    category: ConversionCategory.massForce,
    toUnit: "lbf",
    fromUnit: "kN",
    toFn: (input) => input * 224.809,
    fromFn: (input) => input / 224.809,
  ),
  ConversionTool(
    label: "Grams ↔ Ounces",
    category: ConversionCategory.massForce,
    toUnit: "oz",
    fromUnit: "g",
    toFn: (input) => input * 0.035274,
    fromFn: (input) => input / 0.035274,
  ),

  // Volume
  ConversionTool(
    label: "Liters ↔ Gallons",
    category: ConversionCategory.volume,
    toUnit: "gal",
    fromUnit: "L",
    toFn: (input) => input * 0.264172,
    fromFn: (input) => input / 0.264172,
  ),
  ConversionTool(
    label: "Milliliters ↔ Fluid Ounces",
    category: ConversionCategory.volume,
    toUnit: "fl oz",
    fromUnit: "mL",
    toFn: (input) => input * 0.033814,
    fromFn: (input) => input / 0.033814,
  ),
  ConversionTool(
    label: "Cubic Inches ↔ Liters",
    category: ConversionCategory.volume,
    toUnit: "L",
    fromUnit: "in³",
    toFn: (input) => input * 0.0163871,
    fromFn: (input) => input / 0.0163871,
  ),
  ConversionTool(
    label: "Cubic Feet ↔ Cubic Meters",
    category: ConversionCategory.volume,
    toUnit: "m³",
    fromUnit: "ft³",
    toFn: (input) => input * 0.0283168,
    fromFn: (input) => input / 0.0283168,
  ),

  // Temperature
  ConversionTool(
    label: "°F ↔ °C",
    category: ConversionCategory.temperature,
    toUnit: "°C",
    fromUnit: "°F",
    toFn: (input) => (input - 32) * 5 / 9,
    fromFn: (input) => (input * 9 / 5) + 32,
  ),
  ConversionTool(
    label: "°C ↔ K",
    category: ConversionCategory.temperature,
    toUnit: "K",
    fromUnit: "°C",
    toFn: (input) => input + 273.15,
    fromFn: (input) => input - 273.15,
  ),

  // Cooking
  ConversionTool(
    label: "Teaspoons ↔ Milliliters",
    category: ConversionCategory.cooking,
    toUnit: "mL",
    fromUnit: "tsp",
    toFn: (input) => input * 4.92892,
    fromFn: (input) => input / 4.92892,
  ),
  ConversionTool(
    label: "Tablespoons ↔ Milliliters",
    category: ConversionCategory.cooking,
    toUnit: "mL",
    fromUnit: "tbsp",
    toFn: (input) => input * 14.7868,
    fromFn: (input) => input / 14.7868,
  ),
  ConversionTool(
    label: "Cups ↔ Milliliters",
    category: ConversionCategory.cooking,
    toUnit: "mL",
    fromUnit: "cups",
    toFn: (input) => input * 236.588,
    fromFn: (input) => input / 236.588,
  ),
  ConversionTool(
    label: "Pints ↔ Liters",
    category: ConversionCategory.cooking,
    toUnit: "L",
    fromUnit: "pt",
    toFn: (input) => input * 0.473176,
    fromFn: (input) => input / 0.473176,
  ),
  ConversionTool(
    label: "Quarts ↔ Liters",
    category: ConversionCategory.cooking,
    toUnit: "L",
    fromUnit: "qt",
    toFn: (input) => input * 0.946353,
    fromFn: (input) => input / 0.946353,
  ),
  ConversionTool(
    label: "Cups ↔ Tablespoons",
    category: ConversionCategory.cooking,
    toUnit: "tbsp",
    fromUnit: "cups",
    toFn: (input) => input * 16.0,
    fromFn: (input) => input / 16.0,
  ),
  ConversionTool(
    label: "Cups ↔ Teaspoons",
    category: ConversionCategory.cooking,
    toUnit: "tsp",
    fromUnit: "cups",
    toFn: (input) => input * 48.0,
    fromFn: (input) => input / 48.0,
  ),
  ConversionTool(
    label: "Tablespoons ↔ Teaspoons",
    category: ConversionCategory.cooking,
    toUnit: "tsp",
    fromUnit: "tbsp",
    toFn: (input) => input * 3.0,
    fromFn: (input) => input / 3.0,
  ),
  ConversionTool(
    label: "Cups ↔ Pints",
    category: ConversionCategory.cooking,
    toUnit: "pt",
    fromUnit: "cups",
    toFn: (input) => input / 2.0,
    fromFn: (input) => input * 2.0,
  ),
  ConversionTool(
    label: "Cups ↔ Quarts",
    category: ConversionCategory.cooking,
    toUnit: "qt",
    fromUnit: "cups",
    toFn: (input) => input / 4.0,
    fromFn: (input) => input * 4.0,
  ),

  // Electrical
  ConversionTool(
    label: "Volts ↔ Millivolts",
    category: ConversionCategory.electrical,
    toUnit: "mV",
    fromUnit: "V",
    toFn: (input) => input * 1000.0,
    fromFn: (input) => input / 1000.0,
  ),
  ConversionTool(
    label: "Amps ↔ Milliamps",
    category: ConversionCategory.electrical,
    toUnit: "mA",
    fromUnit: "A",
    toFn: (input) => input * 1000.0,
    fromFn: (input) => input / 1000.0,
  ),
  ConversionTool(
    label: "Watts ↔ Kilowatts",
    category: ConversionCategory.electrical,
    toUnit: "kW",
    fromUnit: "W",
    toFn: (input) => input / 1000.0,
    fromFn: (input) => input * 1000.0,
  ),
  ConversionTool(
    label: "Ohms ↔ Kilohms",
    category: ConversionCategory.electrical,
    toUnit: "kΩ",
    fromUnit: "Ω",
    toFn: (input) => input / 1000.0,
    fromFn: (input) => input * 1000.0,
  ),
  ConversionTool(
    label: "Ohms ↔ Megohms",
    category: ConversionCategory.electrical,
    toUnit: "MΩ",
    fromUnit: "Ω",
    toFn: (input) => input / 1000000.0,
    fromFn: (input) => input * 1000000.0,
  ),
];
