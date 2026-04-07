import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/window_testing_tools_page.dart';

import 'app_theme.dart';
import 'convert_it_page.dart';
import 'conversions/unit_conversions.dart';
import 'fabricate_it_page.dart';
import 'fun_links_page.dart';
import 'settings_page.dart';
import 'terminal_scaffold.dart';

// Hubs
import 'reference/reference_home_page.dart';

// Fabrication
import 'fabrication/drill_index_page.dart';
import 'fabrication/drill_tap_Selector_page.dart';
import 'fabrication/fraction_decimal_page.dart';
import 'fabrication/speed_feed_page.dart';
import 'fabrication/weld_it_page.dart';
import 'fabrication/shielding_gas_page.dart';
import 'fabrication/stick_rod_page.dart';
import 'fabrication/tig_amp_page.dart';
import 'fabrication/tig_tungsten_page.dart';

// Window testing
import 'window_testing_tools/astm_e1300_page.dart';
import 'window_testing_tools/glass_deflection_page.dart';
import 'window_testing_tools/rating_reference_page.dart';
import 'window_testing_tools/structural_test_math_page.dart';
import 'window_testing_tools/test_sequence_reference_page.dart';

// Reference
import 'reference/geometry_page.dart';
import 'reference/geometry_2d_page.dart';
import 'reference/geometry_3d_page.dart';
import 'reference/geometry_shop_page.dart';
import 'reference/physics_equations_page.dart';
import 'reference/materials/material_reference_page.dart';
import 'reference/eletrical_tools/eletrical_reference_page.dart';
import 'reference/eletrical_tools/ohms_law_page.dart';
import 'reference/eletrical_tools/power_law_page.dart';
import 'reference/eletrical_tools/voltage_divider_page.dart';
import 'reference/eletrical_tools/awg_reference_page.dart';
import 'reference/eletrical_tools/battery_runtime_page.dart';
import 'reference/physics/cantilever_beam_page.dart';
import 'reference/physics/pulleys_page.dart';
import 'reference/physics/section_i_page.dart';
import 'reference/physics/torque_power_page.dart';
import 'reference/physics/velocity_page.dart';
import 'reference/shapes/circle_page.dart';
import 'reference/shapes/rect_page.dart';
import 'reference/shapes/right_triangle_page.dart';
import 'reference/shapes/trapezoid_page.dart';
import 'reference/shapes/annulus_page.dart';
import 'reference/shapes/triangle_solver_page.dart';
import 'reference/shapes3d/box_page.dart';
import 'reference/shapes3d/cone_page.dart';
import 'reference/shapes3d/cylinder_page.dart';
import 'reference/shapes3d/pipe_page.dart';
import 'reference/shapes3d/sphere_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = AppThemeController();
  await themeController.load();

  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final AppThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeController.buildTerminalTheme(
            themeController.accentColor,
          ),
          home: MainMenuPage(themeController: themeController),
        );
      },
    );
  }
}

class MainMenuPage extends StatefulWidget {
  final AppThemeController themeController;

