import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../reference/materials/material_data.dart' as material_refs;
import '../terminal_scaffold.dart';
import '../widgets/calc_button.dart';
import '../widgets/terminal_fields.dart';

enum LatheUnitSystem { imperial, metric }

enum LatheToolMaterial { hss, carbide }

class LatheRecommendation {
  final String id;
  final String label;
  final String? centralMaterialName;
  final double hssSfm;
  final double carbideSfm;
  final double hssFeedInPerRev;
  final double carbideFeedInPerRev;
  final String note;

  const LatheRecommendation({
    required this.id,
    required this.label,
    required this.centralMaterialName,
    required this.hssSfm,
    required this.carbideSfm,
    required this.hssFeedInPerRev,
    required this.carbideFeedInPerRev,
    required this.note,
  });

  double sfmFor(LatheToolMaterial tool) {
    return tool == LatheToolMaterial.hss ? hssSfm : carbideSfm;
  }

  double feedInPerRevFor(LatheToolMaterial tool) {
    return tool == LatheToolMaterial.hss
        ? hssFeedInPerRev
        : carbideFeedInPerRev;
  }

  double cuttingSpeedMMinFor(LatheToolMaterial tool) {
    return sfmFor(tool) * 0.3048;
  }

  double feedMmPerRevFor(LatheToolMaterial tool) {
    return feedInPerRevFor(tool) * 25.4;
  }
}

class LatheCalculationResult {
  final double rpm;
  final double feedRate;

  const LatheCalculationResult({required this.rpm, required this.feedRate});
}

const latheRecommendations = <LatheRecommendation>[
  LatheRecommendation(
    id: 'aluminum',
    label: 'Aluminum',
    centralMaterialName: '6061-T6',
    hssSfm: 300,
    carbideSfm: 800,
    hssFeedInPerRev: 0.006,
    carbideFeedInPerRev: 0.008,
    note: 'Good starting point for common 6xxx aluminum.',
  ),
  LatheRecommendation(
    id: 'mild_steel',
    label: 'Mild Steel',
    centralMaterialName: '1018 (Cold Drawn)',
    hssSfm: 100,
    carbideSfm: 350,
    hssFeedInPerRev: 0.005,
    carbideFeedInPerRev: 0.007,
    note: 'Reduce for scale, interrupted cuts, or light machines.',
  ),
  LatheRecommendation(
    id: 'stainless_steel',
    label: 'Stainless Steel',
    centralMaterialName: '304 Stainless (Annealed)',
    hssSfm: 50,
    carbideSfm: 180,
    hssFeedInPerRev: 0.004,
    carbideFeedInPerRev: 0.006,
    note: 'Keep the tool cutting to avoid work hardening.',
  ),
  LatheRecommendation(
    id: 'brass',
    label: 'Brass',
    centralMaterialName: 'Brass (C360 Free-Cutting)',
    hssSfm: 200,
    carbideSfm: 600,
    hssFeedInPerRev: 0.006,
    carbideFeedInPerRev: 0.008,
    note: 'Use sharp tools and adjust for the exact brass alloy.',
  ),
  LatheRecommendation(
    id: 'copper',
    label: 'Copper',
    centralMaterialName: 'Copper (C110 ETP)',
    hssSfm: 150,
    carbideSfm: 400,
    hssFeedInPerRev: 0.004,
    carbideFeedInPerRev: 0.006,
    note: 'Copper can be gummy. Sharp tools and lubrication help.',
  ),
];

double calculateLatheRpm({
  required LatheUnitSystem unitSystem,
  required double cuttingSpeed,
  required double diameter,
}) {
  if (diameter <= 0 || cuttingSpeed <= 0) return 0;

  switch (unitSystem) {
    case LatheUnitSystem.imperial:
      return (cuttingSpeed * 12) / (math.pi * diameter);
    case LatheUnitSystem.metric:
      return (cuttingSpeed * 1000) / (math.pi * diameter);
  }
}

LatheCalculationResult calculateLatheSpeedFeed({
  required LatheUnitSystem unitSystem,
  required double diameter,
  required double cuttingSpeed,
  required double feedPerRev,
}) {
  final rpm = calculateLatheRpm(
    unitSystem: unitSystem,
    cuttingSpeed: cuttingSpeed,
    diameter: diameter,
  );

  return LatheCalculationResult(rpm: rpm, feedRate: rpm * feedPerRev);
}

