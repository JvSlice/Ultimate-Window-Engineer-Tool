import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/window_testing_tools_page.dart';

import 'app_theme.dart';
import 'convert_it_page.dart';
import 'fabricate_it_page.dart';
import 'fun_links_page.dart';
import 'settings_page.dart';
import 'terminal_scaffold.dart';

// Main hubs
import 'reference/reference_home_page.dart';

// Fabrication pages
import 'package:ultimate_window_engineer_tool/fabrication/drill_index_page.dart';
import 'package:ultimate_window_engineer_tool/fabrication/drill_tap_Selector_page.dart';
import 'package:ultimate_window_engineer_tool/fabrication/fraction_decimal_page.dart';
import 'package:ultimate_window_engineer_tool/fabrication/speed_feed_page.dart';
import 'package:ultimate_window_engineer_tool/fabrication/weld_it_page.dart';

// Window testing pages
import 'package:ultimate_window_engineer_tool/window_testing_tools/glass_deflection_page.dart';
import 'package:ultimate_window_engineer_tool/window_testing_tools/structural_test_math_page.dart';
import 'package:ultimate_window_engineer_tool/window_testing_tools/rating_reference_page.dart';
import 'package:ultimate_window_engineer_tool/window_testing_tools/test_sequence_reference_page.dart';
import 'package:ultimate_window_engineer_tool/window_testing_tools/astm_e1300_page.dart';

// Reference pages
import 'package:ultimate_window_engineer_tool/reference/physics_equations_page.dart';
import 'package:ultimate_window_engineer_tool/reference/geometry_page.dart';
import 'package:ultimate_window_engineer_tool/reference/materials/material_reference_page.dart';
import 'package:ultimate_window_engineer_tool/reference/eletrical_tools/eletrical_reference_page.dart';

// Electrical deep pages
import 'package:ultimate_window_engineer_tool/reference/eletrical_tools/ohms_law_page.dart';
import 'package:ultimate_window_engineer_tool/reference/eletrical_tools/power_law_page.dart';
import 'package:ultimate_window_engineer_tool/reference/eletrical_tools/voltage_divider_page.dart';
import 'package:ultimate_window_engineer_tool/reference/eletrical_tools/awg_reference_page.dart';
import 'package:ultimate_window_engineer_tool/reference/eletrical_tools/battery_runtime_page.dart';

// Physics deep pages
import 'package:ultimate_window_engineer_tool/reference/physics/cantilever_beam_page.dart';
import 'package:ultimate_window_engineer_tool/reference/physics/pulleys_page.dart';
import 'package:ultimate_window_engineer_tool/reference/physics/section_i_page.dart';
import 'package:ultimate_window_engineer_tool/reference/physics/torque_power_page.dart';
import 'package:ultimate_window_engineer_tool/reference/physics/velocity_page.dart';

// Geometry deep pages
import 'package:ultimate_window_engineer_tool/reference/geometry_2d_page.dart';
import 'package:ultimate_window_engineer_tool/reference/geometry_3d_page.dart';
import 'package:ultimate_window_engineer_tool/reference/geometry_shop_page.dart';

// Shape pages
import 'package:ultimate_window_engineer_tool/reference/shapes/circle_page.dart';
import 'package:ultimate_window_engineer_tool/reference/shapes/rect_page.dart';
import 'package:ultimate_window_engineer_tool/reference/shapes/right_triangle_page.dart';
import 'package:ultimate_window_engineer_tool/reference/shapes/trapezoid_page.dart';
import 'package:ultimate_window_engineer_tool/reference/shapes/annulus_page.dart';
import 'package:ultimate_window_engineer_tool/reference/shapes/triangle_solver_page.dart';