  const MainMenuPage({super.key, required this.themeController});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });

    if (_showSearch) {
      Future.delayed(const Duration(milliseconds: 40), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    } else {
      _searchFocusNode.unfocus();
      _searchController.clear();
    }
  }

  void _closeSearch() {
    setState(() {
      _showSearch = false;
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
  }

  void _openTarget(_SearchTarget target) {
    _closeSearch();
    openPage(context, target.builder(context));
  }

  List<_SearchTarget> _buildTargets() {
    return [
      // Main hubs
      _SearchTarget(
        label: 'Convert It',
        subtitle: 'Unit conversion hub',
        keywords: [
          'convert',
          'conversion',
          'units',
          'psi',
          'psf',
          'kpa',
          'pa',
          'length',
          'area',
          'volume',
          'temperature',
          'speed',
          'torque',
          'electrical',
        ],
        builder: (_) => const ConverItPage(),
      ),
      _SearchTarget(
        label: 'Fabricate It',
        subtitle: 'Fabrication tools hub',
        keywords: ['fabricate', 'fabrication', 'shop', 'machining', 'metal'],
        builder: (_) => const FabricateItPage(),
      ),
      _SearchTarget(
        label: 'Reference It',
        subtitle: 'Reference hub',
        keywords: [
          'reference',
          'library',
          'lookup',
          'equations',
          'geometry',
          'materials',
          'electrical',
        ],
        builder: (_) => const ReferenceHomePage(),
      ),
      _SearchTarget(
        label: 'Window Testing Tools',
        subtitle: 'Testing tools hub',
        keywords: [
          'window testing',
          'test',
          'testing',
          'glass',
          'deflection',
          'rating',
          'sequence',
          'structural',
          'e1300',
        ],
        builder: (_) => const WindowTestingToolsPage(),
      ),

      // Fabrication
      _SearchTarget(
        label: 'Drill Index',
        subtitle: 'Letter / Number / Fractional',
        keywords: ['drill', 'index', 'bit', 'fractional drill', 'letter drill'],
        builder: (_) => const DrillIndexPage(),
      ),
      _SearchTarget(
        label: 'Drill & Tap Selector',
        subtitle: 'Tap drill, clearance, engagement',
        keywords: [
          'tap',
          'tap drill',
          'drill tap',
          'clearance',
          'engagement',
          'thread',
          'threads',
          'hole',
        ],
        builder: (_) => const DrillTapSelectorPage(),
      ),
      _SearchTarget(
        label: 'Speed & Feeds',
        subtitle: 'RPM / IPM calculator',
        keywords: ['speed', 'feed', 'feeds', 'rpm', 'ipm', 'sfm'],
        builder: (_) => const SpeedFeedPage(),
      ),
      _SearchTarget(
        label: 'Weld It',
        subtitle: 'Welding settings and references',
        keywords: ['weld', 'welding', 'mig', 'tig', 'stick'],
        builder: (_) => const WeldItPage(),
      ),
      _SearchTarget(
        label: 'TIG Amps',
        subtitle: 'TIG amperage reference',
        keywords: ['tig amps', 'tig amp', 'amperage'],
        builder: (_) => const TigAmpsPage(),
      ),
      _SearchTarget(
        label: 'TIG Tungsten',
        subtitle: 'TIG tungsten reference',
        keywords: ['tig tungsten', 'tungsten', 'electrode'],
        builder: (_) => const TigTungstenPage(),
      ),
      _SearchTarget(
        label: 'Shielding Gas',
        subtitle: 'Shielding gas reference',
        keywords: ['shielding gas', 'argon', 'co2', 'helium', 'gas mix'],
        builder: (_) => const ShieldingGasPage(),
      ),
      _SearchTarget(
        label: 'Stick Rods',
        subtitle: 'Stick rod reference',
        keywords: ['stick rod', '7018', '6011', '6010', 'rod chart'],
        builder: (_) => const StickRodsPage(),
      ),
      _SearchTarget(
        label: 'Fraction Calculator',
        subtitle: 'Convert to and from fractions',
        keywords: [
          'fraction',
          'fractions',
          'decimal',
          'fraction calculator',
          'decimal to fraction',
          'fraction to decimal',
        ],
        builder: (_) => const FractionDecimalPage(),
      ),

      // Window testing
      _SearchTarget(
        label: 'Glass & Deflection',
        subtitle: 'Glass and deflection checks',
        keywords: ['glass', 'deflection', 'glass deflection'],
        builder: (_) => const GlassDeflectionPage(),
      ),
      _SearchTarget(
        label: 'ASTM E1300',
        subtitle: 'ASTM E1300 glass reference',
        keywords: ['e1300', 'astm e1300', 'glass standard'],
        builder: (_) => const AstmE1300Page(),
      ),
      _SearchTarget(
        label: 'Structural Test Math',
        subtitle: 'Structural testing calculations',
        keywords: ['structural', 'test math', 'load', 'pressure math'],
        builder: (_) => const StructuralTestMathPage(),
      ),
      _SearchTarget(
        label: 'Rating Reference',
        subtitle: 'DP / PG / rating reference',
        keywords: ['rating', 'dp', 'pg', 'design pressure', 'performance grade'],
        builder: (_) => const RatingReferencePage(),
      ),
      _SearchTarget(
        label: 'Test Sequence Reference',
        subtitle: 'Testing order and sequence',
        keywords: ['sequence', 'test sequence', 'procedure', 'order'],
        builder: (_) => const TestSequenceReferencePage(),
      ),

      // Reference hubs
      _SearchTarget(
        label: 'Physics Equations',
        subtitle: 'Physics and engineering equations',
        keywords: ['physics', 'equations', 'beam', 'torque', 'velocity'],
        builder: (_) => const PhysicsEquationsPage(),
      ),
      _SearchTarget(
        label: 'Geometry',
        subtitle: '2D / 3D / shop geometry',
        keywords: ['geometry', 'shape', 'shapes', 'area', 'volume'],
        builder: (_) => const GeometryPage(),
      ),
      _SearchTarget(
        label: 'Material Reference',
        subtitle: 'Material property reference',
        keywords: ['material', 'materials', 'steel', 'aluminum', 'plastic'],
        builder: (_) => const MaterialReferencePage(),
      ),
      _SearchTarget(
        label: 'Electrical Reference',
        subtitle: 'Electrical formulas and references',
        keywords: ['electrical', 'electric', 'wire', 'awg', 'voltage'],
        builder: (_) => const ElectricalReferencePage(),
      ),

      // Electrical
      _SearchTarget(
        label: 'Ohms Law',
        subtitle: 'Voltage / current / resistance',
        keywords: ['ohms', 'ohm', 'resistance', 'current', 'voltage'],
        builder: (_) => const OhmsLawPage(),
      ),
      _SearchTarget(
        label: 'Power Law',
        subtitle: 'Power / volts / amps',
        keywords: ['power law', 'watts', 'amps', 'volts', 'power'],
        builder: (_) => const PowerLawPage(),
      ),
      _SearchTarget(
        label: 'Voltage Divider',
        subtitle: 'Two resistor divider tool',
        keywords: ['divider', 'voltage divider', 'resistor divider'],
        builder: (_) => const VoltageDividerPage(),
      ),
      _SearchTarget(
        label: 'AWG Quick Reference',
        subtitle: 'Wire gauge reference',
        keywords: ['awg', 'wire gauge', 'wire size', 'gauge'],
        builder: (_) => const AwgReferencePage(),
      ),
      _SearchTarget(
        label: 'Battery Runtime',
        subtitle: 'Battery runtime calculator',
        keywords: ['battery', 'runtime', 'amp hour', 'ah'],
        builder: (_) => const BatteryRuntimePage(),
      ),

      // Physics
      _SearchTarget(
        label: 'Torque & Power',
        subtitle: 'Torque and power relationships',
        keywords: ['torque', 'horsepower', 'rpm torque', 'power torque'],
        builder: (_) => const TorquePowerPage(),
      ),
      _SearchTarget(
        label: 'Cantilever Beam',
        subtitle: 'Cantilever beam calculations',
        keywords: ['cantilever', 'beam', 'deflection beam'],
        builder: (_) => const CantileverBeamPage(),
      ),
      _SearchTarget(
        label: 'Pulleys',
        subtitle: 'Pulley / mechanical advantage',
        keywords: ['pulley', 'pulleys', 'mechanical advantage'],
        builder: (_) => const PulleyPage(),
      ),
      _SearchTarget(
        label: 'Velocity & Accel',
        subtitle: 'Motion formulas',
        keywords: ['velocity', 'accel', 'acceleration', 'motion'],
        builder: (_) => const VelocityAccelPage(),
      ),
      _SearchTarget(
        label: 'Section Properties (I)',
        subtitle: 'Section property formulas',
        keywords: ['section', 'moment of inertia', 'inertia', 'section properties'],
        builder: (_) => const SectionIPage(),
      ),

      // Geometry hubs
      _SearchTarget(
        label: '2D Shapes',
        subtitle: '2D geometry tools',
        keywords: ['2d', '2d geometry', 'area', 'perimeter'],
        builder: (_) => const Geometry2DPage(),
      ),
      _SearchTarget(
        label: '3D Shapes',
        subtitle: '3D geometry tools',
        keywords: ['3d', '3d geometry', 'volume', 'surface area'],
        builder: (_) => const Geometry3DPage(),
      ),
      _SearchTarget(
        label: 'Shop Geometry',
        subtitle: 'Shop geometry helper',
        keywords: ['shop geometry', 'layout geometry', 'shop math'],
        builder: (_) => const GeometryShopPage(),
      ),

      // 2D shapes
      _SearchTarget(
        label: 'Circle',
        subtitle: 'Circle formulas',
        keywords: ['circle', 'diameter', 'radius', 'circumference'],
        builder: (_) => const CirclePage(),
      ),
      _SearchTarget(
        label: 'Rectangle',
        subtitle: 'Rectangle formulas',
        keywords: ['rectangle', 'rect', 'square'],
        builder: (_) => const RectPage(),
      ),
      _SearchTarget(
        label: 'Right Triangle',
        subtitle: 'Right triangle formulas',
        keywords: ['right triangle', 'triangle', 'pythagorean'],
        builder: (_) => const RightTrianglePage(),
      ),
      _SearchTarget(
        label: 'Trapezoid',
        subtitle: 'Trapezoid formulas',
        keywords: ['trapezoid'],
        builder: (_) => const TrapezoidPage(),
      ),
      _SearchTarget(
        label: 'Annulus',
        subtitle: 'Annulus formulas',
        keywords: ['annulus', 'ring area'],
        builder: (_) => const AnnulusPage(),
      ),
      _SearchTarget(
        label: 'Triangle Solver',
        subtitle: 'General triangle solver',
        keywords: ['triangle solver', 'angles', 'sides'],
        builder: (_) => const TriangleSolverPage(),
      ),

      // 3D shapes
      _SearchTarget(
        label: 'Box',
        subtitle: 'Box volume / surface area',
        keywords: ['box', 'cube', 'rectangular prism'],
        builder: (_) => const BoxPage(),
      ),
      _SearchTarget(
        label: 'Cone',
        subtitle: 'Cone volume / surface area',
        keywords: ['cone'],
        builder: (_) => const ConePage(),
      ),
      _SearchTarget(
        label: 'Cylinder',
        subtitle: 'Cylinder volume / surface area',
        keywords: ['cylinder'],
        builder: (_) => const CylinderPage(),
      ),
      _SearchTarget(
        label: 'Pipe',
        subtitle: 'Pipe / tube formulas',
        keywords: ['pipe', 'tube'],
        builder: (_) => const PipePage(),
      ),
      _SearchTarget(
        label: 'Sphere',
        subtitle: 'Sphere volume / surface area',
        keywords: ['sphere', 'ball'],
        builder: (_) => const SpherePage(),
      ),

      // Misc
      _SearchTarget(
        label: 'FUN?',
        subtitle: 'Fun links',
        keywords: ['fun', 'games', 'links'],
        builder: (_) => const FunLinksPage(),
      ),
      _SearchTarget(
        label: 'Settings',
        subtitle: 'App settings and theme',
        keywords: ['settings', 'theme', 'accent', 'color'],
        builder: (_) =>
            SettingsPage(themeController: widget.themeController),
      ),
    ];
  }

  List<_SearchHit> get _searchHits {
    final query = _searchController.text.trim();
    final lower = query.toLowerCase();

    final hits = <_SearchHit>[];

    final conversionMatch = _parseConversionQuery(query);
    if (conversionMatch != null) {
      hits.add(
        _SearchHit(
          title: conversionMatch.title,
          subtitle: conversionMatch.subtitle,
          kindLabel: 'instant',
          onTap: () {
            _closeSearch();
            openPage(context, const ConverItPage());
          },
        ),
      );
    }

    final targets = _buildTargets();
    final scored = <MapEntry<_SearchTarget, int>>[];

    for (final target in targets) {
      int score = 0;

      final label = target.label.toLowerCase();
      final subtitle = target.subtitle.toLowerCase();

      if (label == lower) score += 140;
      if (label.startsWith(lower)) score += 90;
      if (label.contains(lower)) score += 48;
      if (subtitle.contains(lower)) score += 18;

      for (final keyword in target.keywords) {
        final k = keyword.toLowerCase();

        if (k == lower) score += 110;
        if (k.startsWith(lower)) score += 55;
        if (k.contains(lower)) score += 24;
      }

      final parts =
          lower.split(RegExp(r'\s+')).where((part) => part.trim().isNotEmpty);

      for (final part in parts) {
        if (label.contains(part)) score += 13;
        if (subtitle.contains(part)) score += 6;

        for (final keyword in target.keywords) {
          if (keyword.toLowerCase().contains(part)) {
            score += 9;
          }
        }
      }

      // Intent boosts
      if (lower.contains('e1300') && label.contains('astm e1300')) score += 120;
      if (lower.contains('tap') && label.contains('drill & tap')) score += 70;
      if (lower.contains('awg') && label.contains('awg')) score += 85;
      if (lower.contains('glass') && label.contains('glass')) score += 50;
      if (lower.contains('deflection') && label.contains('deflection')) {
        score += 50;
      }
      if (lower.contains('ohm') && label.contains('ohms')) score += 70;
      if (lower.contains('triangle') && label.contains('triangle')) score += 45;
      if (lower.contains('weld') && label.contains('weld')) score += 55;
      if (lower.contains('tig') && label.contains('tig')) score += 65;
      if (lower.contains('stick') && label.contains('stick')) score += 65;
      if (lower.contains('gas') && label.contains('gas')) score += 35;
      if (lower.contains('battery') && label.contains('battery')) score += 60;
      if (lower.contains('torque') && label.contains('torque')) score += 60;
      if (lower.contains('beam') && label.contains('beam')) score += 60;
      if (lower.contains('geometry') && label.contains('geometry')) score += 50;

      if (score > 0) {
        scored.add(MapEntry(target, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));

    final seen = <String>{};
    for (final entry in scored) {
      if (seen.add(entry.key.label)) {
        hits.add(
          _SearchHit(
            title: entry.key.label,
            subtitle: entry.key.subtitle,
            kindLabel: 'page',
            onTap: () => _openTarget(entry.key),
          ),
        );
      }
      if (hits.length >= 9) break;
    }

    return hits;
  }

  _ConversionMatch? _parseConversionQuery(String query) {
    if (query.trim().isEmpty) return null;

    final numericPattern = RegExp(
      r'^\s*([-+]?\d*\.?\d+)\s*([A-Za-z°µΩ²³/·\-\s]+?)\s*(?:to|into|->|→)\s*([A-Za-z°µΩ²³/·\-\s]+)\s*$',
      caseSensitive: false,
    );

    final noValuePattern = RegExp(
      r'^\s*([A-Za-z°µΩ²³/·\-\s]+?)\s*(?:to|into|->|→)\s*([A-Za-z°µΩ²³/·\-\s]+)\s*$',
      caseSensitive: false,
    );

    final numericMatch = numericPattern.firstMatch(query);
    if (numericMatch != null) {
      final input = double.tryParse(numericMatch.group(1)!);
      final fromRaw = numericMatch.group(2)!;
      final toRaw = numericMatch.group(3)!;

      if (input == null) return null;

      final resolved = _resolveConversionTool(fromRaw, toRaw);
      if (resolved == null) return null;

      final output = resolved.tool.convert(resolved.direction, input);

      return _ConversionMatch(
        title:
            '${_formatInput(input)} ${_prettyUnit(fromRaw)} → $output',
        subtitle: '${resolved.tool.label} • tap to open Convert It',
      );
    }

    final noValueMatch = noValuePattern.firstMatch(query);
    if (noValueMatch != null) {
      final fromRaw = noValueMatch.group(1)!;
      final toRaw = noValueMatch.group(2)!;

      final resolved = _resolveConversionTool(fromRaw, toRaw);
      if (resolved == null) return null;

      return _ConversionMatch(
        title:
            'Open ${resolved.tool.label} (${_prettyUnit(fromRaw)} → ${_prettyUnit(toRaw)})',
        subtitle: 'Matched conversion tool • tap to open Convert It',
      );
    }

    return null;
  }

  _ResolvedTool? _resolveConversionTool(String fromRaw, String toRaw) {
    final from = _canonicalUnit(fromRaw);
    final to = _canonicalUnit(toRaw);

    for (final tool in conversionTools) {
      final toolFrom = _canonicalUnit(tool.fromUnit);
      final toolTo = _canonicalUnit(tool.toUnit);

      if (from == toolFrom && to == toolTo) {
        return _ResolvedTool(tool: tool, direction: Direction.to);
      }
      if (from == toolTo && to == toolFrom) {
        return _ResolvedTool(tool: tool, direction: Direction.from);
      }
    }

    return null;
  }

  String _prettyUnit(String raw) {
    return raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _formatInput(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _canonicalUnit(String raw) {
    String s = raw.toLowerCase().trim();

    s = s
        .replaceAll('°', '')
        .replaceAll('µ', 'u')
        .replaceAll('Ω', 'ohm')
        .replaceAll('²', '2')
        .replaceAll('³', '3')
        .replaceAll('·', '')
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll(RegExp(r'\.$'), '');

    const aliases = <String, String>{
      // pressure / air
      'psi': 'psi',
      'psf': 'psf',
      'pa': 'pa',
      'pascal': 'pa',
      'pascals': 'pa',
      'kpa': 'kpa',
      'cfm/ft2': 'cfm/ft2',
      'cfm/ft^2': 'cfm/ft2',
      'cfmft2': 'cfm/ft2',
      'l/min/m2': 'l/min/m2',
      'l/min/m^2': 'l/min/m2',
      'lminm2': 'l/min/m2',
      'mph': 'mph',
      'windspeed': 'mph',

      // length
      'in': 'in',
      'inch': 'in',
      'inches': 'in',
      'ft': 'ft',
      'foot': 'ft',
      'feet': 'ft',
      'mm': 'mm',
      'millimeter': 'mm',
      'millimeters': 'mm',
      'cm': 'cm',
      'centimeter': 'cm',
      'centimeters': 'cm',
      'm': 'm',
      'meter': 'm',
      'meters': 'm',
      'yd': 'yd',
      'yard': 'yd',
      'yards': 'yd',
      'mi': 'mi',
      'mile': 'mi',
      'miles': 'mi',
      'km': 'km',
      'kilometer': 'km',
      'kilometers': 'km',
      'um': 'um',
      'micron': 'um',
      'microns': 'um',

      // area
      'in2': 'in2',
      'in^2': 'in2',
      'sqin': 'in2',
      'squareinch': 'in2',
      'squareinches': 'in2',
      'cm2': 'cm2',
      'cm^2': 'cm2',
      'sqcm': 'cm2',
      'ft2': 'ft2',
      'ft^2': 'ft2',
      'sqft': 'ft2',
      'squarefoot': 'ft2',
      'squarefeet': 'ft2',
      'm2': 'm2',
      'm^2': 'm2',
      'sqm': 'm2',
      'yd2': 'yd2',
      'yd^2': 'yd2',
      'sqyd': 'yd2',
      'acres': 'acres',
      'acre': 'acres',

      // force / mass
      'kg': 'kg',
      'kilogram': 'kg',
      'kilograms': 'kg',
      'lb': 'lb',
      'lbs': 'lb',
      'pound': 'lb',
      'pounds': 'lb',
      'g': 'g',
      'gram': 'g',
      'grams': 'g',
      'oz': 'oz',
      'ounce': 'oz',
      'ounces': 'oz',
      'n': 'n',
      'newton': 'n',
      'newtons': 'n',
      'kn': 'kn',
      'kilonewton': 'kn',
      'kilonewtons': 'kn',
      'lbf': 'lbf',

      // volume / cooking
      'l': 'l',
      'liter': 'l',
      'liters': 'l',
      'litre': 'l',
      'litres': 'l',
      'ml': 'ml',
      'milliliter': 'ml',
      'milliliters': 'ml',
      'millilitre': 'ml',
      'millilitres': 'ml',
      'gal': 'gal',
      'gallon': 'gal',
      'gallons': 'gal',
      'floz': 'floz',
      'fl.oz': 'floz',
      'fluidounce': 'floz',
      'fluidounces': 'floz',
      'in3': 'in3',
      'in^3': 'in3',
      'cubicinch': 'in3',
      'cubicinches': 'in3',
      'ft3': 'ft3',
      'ft^3': 'ft3',
      'cubicfoot': 'ft3',
      'cubicfeet': 'ft3',
      'm3': 'm3',
      'm^3': 'm3',
      'tsp': 'tsp',
      'teaspoon': 'tsp',
      'teaspoons': 'tsp',
      'tbsp': 'tbsp',
      'tablespoon': 'tbsp',
      'tablespoons': 'tbsp',
      'cup': 'cups',
      'cups': 'cups',
      'pt': 'pt',
      'pint': 'pt',
      'pints': 'pt',
      'qt': 'qt',
      'quart': 'qt',
      'quarts': 'qt',

      // temperature
      'f': 'f',
      'fahrenheit': 'f',
      'c': 'c',
      'celsius': 'c',
      'k': 'k',
      'kelvin': 'k',

      // electrical
      'v': 'v',
      'volt': 'v',
      'volts': 'v',
      'mv': 'mv',
      'millivolt': 'mv',
      'millivolts': 'mv',
      'a': 'a',
      'amp': 'a',
      'amps': 'a',
      'ampere': 'a',
      'amperes': 'a',
      'ma': 'ma',
      'milliamp': 'ma',
      'milliamps': 'ma',
      'w': 'w',
      'watt': 'w',
      'watts': 'w',
      'kw': 'kw',
      'kilowatt': 'kw',
      'kilowatts': 'kw',
      'ohm': 'ohm',
      'ohms': 'ohm',
      'kohm': 'kohm',
      'kilohm': 'kohm',
      'kilohms': 'kohm',
      'mohm': 'mohm',
      'megohm': 'mohm',
      'megohms': 'mohm',
      'fara': 'f',
      'farad': 'f',
      'farads': 'f',
      'uf': 'uf',
      'microfarad': 'uf',
      'microfarads': 'uf',
      'hz': 'hz',
      'hertz': 'hz',
      'khz': 'khz',
      'kilohertz': 'khz',

      // speed
      'm/s': 'm/s',
      'ms': 'm/s',
      'meter/second': 'm/s',
      'meters/second': 'm/s',
      'meterpersecond': 'm/s',
      'meterspersecond': 'm/s',
      'ft/s': 'ft/s',
      'fps': 'ft/s',
      'foot/second': 'ft/s',
      'feet/second': 'ft/s',
      'km/h': 'km/h',
      'kph': 'km/h',
      'kmh': 'km/h',

      // power / energy
      'hp': 'hp',
      'horsepower': 'hp',
      'btu': 'btu',
      'j': 'j',
      'joule': 'j',
      'joules': 'j',
      'kwh': 'kwh',
      'kilowatthour': 'kwh',
      'kilowatt-hours': 'kwh',
      'kilowatthours': 'kwh',

      // torque
      'ftlbf': 'ftlbf',
      'ftlb': 'ftlbf',
      'footpound': 'ftlbf',
      'footpounds': 'ftlbf',
      'inlbf': 'inlbf',
      'inlb': 'inlbf',
      'inchpound': 'inlbf',
      'inchpounds': 'inlbf',
      'nm': 'nm',
      'n-m': 'nm',
      'newtonmeter': 'nm',
      'newtonmeters': 'nm',
    };

    return aliases[s] ?? s;
  }

  Widget _buildSearchPanel(Color accent, Size size) {
    final results = _searchHits;

    return Container(
      width: size.width > 900 ? 760 : size.width * 0.92,
      constraints: BoxConstraints(
        maxHeight: size.height * 0.72,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: accent, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 22,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.search,
                color: accent.withValues(alpha: 0.85),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: true,
                  style: TextStyle(color: accent),
                  decoration: InputDecoration(
                    hintText: 'Search tools or type: 25 psi to psf',
                    hintStyle: TextStyle(
                      color: accent.withValues(alpha: 0.40),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) {
                    if (results.isNotEmpty) {
                      results.first.onTap();
                    }
                  },
                ),
              ),
              IconButton(
                tooltip: 'Close search',
                onPressed: _closeSearch,
                icon: Icon(Icons.close, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            color: accent.withValues(alpha: 0.25),
            height: 1,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: results.isEmpty
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 12,
                      ),
                      child: Text(
                        _searchController.text.trim().isEmpty
                            ? 'Try: tap drill, e1300, awg 12, torque, glass, 25 psi to psf'
                            : 'No results found',
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.55),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: results.length,
                    separatorBuilder: (_, _) => Divider(
                      color: accent.withValues(alpha: 0.12),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final hit = results[index];
                      final isInstant = hit.kindLabel == 'instant';

                      return InkWell(
                        onTap: hit.onTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isInstant
                                    ? Icons.bolt_outlined
                                    : Icons.subdirectory_arrow_right,
                                color: accent.withValues(alpha: 0.78),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hit.title,
                                      style: TextStyle(
                                        color: accent,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      hit.subtitle,
                                      style: TextStyle(
                                        color: accent.withValues(alpha: 0.60),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Opacity(
                                opacity: 0.55,
                                child: Text(
                                  hit.kindLabel.toUpperCase(),
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 10,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final accent = widget.themeController.accentColor;

    final verticalSpacing = size.height * 0.02;
    final gridSpacing = size.width * 0.02;

    Widget terminalButton(
      BuildContext context,
      String label,
      VoidCallback onPressed,
    ) {
      return SizedBox(
        width: double.infinity,
        height: size.height * 0.10,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: BorderSide(color: accent, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero,
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              accent.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.018,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
    }

    Widget bottomCornerButton({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
    }) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: size.width * 0.02),
        label: Text(
          label,
          style: TextStyle(fontSize: size.width * 0.016),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: size.width * 0.002),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.02,
            vertical: size.height * 0.012,
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: "Ultimate Window Engineer Tool",
      child: Stack(
        children: [
          Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip: 'Search tools',
                  onPressed: _toggleSearch,
                  icon: Icon(
                    Icons.search,
                    color: accent.withValues(alpha: 0.72),
                    size: size.width > 900 ? 24 : 22,
                  ),
                ),
              ),

              SizedBox(height: verticalSpacing * 0.25),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                  childAspectRatio: 1.6,
                  children: [
                    terminalButton(context, "Convert it", () {
                      openPage(context, const ConverItPage());
                    }),
                    terminalButton(context, "Fabricate it", () {
                      openPage(context, const FabricateItPage());
                    }),
                    terminalButton(context, "Reference it", () {
                      openPage(context, const ReferenceHomePage());
                    }),
                    terminalButton(context, "Window Testing Tools", () {
                      openPage(context, const WindowTestingToolsPage());
                    }),
                  ],
                ),
              ),

              SizedBox(height: verticalSpacing),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  bottomCornerButton(
                    icon: Icons.videogame_asset_outlined,
                    label: "FUN?",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FunLinksPage(),
                        ),
                      );
                    },
                  ),
                  bottomCornerButton(
                    icon: Icons.settings,
                    label: "settings",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsPage(
                            themeController: widget.themeController,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: verticalSpacing),
            ],
          ),

          if (_showSearch)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeSearch,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.62),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: _buildSearchPanel(accent, size),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchTarget {
  final String label;
  final String subtitle;
  final List<String> keywords;
  final Widget Function(BuildContext context) builder;

  const _SearchTarget({
    required this.label,
    required this.subtitle,
    required this.keywords,
    required this.builder,
  });
}

class _SearchHit {
  final String title;
  final String subtitle;
  final String kindLabel;
  final VoidCallback onTap;

  const _SearchHit({
    required this.title,
    required this.subtitle,
    required this.kindLabel,
    required this.onTap,
  });
}

class _ResolvedTool {
  final ConversionTool tool;
  final Direction direction;

  const _ResolvedTool({
    required this.tool,
    required this.direction,
  });
}

class _ConversionMatch {
  final String title;
  final String subtitle;

  const _ConversionMatch({
    required this.title,
    required this.subtitle,
  });
}
