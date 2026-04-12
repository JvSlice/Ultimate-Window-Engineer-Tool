import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../convert_it_page.dart';
import '../../fabricate_it_page.dart';
import '../../fun_links_page.dart';
import '../../settings_page.dart';
import '../../window_testing_tools_page.dart';
import '../../reference/reference_home_page.dart';

// Fabrication
import '../../fabrication/drill_index_page.dart';
import '../../fabrication/drill_tap_Selector_page.dart';
import '../../fabrication/fraction_decimal_page.dart';
import '../../fabrication/shielding_gas_page.dart';
import '../../fabrication/speed_feed_page.dart';
import '../../fabrication/stick_rod_page.dart';
import '../../fabrication/tig_amp_page.dart';
import '../../fabrication/tig_tungsten_page.dart';
import '../../fabrication/weld_it_page.dart';
import '../../fabrication/weld_it/mig_setup_calc_page.dart';
import '../../fabrication/weld_it/stick_setup_calc_page.dart';
import '../../fabrication/weld_it/tig_setup_calc_page.dart';
import '../../fabrication/test_buck_calculator.dart';

// Window testing
import '../../window_testing_tools/astm_e1300_page.dart';
import '../../window_testing_tools/glass_deflection_page.dart';
import '../../window_testing_tools/rating_reference_page.dart';
import '../../window_testing_tools/structural_test_math_page.dart';
import '../../window_testing_tools/test_sequence_reference_page.dart';

// Reference
import '../../reference/geometry_page.dart';
import '../../reference/geometry_2d_page.dart';
import '../../reference/geometry_3d_page.dart';
import '../../reference/geometry_shop_page.dart';
import '../../reference/materials/material_reference_page.dart';
import '../../reference/physics_equations_page.dart';
import '../../reference/eletrical_tools/eletrical_reference_page.dart';
import '../../reference/eletrical_tools/ohms_law_page.dart';
import '../../reference/eletrical_tools/power_law_page.dart';
import '../../reference/eletrical_tools/voltage_divider_page.dart';
import '../../reference/eletrical_tools/awg_reference_page.dart';
import '../../reference/eletrical_tools/battery_runtime_page.dart';
import '../../reference/physics/cantilever_beam_page.dart';
import '../../reference/physics/pulleys_page.dart';
import '../../reference/physics/section_i_page.dart';
import '../../reference/physics/torque_power_page.dart';
import '../../reference/physics/velocity_page.dart';
import '../../reference/shapes/annulus_page.dart';
import '../../reference/shapes/circle_page.dart';
import '../../reference/shapes/rect_page.dart';
import '../../reference/shapes/right_triangle_page.dart';
import '../../reference/shapes/trapezoid_page.dart';
import '../../reference/shapes/triangle_solver_page.dart';
import '../../reference/shapes3d/box_page.dart';
import '../../reference/shapes3d/cone_page.dart';
import '../../reference/shapes3d/cylinder_page.dart';
import '../../reference/shapes3d/pipe_page.dart';
import '../../reference/shapes3d/sphere_page.dart';
import '../../reference/rigging/rigging_home_page.dart';
import '../../reference/rigging/rigging_load_calculator_page.dart';
import '../../reference/rigging/wll_calculator_page.dart';

import 'search_models.dart';