// 3D shape pages
import 'package:ultimate_window_engineer_tool/reference/shapes3d/box_page.dart';
import 'package:ultimate_window_engineer_tool/reference/shapes3d/cone_page.dart';
import 'package:ultimate_window_engineer_tool/reference/shapes3d/cylinder_page.dart';
import 'package:ultimate_window_engineer_tool/reference/shapes3d/pipe_page.dart';
import 'package:ultimate_window_engineer_tool/reference/shapes3d/sphere_page.dart';

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
      // ------------------------------------------------------------
      // MAIN HUBS
      // ------------------------------------------------------------
      _SearchTarget(
        label: 'Convert It',
        subtitle: 'Unit conversion hub',
        keywords: [
          'convert',
          'conversion',
          'units',
          'pressure',
          'length',
          'mass',
          'force',
          'volume',
          'temperature',
          'cooking',
          'electrical',
          'speed',
          'power',
          'energy',
          'torque',
          'psi',
          'psf',
        ],
        builder: (_) => const ConverItPage(),
      ),
      _SearchTarget(
        label: 'Fabricate It',
        subtitle: 'Fabrication tools hub',
        keywords: [
          'fabricate',
          'fabrication',
          'shop',
          'machine',
          'machining',
          'metal',
          'layout',
        ],
        builder: (_) => const FabricateItPage(),
      ),
      _SearchTarget(
        label: 'Reference It',
        subtitle: 'Reference hub',
        keywords: [
          'reference',
          'lookup',
          'library',
          'data',
          'equations',
          'geometry',
          'materials',
          'electrical',
        ],
        builder: (_) => const ReferenceHomePage(),
      ),
      _SearchTarget(
        label: 'Window Testing Tools',
        subtitle: 'Window testing hub',
        keywords: [
          'window testing',
          'testing',
          'test',
          'structural',
          'water',
          'glass',
          'deflection',
          'rating',
          'sequence',
          'astm',
          'aama',
          'e1300',
        ],
        builder: (_) => const WindowTestingToolsPage(),
      ),

      // ------------------------------------------------------------
      // FABRICATION
      // ------------------------------------------------------------
      _SearchTarget(
        label: 'Drill Index',
        subtitle: 'Letter / Number / Fractional',
        keywords: [
          'drill',
          'index',
          'drill index',
          'bit',
          'drill bit',
          'fractional drill',
          'number drill',
          'letter drill',
        ],
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
          'screw',
        ],
        builder: (_) => const DrillTapSelectorPage(),
      ),
      _SearchTarget(
        label: 'Speed & Feeds',
        subtitle: 'RPM / IPM calculator',
        keywords: [
          'speed',
          'feed',
          'feeds',
          'rpm',
          'ipm',
          'machining speed',
          'machining feed',
          'cutting speed',
        ],
        builder: (_) => const SpeedFeedPage(),
      ),
      _SearchTarget(
        label: 'Weld It',
        subtitle: 'Welding setting reference',
        keywords: [
          'weld',
          'welding',
          'mig',
          'tig',
          'stick',
          'rod',
          'gas',
          'weld settings',
        ],
        builder: (_) => const WeldItPage(),
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

      // ------------------------------------------------------------
      // REFERENCE HUBS
      // ------------------------------------------------------------
      _SearchTarget(
        label: 'Physics Equations',
        subtitle: 'Physics and engineering equations',
        keywords: [
          'physics',
          'equations',
          'engineering equations',
          'beam',
          'velocity',
          'torque',
          'section properties',
        ],
        builder: (_) => const PhysicsEquationsPage(),
      ),
      _SearchTarget(
        label: 'Geometry',
        subtitle: '2D / 3D / shop geometry',
        keywords: [
          'geometry',
          'shape',
          'shapes',
          'triangle',
          'circle',
          'box',
          'area',
          'volume',
        ],
        builder: (_) => const GeometryPage(),
      ),
      _SearchTarget(
        label: 'Material Properties',
        subtitle: 'Material reference data',
        keywords: [
          'material',
          'materials',
          'material properties',
          'aluminum',
          'steel',
          'density',
          'modulus',
        ],
        builder: (_) => const MaterialReferencePage(),
      ),
      _SearchTarget(
        label: 'Electrical References',
        subtitle: 'Electrical calculators and references',
        keywords: [
          'electrical',
          'electric',
          'wire',
          'ohms law',
          'voltage',
          'power law',
          'awg',
          'battery',
        ],
        builder: (_) => const ElectricalReferencePage(),
      ),

      // ------------------------------------------------------------
      // ELECTRICAL DEEP LINKS
      // ------------------------------------------------------------
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
        keywords: [
          'divider',
          'voltage divider',
          'resistor divider',
          'resistors',
        ],
        builder: (_) => const VoltageDividerPage(),
      ),
      _SearchTarget(
        label: 'AWG Reference',
        subtitle: 'Wire gauge reference',
        keywords: ['awg', 'wire gauge', 'wire size', 'gauge'],
        builder: (_) => const AwgReferencePage(),
      ),
      _SearchTarget(
        label: 'Battery Runtime',
        subtitle: 'Battery runtime calculator',
        keywords: ['battery', 'runtime', 'amp hour', 'ah', 'load time'],
        builder: (_) => const BatteryRuntimePage(),
      ),

      // ------------------------------------------------------------
      // PHYSICS DEEP LINKS
      // ------------------------------------------------------------
      _SearchTarget(
        label: 'Cantilever Beam',
        subtitle: 'Cantilever beam calculations',
        keywords: ['cantilever', 'beam', 'deflection beam', 'load beam'],
        builder: (_) => const CantileverBeamPage(),
      ),
      _SearchTarget(
        label: 'Pulleys',
        subtitle: 'Pulley / mechanical advantage',
        keywords: ['pulley', 'pulleys', 'mechanical advantage'],
        builder: (_) => const PulleyPage(),
      ),
      _SearchTarget(
        label: 'Section I',
        subtitle: 'Section properties',
        keywords: [
          'section',
          'section i',
          'moment of inertia',
          'inertia',
          'section properties',
        ],
        builder: (_) => const SectionIPage(),
      ),
      _SearchTarget(
        label: 'Torque / Power',
        subtitle: 'Torque and power relationships',
        keywords: ['torque', 'horsepower', 'power torque', 'rpm torque'],
        builder: (_) => const TorquePowerPage(),
      ),
      _SearchTarget(
        label: 'Velocity / Acceleration',
        subtitle: 'Motion formulas',
        keywords: ['velocity', 'acceleration', 'motion', 'speed'],
        builder: (_) => const VelocityAccelPage(),
      ),

      // ------------------------------------------------------------
      // GEOMETRY DEEP LINKS
      // ------------------------------------------------------------
      _SearchTarget(
        label: 'Geometry 2D',
        subtitle: '2D geometry tools',
        keywords: ['2d', '2d geometry', 'area', 'perimeter'],
        builder: (_) => const Geometry2DPage(),
      ),
      _SearchTarget(
        label: 'Geometry 3D',
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

      // ------------------------------------------------------------
      // SHAPES
      // ------------------------------------------------------------
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
        keywords: ['trapezoid', 'trap'],
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
        keywords: ['triangle solver', 'triangle', 'angles', 'sides'],
        builder: (_) => const TriangleSolverPage(),
      ),

      // ------------------------------------------------------------
      // 3D SHAPES
      // ------------------------------------------------------------
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
        subtitle: 'Pipe formulas',
        keywords: ['pipe', 'tube'],
        builder: (_) => const PipePage(),
      ),
      _SearchTarget(
        label: 'Sphere',
        subtitle: 'Sphere volume / surface area',
        keywords: ['sphere', 'ball'],
        builder: (_) => const SpherePage(),
      ),

      // ------------------------------------------------------------
      // WINDOW TESTING DEEP LINKS
      // ------------------------------------------------------------
      _SearchTarget(
        label: 'Glass & Deflection',
        subtitle: 'Glass and deflection checks',
        keywords: [
          'glass',
          'deflection',
          'glass deflection',
          'glass check',
        ],
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
        keywords: ['structural', 'structural test', 'test math', 'load math'],
        builder: (_) => const StructuralTestMathPage(),
      ),
      _SearchTarget(
        label: 'Rating Reference',
        subtitle: 'DP / PG / rating reference',
        keywords: [
          'rating',
          'dp',
          'pg',
          'design pressure',
          'performance grade',
          'cw',
          'aw',
        ],
        builder: (_) => const RatingReferencePage(),
      ),
      _SearchTarget(
        label: 'Test Sequence Reference',
        subtitle: 'Testing order and sequence',
        keywords: ['sequence', 'test sequence', 'procedure', 'order'],
        builder: (_) => const TestSequenceReferencePage(),
      ),

      // ------------------------------------------------------------
      // EXTRA
      // ------------------------------------------------------------
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

  List<_SearchTarget> get _filteredTargets {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return [];

    final allTargets = _buildTargets();
    final scored = <MapEntry<_SearchTarget, int>>[];

    for (final target in allTargets) {
      int score = 0;

      final label = target.label.toLowerCase();
      final subtitle = target.subtitle.toLowerCase();

      if (label == query) score += 120;
      if (label.startsWith(query)) score += 80;
      if (label.contains(query)) score += 45;

      if (subtitle.contains(query)) score += 18;

      for (final keyword in target.keywords) {
        final k = keyword.toLowerCase();

        if (k == query) score += 100;
        if (k.startsWith(query)) score += 50;
        if (k.contains(query)) score += 24;
      }

      final queryParts = query.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
      for (final part in queryParts) {
        if (label.contains(part)) score += 12;
        if (subtitle.contains(part)) score += 6;

        for (final keyword in target.keywords) {
          if (keyword.toLowerCase().contains(part)) {
            score += 8;
          }
        }
      }

      if (score > 0) {
        scored.add(MapEntry(target, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));

    final seen = <String>{};
    final results = <_SearchTarget>[];

    for (final entry in scored) {
      if (seen.add(entry.key.label)) {
        results.add(entry.key);
      }
      if (results.length >= 8) break;
    }

    return results;
  }

  Widget _buildSearchPanel(Color accent, Size size) {
    final results = _filteredTargets;

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
                    hintText: 'Search tools, references, calculators...',
                    hintStyle: TextStyle(
                      color: accent.withValues(alpha: 0.40),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) {
                    if (results.isNotEmpty) {
                      _openTarget(results.first);
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
                            ? 'Try: drill, glass, awg, torque, tap, rating...'
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
                      final target = results[index];

                      return InkWell(
                        onTap: () => _openTarget(target),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.subdirectory_arrow_right,
                                color: accent.withValues(alpha: 0.78),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      target.label,
                                      style: TextStyle(
                                        color: accent,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.7,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      target.subtitle,
                                      style: TextStyle(
                                        color: accent.withValues(alpha: 0.60),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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