class LatheSpeedFeedPage extends StatefulWidget {
  const LatheSpeedFeedPage({super.key});

  @override
  State<LatheSpeedFeedPage> createState() => _LatheSpeedFeedPageState();
}

class _LatheSpeedFeedPageState extends State<LatheSpeedFeedPage> {
  LatheUnitSystem unitSystem = LatheUnitSystem.imperial;
  LatheToolMaterial toolMaterial = LatheToolMaterial.carbide;
  LatheRecommendation recommendation = latheRecommendations.first;

  final diameterCtrl = TextEditingController(text: '1.000');
  final speedCtrl = TextEditingController();
  final feedPerRevCtrl = TextEditingController();

  LatheCalculationResult? result;
  String warning = '';

  @override
  void initState() {
    super.initState();
    _loadRecommendation(calculate: true);
  }

  @override
  void dispose() {
    diameterCtrl.dispose();
    speedCtrl.dispose();
    feedPerRevCtrl.dispose();
    super.dispose();
  }

  void _loadRecommendation({bool calculate = false}) {
    if (unitSystem == LatheUnitSystem.imperial) {
      speedCtrl.text = recommendation.sfmFor(toolMaterial).toStringAsFixed(0);
      feedPerRevCtrl.text = recommendation
          .feedInPerRevFor(toolMaterial)
          .toStringAsFixed(4);
    } else {
      speedCtrl.text = recommendation
          .cuttingSpeedMMinFor(toolMaterial)
          .toStringAsFixed(0);
      feedPerRevCtrl.text = recommendation
          .feedMmPerRevFor(toolMaterial)
          .toStringAsFixed(3);
    }

    if (calculate) {
      _calculate();
    }
  }

  void _calculate() {
    final diameter = double.tryParse(diameterCtrl.text.trim());
    final speed = double.tryParse(speedCtrl.text.trim());
    final feedPerRev = double.tryParse(feedPerRevCtrl.text.trim());

    setState(() {
      warning = '';
      result = null;

      if (diameter == null || speed == null || feedPerRev == null) {
        warning = 'Enter diameter, cutting speed, and feed per revolution.';
        return;
      }

      if (diameter <= 0 || speed <= 0 || feedPerRev <= 0) {
        warning = 'Inputs must be greater than 0.';
        return;
      }

      result = calculateLatheSpeedFeed(
        unitSystem: unitSystem,
        diameter: diameter,
        cuttingSpeed: speed,
        feedPerRev: feedPerRev,
      );
    });
  }

  void _setUnitSystem(LatheUnitSystem value) {
    if (unitSystem == value) return;
    setState(() {
      unitSystem = value;
      diameterCtrl.text = value == LatheUnitSystem.imperial ? '1.000' : '25.4';
      _loadRecommendation();
    });
    _calculate();
  }

  void _setToolMaterial(LatheToolMaterial value) {
    setState(() {
      toolMaterial = value;
      _loadRecommendation();
    });
    _calculate();
  }

  void _setRecommendation(LatheRecommendation value) {
    setState(() {
      recommendation = value;
      _loadRecommendation();
    });
    _calculate();
  }

  bool get _hasCentralMaterial {
    final name = recommendation.centralMaterialName;
    if (name == null) return false;
    return material_refs.materials.any((material) => material.name == name);
  }