List<SearchTarget> buildMainMenuSearchTargets(
  AppThemeController themeController,
) {
  return [
    SearchTarget(
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
    SearchTarget(
      label: 'Fabricate It',
      subtitle: 'Fabrication tools hub',
      keywords: ['fabricate', 'fabrication', 'shop', 'machining', 'metal'],
      builder: (_) => const FabricateItPage(),
    ),
    SearchTarget(
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
    SearchTarget(
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

    SearchTarget(
      label: 'Drill Index',
      subtitle: 'Letter / Number / Fractional',
      keywords: ['drill', 'index', 'bit', 'fractional drill', 'letter drill'],
      builder: (_) => const DrillIndexPage(),
    ),
    SearchTarget(
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
    SearchTarget(
      label: 'Speed & Feeds',
      subtitle: 'RPM / IPM calculator',
      keywords: ['speed', 'feed', 'feeds', 'rpm', 'ipm', 'sfm'],
      builder: (_) => const SpeedFeedPage(),
    ),
    SearchTarget(
      label: 'Weld It',
      subtitle: 'Welding settings and references',
      keywords: ['weld', 'welding', 'mig', 'tig', 'stick'],
      builder: (_) => const WeldItPage(),
    ),
    //SearchTarget(
    //label: 'TIG Amps',
    //subtitle: 'TIG amperage reference',
    //keywords: ['tig amps', 'tig amp', 'amperage'],
    //builder: (_) => const TigAmpPage(),
    //),
    SearchTarget(
      label: 'TIG Tungsten',
      subtitle: 'TIG tungsten reference',
      keywords: ['tig tungsten', 'tungsten', 'electrode'],
      builder: (_) => const TigTungstenPage(),
    ),
    SearchTarget(
      label: 'Shielding Gas',
      subtitle: 'Shielding gas reference',
      keywords: ['shielding gas', 'argon', 'co2', 'helium', 'gas mix'],
      builder: (_) => const ShieldingGasPage(),
    ),
    SearchTarget(
      label: 'Stick Rods',
      subtitle: 'Stick rod reference',
      keywords: ['stick rod', '7018', '6011', '6010', 'rod chart'],
      builder: (_) => const StickRodsPage(),
    ),
    SearchTarget(
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

    SearchTarget(
      label: 'Glass & Deflection',
      subtitle: 'Glass and deflection checks',
      keywords: ['glass', 'deflection', 'glass deflection'],
      builder: (_) => const GlassDeflectionPage(),
    ),
    SearchTarget(
      label: 'ASTM E1300',
      subtitle: 'ASTM E1300 glass reference',
      keywords: ['e1300', 'astm e1300', 'glass standard'],
      builder: (_) => const AstmE1300Page(),
    ),
    SearchTarget(
      label: 'Structural Test Math',
      subtitle: 'Structural testing calculations',
      keywords: ['structural', 'test math', 'load', 'pressure math'],
      builder: (_) => const StructuralTestMathPage(),
    ),
    SearchTarget(
      label: 'Rating Reference',
      subtitle: 'DP / PG / rating reference',
      keywords: ['rating', 'dp', 'pg', 'design pressure', 'performance grade'],
      builder: (_) => const RatingReferencePage(),
    ),
    SearchTarget(
      label: 'Test Sequence Reference',
      subtitle: 'Testing order and sequence',
      keywords: ['sequence', 'test sequence', 'procedure', 'order'],
      builder: (_) => const TestSequenceReferencePage(),
    ),

    SearchTarget(
      label: 'Physics Equations',
      subtitle: 'Physics and engineering equations',
      keywords: ['physics', 'equations', 'beam', 'torque', 'velocity'],
      builder: (_) => const PhysicsEquationsPage(),
    ),
    SearchTarget(
      label: 'Geometry',
      subtitle: '2D / 3D / shop geometry',
      keywords: ['geometry', 'shape', 'shapes', 'area', 'volume'],
      builder: (_) => const GeometryPage(),
    ),
    SearchTarget(
      label: 'Material Reference',
      subtitle: 'Material property reference',
      keywords: ['material', 'materials', 'steel', 'aluminum', 'plastic'],
      builder: (_) => const MaterialReferencePage(),
    ),
    SearchTarget(
      label: 'Electrical Reference',
      subtitle: 'Electrical formulas and references',
      keywords: ['electrical', 'electric', 'wire', 'awg', 'voltage'],
      builder: (_) => const ElectricalReferencePage(),
    ),

    SearchTarget(
      label: 'Ohms Law',
      subtitle: 'Voltage / current / resistance',
      keywords: ['ohms', 'ohm', 'resistance', 'current', 'voltage'],
      builder: (_) => const OhmsLawPage(),
    ),
    SearchTarget(
      label: 'Power Law',
      subtitle: 'Power / volts / amps',
      keywords: ['power law', 'watts', 'amps', 'volts', 'power'],
      builder: (_) => const PowerLawPage(),
    ),
    SearchTarget(
      label: 'Voltage Divider',
      subtitle: 'Two resistor divider tool',
      keywords: ['divider', 'voltage divider', 'resistor divider'],
      builder: (_) => const VoltageDividerPage(),
    ),
    SearchTarget(
      label: 'AWG Quick Reference',
      subtitle: 'Wire gauge reference',
      keywords: ['awg', 'wire gauge', 'wire size', 'gauge'],
      builder: (_) => const AwgReferencePage(),
    ),
    SearchTarget(
      label: 'Battery Runtime',
      subtitle: 'Battery runtime calculator',
      keywords: ['battery', 'runtime', 'amp hour', 'ah'],
      builder: (_) => const BatteryRuntimePage(),
    ),

    SearchTarget(
      label: 'Torque & Power',
      subtitle: 'Torque and power relationships',
      keywords: ['torque', 'horsepower', 'rpm torque', 'power torque'],
      builder: (_) => const TorquePowerPage(),
    ),
    SearchTarget(
      label: 'Cantilever Beam',
      subtitle: 'Cantilever beam calculations',
      keywords: ['cantilever', 'beam', 'deflection beam'],
      builder: (_) => const CantileverBeamPage(),
    ),
    SearchTarget(
      label: 'Pulleys',
      subtitle: 'Pulley / mechanical advantage',
      keywords: ['pulley', 'pulleys', 'mechanical advantage'],
      builder: (_) => const PulleyPage(),
    ),
    SearchTarget(
      label: 'Velocity & Accel',
      subtitle: 'Motion formulas',
      keywords: ['velocity', 'accel', 'acceleration', 'motion'],
      builder: (_) => const VelocityAccelPage(),
    ),
    SearchTarget(
      label: 'Section Properties (I)',
      subtitle: 'Section property formulas',
      keywords: [
        'section',
        'moment of inertia',
        'inertia',
        'section properties',
      ],
      builder: (_) => const SectionIPage(),
    ),

    SearchTarget(
      label: '2D Shapes',
      subtitle: '2D geometry tools',
      keywords: ['2d', '2d geometry', 'area', 'perimeter'],
      builder: (_) => const Geometry2DPage(),
    ),
    SearchTarget(
      label: '3D Shapes',
      subtitle: '3D geometry tools',
      keywords: ['3d', '3d geometry', 'volume', 'surface area'],
      builder: (_) => const Geometry3DPage(),
    ),
    SearchTarget(
      label: 'Shop Geometry',
      subtitle: 'Shop geometry helper',
      keywords: ['shop geometry', 'layout geometry', 'shop math'],
      builder: (_) => const GeometryShopPage(),
    ),

    SearchTarget(
      label: 'Circle',
      subtitle: 'Circle formulas',
      keywords: ['circle', 'diameter', 'radius', 'circumference'],
      builder: (_) => const CirclePage(),
    ),
    SearchTarget(
      label: 'Rectangle',
      subtitle: 'Rectangle formulas',
      keywords: ['rectangle', 'rect', 'square'],
      builder: (_) => const RectPage(),
    ),
    SearchTarget(
      label: 'Right Triangle',
      subtitle: 'Right triangle formulas',
      keywords: ['right triangle', 'triangle', 'pythagorean'],
      builder: (_) => const RightTrianglePage(),
    ),
    SearchTarget(
      label: 'Trapezoid',
      subtitle: 'Trapezoid formulas',
      keywords: ['trapezoid'],
      builder: (_) => const TrapezoidPage(),
    ),
    SearchTarget(
      label: 'Annulus',
      subtitle: 'Annulus formulas',
      keywords: ['annulus', 'ring area'],
      builder: (_) => const AnnulusPage(),
    ),
    SearchTarget(
      label: 'Triangle Solver',
      subtitle: 'General triangle solver',
      keywords: ['triangle solver', 'angles', 'sides'],
      builder: (_) => const TriangleSolverPage(),
    ),

    SearchTarget(
      label: 'Box',
      subtitle: 'Box volume / surface area',
      keywords: ['box', 'cube', 'rectangular prism'],
      builder: (_) => const BoxPage(),
    ),
    SearchTarget(
      label: 'Cone',
      subtitle: 'Cone volume / surface area',
      keywords: ['cone'],
      builder: (_) => const ConePage(),
    ),
    SearchTarget(
      label: 'Cylinder',
      subtitle: 'Cylinder volume / surface area',
      keywords: ['cylinder'],
      builder: (_) => const CylinderPage(),
    ),
    SearchTarget(
      label: 'Pipe',
      subtitle: 'Pipe / tube formulas',
      keywords: ['pipe', 'tube'],
      builder: (_) => const PipePage(),
    ),
    SearchTarget(
      label: 'Sphere',
      subtitle: 'Sphere volume / surface area',
      keywords: ['sphere', 'ball'],
      builder: (_) => const SpherePage(),
    ),

    SearchTarget(
      label: 'FUN?',
      subtitle: 'Fun links',
      keywords: ['fun', 'games', 'links'],
      builder: (_) => const FunLinksPage(),
    ),
    SearchTarget(
      label: 'Settings',
      subtitle: 'App settings and theme',
      keywords: ['settings', 'theme', 'accent', 'color'],
      builder: (_) => SettingsPage(themeController: themeController),
    ),
    SearchTarget(
      label: 'Rigging Tools',
      subtitle: 'Rigging load and hitch calculator',
      keywords: [
        'rigging',
        'sling',
        'basket hitch',
        'choker hitch',
        'vertical hitch',
        'lifting angle',
        'load angle',
        'rigging calculator',
      ],
      builder: (_) => const RiggingHomePage(),
    ),
    SearchTarget(
      label: 'Rigging WLL Calculator',
      subtitle: 'Working load limit and pass/fail check',
      keywords: [
        'rigging wll',
        'working load limit',
        'sling capacity',
        'chain sling',
        'wire rope sling',
        'web sling',
        'rigging pass fail',
      ],
      builder: (_) => const RiggingWllCalculatorPage(),
    ),
    SearchTarget(
      label: 'MIG Setup Calculator',
      subtitle: 'Weld It • voltage, wire speed, wire size, gas, polarity',
      keywords: [
        'mig',
        'mig calc',
        'mig calculator',
        'mig setup',
        'mig settings',
        'wire speed',
        'voltage',
        'welding',
        'weld it',
        'gmaw',
      ],
      builder: (_) => const MigSetupCalcPage(),
    ),

    SearchTarget(
      label: 'Stick Setup Calculator',
      subtitle: 'Weld It • polarity, rod choices, amperage',
      keywords: [
        'stick',
        'stick calc',
        'stick calculator',
        'stick setup',
        'stick settings',
        'rod',
        'rod choice',
        'electrode',
        'amp',
        'amps',
        'amperage',
        'smaw',
        'welding',
        'weld it',
      ],
      builder: (_) => const StickSetupCalcPage(),
    ),

    SearchTarget(
      label: 'TIG Setup Calculator',
      subtitle: 'Weld It • polarity, amps, tungsten type and size',
      keywords: [
        'tig',
        'tig calc',
        'tig calculator',
        'tig setup',
        'tig settings',
        'tungsten',
        'tungsten size',
        'tungsten type',
        'gtaw',
        'amp',
        'amps',
        'amperage',
        'welding',
        'weld it',
      ],
      builder: (_) => const TigSetupCalcPage(),
    ),
    SearchTarget(
      label: 'Test Buck Calculator',
      subtitle: 'Calculate lumber cut sizes for test bucks',
      keywords: [
        'test buck',
        'buck calculator',
        'lumber cuts',
        'rough opening buck',
        'caulk joint',
        'fab',
        'fabrication',
      ],
      builder: (_) => const TestBuckCalculatorPage(),
    ),
  ];
}