  Widget _sectionTitle(String text, Color accent) {
    return Text(
      text,
      style: TextStyle(
        color: accent,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _toggleButton<T>({
    required Color accent,
    required String label,
    required T current,
    required T value,
    required ValueChanged<T> onPressed,
  }) {
    final selected = current == value;

    return Expanded(
      child: OutlinedButton(
        onPressed: () => onPressed(value),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 2),
          backgroundColor: selected
              ? accent.withValues(alpha: 0.18)
              : Colors.transparent,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: accent, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _materialDropdown(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.6), width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LatheRecommendation>(
          value: recommendation,
          isExpanded: true,
          dropdownColor: Colors.black,
          iconEnabledColor: accent,
          style: TextStyle(color: accent),
          items: latheRecommendations.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item.label, style: TextStyle(color: accent)),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            _setRecommendation(value);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final speedUnit = unitSystem == LatheUnitSystem.imperial ? 'SFM' : 'm/min';
    final diameterUnit = unitSystem == LatheUnitSystem.imperial ? 'in' : 'mm';
    final feedPerRevUnit = unitSystem == LatheUnitSystem.imperial
        ? 'in/rev'
        : 'mm/rev';
    final feedRateUnit = unitSystem == LatheUnitSystem.imperial
        ? 'in/min'
        : 'mm/min';

    return TerminalScaffold(
      title: 'Lathe Speed & Feed',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Starting-point turning calculator. Adjust for alloy, tool geometry, rigidity, depth of cut, coolant, and finish requirements.',
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            _sectionTitle('Units', accent),
            const SizedBox(height: 8),
            Row(
              children: [
                _toggleButton(
                  accent: accent,
                  label: 'IMPERIAL',
                  current: unitSystem,
                  value: LatheUnitSystem.imperial,
                  onPressed: _setUnitSystem,
                ),
                const SizedBox(width: 8),
                _toggleButton(
                  accent: accent,
                  label: 'METRIC',
                  current: unitSystem,
                  value: LatheUnitSystem.metric,
                  onPressed: _setUnitSystem,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionTitle('Material', accent),
            const SizedBox(height: 8),
            _materialDropdown(accent),
            const SizedBox(height: 8),
            Text(
              _hasCentralMaterial
                  ? 'Linked material reference: ${recommendation.centralMaterialName}'
                  : 'Lathe recommendation only: central material record not yet available.',
              style: TextStyle(color: accent.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 18),
            _sectionTitle('Tool', accent),
            const SizedBox(height: 8),
            Row(
              children: [
                _toggleButton(
                  accent: accent,
                  label: 'HSS',
                  current: toolMaterial,
                  value: LatheToolMaterial.hss,
                  onPressed: _setToolMaterial,
                ),
                const SizedBox(width: 8),
                _toggleButton(
                  accent: accent,
                  label: 'CARBIDE',
                  current: toolMaterial,
                  value: LatheToolMaterial.carbide,
                  onPressed: _setToolMaterial,
                ),
              ],
            ),
            const SizedBox(height: 18),
            terminalNumberField(
              accent: accent,
              label: 'Workpiece Diameter ($diameterUnit)',
              hint: unitSystem == LatheUnitSystem.imperial
                  ? 'ex: 1.000'
                  : 'ex: 25.4',
              controller: diameterCtrl,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: 'Cutting Speed ($speedUnit)',
              hint: unitSystem == LatheUnitSystem.imperial
                  ? 'ex: 350'
                  : 'ex: 107',
              controller: speedCtrl,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 12),
            terminalNumberField(
              accent: accent,
              label: 'Feed per Revolution ($feedPerRevUnit)',
              hint: unitSystem == LatheUnitSystem.imperial
                  ? 'ex: 0.007'
                  : 'ex: 0.178',
              controller: feedPerRevCtrl,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _loadRecommendation());
                      _calculate();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent, width: 2),
                    ),
                    child: Text(
                      'Load Recommendation',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: accent),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: terminalCalcButton(
                    accent: accent,
                    label: 'Calculate',
                    onPressed: _calculate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (warning.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  warning,
                  style: TextStyle(
                    color: accent.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            terminalResultCard(
              accent: accent,
              lines: [
                'Material: ${recommendation.label}',
                'Tool: ${toolMaterial == LatheToolMaterial.hss ? 'HSS' : 'Carbide'}',
                'RPM: ${result == null ? '—' : result!.rpm.toStringAsFixed(0)}',
                'Feed Rate: ${result == null ? '—' : result!.feedRate.toStringAsFixed(unitSystem == LatheUnitSystem.imperial ? 3 : 1)} $feedRateUnit',
                'Formula: RPM = ${unitSystem == LatheUnitSystem.imperial ? '(SFM x 12) / (pi x D)' : '(m/min x 1000) / (pi x D)'}',
                'Feed Rate = RPM x feed/rev',
              ],
            ),
            const SizedBox(height: 14),
            terminalResultCard(
              accent: accent,
              lines: [
                'Recommended starting values:',
                '${recommendation.sfmFor(toolMaterial).toStringAsFixed(0)} SFM / ${recommendation.cuttingSpeedMMinFor(toolMaterial).toStringAsFixed(0)} m/min',
                '${recommendation.feedInPerRevFor(toolMaterial).toStringAsFixed(4)} in/rev / ${recommendation.feedMmPerRevFor(toolMaterial).toStringAsFixed(3)} mm/rev',
                recommendation.note,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
