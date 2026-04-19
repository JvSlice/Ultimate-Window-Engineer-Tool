import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';

/// Spray Rack Pump Sizing Page
///
/// PURPOSE:
/// Helps estimate required flow, nozzle pressure, line velocity, and rough pump
/// sizing for ASTM-style spray rack water application on window test specimens.
///
/// IMPORTANT:
/// - This is an ENGINEERING ESTIMATE tool, not a substitute for calibration.
/// - This page is intentionally HACKABLE.
/// - Keep constants grouped below so you can tune assumptions later.
///
/// HACKABLE:
/// - PVC IDs
/// - velocity warning thresholds
/// - pressure range spread
/// - default nozzle data
/// - safety factor defaults
class SprayRackPumpSizingPage extends StatefulWidget {
  const SprayRackPumpSizingPage({super.key});

  @override
  State<SprayRackPumpSizingPage> createState() =>
      _SprayRackPumpSizingPageState();
}

class _SprayRackPumpSizingPageState extends State<SprayRackPumpSizingPage> {
  // =========================
  // HACKABLE DEFAULTS
  // =========================

  /// ASTM-style target used in this tool.
  static const double defaultTargetFlowGphPerFt2 = 5.0;

  /// Yellow warning thresholds requested by user.
  static const double lowAstmFlowWarning = 4.0;
  static const double highAstmFlowWarning = 6.0;

  /// Requested default spacing.
  static const double defaultNozzleSpacingIn = 12.0;

  /// Default nozzle data for WhirlJet 1/4BX-5.
  /// Current tool models nozzle behavior as:
  /// Q = K * sqrt(P)
  /// where Q = gpm and P = psi.
  static const double defaultNozzleRatedFlowGpm = 0.5;
  static const double defaultNozzleRatedPressurePsi = 10.0;
  static const double defaultNozzleMinPsi = 3.0;
  static const double defaultNozzleMaxPsi = 100.0;

  /// Hazen-Williams roughness coefficient for smooth PVC.
  static const double pvcHazenWilliamsC = 150.0;

  /// Velocity warning thresholds.
  static const double headerVelocityWarnFps = 8.0;
  static const double dropVelocityWarnFps = 6.0;

  /// Pressure range spread to present "rough estimate" range.
  static const double pressureLowFactor = 0.90;
  static const double pressureHighFactor = 1.15;

  /// Pump recommendation default safety factor.
  static const double defaultSafetyFactorPercent = 15.0;

  // =========================
  // PIPE DATA
  // =========================

  /// Approximate Schedule 40 PVC internal diameters in inches.
  /// HACKABLE: update if you want SDR pipe, Sch 80, hose IDs, etc.
  static const Map<String, double> pvcInternalDiametersIn = {
    '1/2"': 0.622,
    '3/4"': 0.824,
    '1"': 1.049,
    '1-1/4"': 1.380,
    '1-1/2"': 1.610,
    '2"': 2.067,
    '2-1/2"': 2.469,
    '3"': 3.068,
  };

  // =========================
  // CONTROLLERS
  // =========================

  late final TextEditingController _widthFtController;
  late final TextEditingController _widthInController;
  late final TextEditingController _heightFtController;
  late final TextEditingController _heightInController;

  late final TextEditingController _dropsController;
  late final TextEditingController _nozzlesPerDropController;

  late final TextEditingController _spacingInController;

  late final TextEditingController _supplyLengthFtController;
  late final TextEditingController _supplyLengthInController;
  late final TextEditingController _dropLengthFtController;
  late final TextEditingController _dropLengthInController;

  late final TextEditingController _targetFlowController;
  late final TextEditingController _safetyFactorController;

  late final TextEditingController _nozzleRatedFlowController;
  late final TextEditingController _nozzleRatedPressureController;
  late final TextEditingController _nozzleMinPressureController;
  late final TextEditingController _nozzleMaxPressureController;

  String _supplyPipeSize = '1-1/2"';
  String _dropPipeSize = '3/4"';

  HeaderFeedLayout _headerFeedLayout = HeaderFeedLayout.oneEnd;
  bool _useCustomNozzleData = false;

  PumpCalcResult? _result;

  @override
  void initState() {
    super.initState();

    _widthFtController = TextEditingController(text: '6');
    _widthInController = TextEditingController(text: '0');
    _heightFtController = TextEditingController(text: '6');
    _heightInController = TextEditingController(text: '0');

    _dropsController = TextEditingController(text: '7');
    _nozzlesPerDropController = TextEditingController(text: '7');

    _spacingInController =
        TextEditingController(text: defaultNozzleSpacingIn.toStringAsFixed(0));

    _supplyLengthFtController = TextEditingController(text: '20');
    _supplyLengthInController = TextEditingController(text: '0');
    _dropLengthFtController = TextEditingController(text: '8');
    _dropLengthInController = TextEditingController(text: '0');

    _targetFlowController = TextEditingController(
      text: defaultTargetFlowGphPerFt2.toStringAsFixed(1),
    );
    _safetyFactorController = TextEditingController(
      text: defaultSafetyFactorPercent.toStringAsFixed(0),
    );

    _nozzleRatedFlowController = TextEditingController(
      text: defaultNozzleRatedFlowGpm.toStringAsFixed(2),
    );
    _nozzleRatedPressureController = TextEditingController(
      text: defaultNozzleRatedPressurePsi.toStringAsFixed(0),
    );
    _nozzleMinPressureController = TextEditingController(
      text: defaultNozzleMinPsi.toStringAsFixed(0),
    );
    _nozzleMaxPressureController = TextEditingController(
      text: defaultNozzleMaxPsi.toStringAsFixed(0),
    );

    _runCalculation();
  }

  @override
  void dispose() {
    _widthFtController.dispose();
    _widthInController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();

    _dropsController.dispose();
    _nozzlesPerDropController.dispose();

    _spacingInController.dispose();

    _supplyLengthFtController.dispose();
    _supplyLengthInController.dispose();
    _dropLengthFtController.dispose();
    _dropLengthInController.dispose();

    _targetFlowController.dispose();
    _safetyFactorController.dispose();

    _nozzleRatedFlowController.dispose();
    _nozzleRatedPressureController.dispose();
    _nozzleMinPressureController.dispose();
    _nozzleMaxPressureController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final result = _result;

    return TerminalScaffold(
      title: 'Spray Rack Pump Sizing',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              context,
              'ASTM-Style Spray Rack Pump Sizing',
              accent,
            ),
            const SizedBox(height: 8),
            _terminalText(
              context,
              'Estimate required spray flow, per-nozzle demand, rough nozzle pressure, line velocity, friction loss, and suggested pump sizing for spray-rack water application.',
            ),
            const SizedBox(height: 16),

            _buildSpecimenSection(context, accent),
            const SizedBox(height: 16),

            _buildRackSection(context, accent),
            const SizedBox(height: 16),

            _buildPipingSection(context, accent),
            const SizedBox(height: 16),

            _buildNozzleSection(context, accent),
            const SizedBox(height: 16),

            _buildAssumptionSection(context, accent),
            const SizedBox(height: 16),

            _buildRunButton(context, accent),
            const SizedBox(height: 18),

            if (result != null) ...[
              _buildWarningsSection(context, accent, result),
              const SizedBox(height: 16),
              _buildResultsSection(context, accent, result),
              const SizedBox(height: 16),
              _buildNotesSection(context, accent, result),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // UI SECTIONS
  // =========================

  Widget _buildSpecimenSection(BuildContext context, Color accent) {
    return _terminalCard(
      context,
      accent,
      title: 'Specimen Size',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _feetInchesInput(
                  context,
                  label: 'Width',
                  feetController: _widthFtController,
                  inchesController: _widthInController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _feetInchesInput(
                  context,
                  label: 'Height',
                  feetController: _heightFtController,
                  inchesController: _heightInController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRackSection(BuildContext context, Color accent) {
    return _terminalCard(
      context,
      accent,
      title: 'Rack Layout',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _numberField(
                  context,
                  label: 'Number of Drops',
                  controller: _dropsController,
                  hint: 'Vertical columns',
                  isInteger: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(
                  context,
                  label: 'Nozzles per Drop',
                  controller: _nozzlesPerDropController,
                  hint: 'Vertical nozzle count',
                  isInteger: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _numberField(
            context,
            label: 'Nozzle Spacing (in)',
            controller: _spacingInController,
            hint: 'Applies horizontally and vertically',
          ),
        ],
      ),
    );
  }

  Widget _buildPipingSection(BuildContext context, Color accent) {
    return _terminalCard(
      context,
      accent,
      title: 'Piping / Layout',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _dropdownField<String>(
                  context,
                  label: 'Supply Line Size',
                  value: _supplyPipeSize,
                  items: pvcInternalDiametersIn.keys.toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _supplyPipeSize = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdownField<String>(
                  context,
                  label: 'Drop Line Size',
                  value: _dropPipeSize,
                  items: pvcInternalDiametersIn.keys.toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _dropPipeSize = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _dropdownField<HeaderFeedLayout>(
            context,
            label: 'Header Feed Layout',
            value: _headerFeedLayout,
            items: HeaderFeedLayout.values,
            displayText: (value) => value.label,
            onChanged: (value) {
              if (value == null) return;
              setState(() => _headerFeedLayout = value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _feetInchesInput(
                  context,
                  label: 'Supply Header Length',
                  feetController: _supplyLengthFtController,
                  inchesController: _supplyLengthInController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _feetInchesInput(
                  context,
                  label: 'Drop Length',
                  feetController: _dropLengthFtController,
                  inchesController: _dropLengthInController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNozzleSection(BuildContext context, Color accent) {
    return _terminalCard(
      context,
      accent,
      title: 'Nozzle Model',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _terminalText(
            context,
            _useCustomNozzleData
                ? 'Custom nozzle curve using Rated Flow @ Rated Pressure.'
                : 'Default nozzle: WhirlJet 1/4BX-5 modeled from 0.5 gpm @ 10 psi.',
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: accent,
            title: Text(
              'Override Default Nozzle Data',
              style: TextStyle(color: accent, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Use rated flow and pressure from your actual nozzle data.',
              style: TextStyle(color: accent.withValues(alpha: 0.8)),
            ),
            value: _useCustomNozzleData,
            onChanged: (value) {
              setState(() => _useCustomNozzleData = value);
            },
          ),
          const SizedBox(height: 8),
          if (_useCustomNozzleData) ...[
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    context,
                    label: 'Rated Flow (gpm)',
                    controller: _nozzleRatedFlowController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numberField(
                    context,
                    label: 'Rated Pressure (psi)',
                    controller: _nozzleRatedPressureController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    context,
                    label: 'Nozzle Min Pressure (psi)',
                    controller: _nozzleMinPressureController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numberField(
                    context,
                    label: 'Nozzle Max Pressure (psi)',
                    controller: _nozzleMaxPressureController,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssumptionSection(BuildContext context, Color accent) {
    return _terminalCard(
      context,
      accent,
      title: 'Spray / Pump Assumptions',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _numberField(
                  context,
                  label: 'Target Flow (gal/ft²·hr)',
                  controller: _targetFlowController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(
                  context,
                  label: 'Pump Safety Factor (%)',
                  controller: _safetyFactorController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunButton(BuildContext context, Color accent) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _runCalculation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Run Calc',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWarningsSection(
    BuildContext context,
    Color accent,
    PumpCalcResult result,
  ) {
    if (result.warnings.isEmpty) {
      return _terminalCard(
        context,
        accent,
        title: 'Warnings',
        child: _terminalText(context, 'No warning flags triggered.'),
      );
    }

    return _terminalCard(
      context,
      Colors.amber,
      title: 'Warnings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: result.warnings
            .map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '• $warning',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildResultsSection(
    BuildContext context,
    Color accent,
    PumpCalcResult result,
  ) {
    return _terminalCard(
      context,
      accent,
      title: 'Results',
      child: Column(
        children: [
          _resultRow('Specimen Area', '${result.areaFt2.toStringAsFixed(2)} ft²'),
          _resultRow(
            'Total Nozzles',
            result.totalNozzles.toString(),
          ),
          _resultRow(
            'Required Total Flow',
            '${result.requiredFlowGph.toStringAsFixed(1)} gph  |  ${result.requiredFlowGpm.toStringAsFixed(2)} gpm',
          ),
          _resultRow(
            'Required Flow per Nozzle',
            '${result.requiredFlowPerNozzleGpm.toStringAsFixed(3)} gpm',
          ),
          _resultRow(
            'Estimated Nozzle Pressure',
            '${result.nozzlePressurePsi.toStringAsFixed(1)} psi',
          ),
          _resultRow(
            'Header Velocity',
            '${result.headerVelocityFps.toStringAsFixed(2)} ft/s',
          ),
          _resultRow(
            'Drop Velocity',
            '${result.dropVelocityFps.toStringAsFixed(2)} ft/s',
          ),
          _resultRow(
            'Header Friction Loss',
            '${result.headerFrictionPsi.toStringAsFixed(2)} psi',
          ),
          _resultRow(
            'Drop Friction Loss',
            '${result.dropFrictionPsi.toStringAsFixed(2)} psi',
          ),
          _resultRow(
            'Estimated System Pressure',
            '${result.systemPressureLowPsi.toStringAsFixed(1)} – ${result.systemPressureHighPsi.toStringAsFixed(1)} psi',
          ),
          _resultRow(
            'Minimum Pump Flow',
            '${result.minimumPumpFlowGpm.toStringAsFixed(2)} gpm',
          ),
          _resultRow(
            'Recommended Pump Flow',
            '${result.recommendedPumpFlowGpm.toStringAsFixed(2)} gpm',
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(
    BuildContext context,
    Color accent,
    PumpCalcResult result,
  ) {
    return _terminalCard(
      context,
      accent,
      title: 'Engineering Notes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _terminalText(
            context,
            'This tool estimates whether your available feed likely has enough pressure/flow or whether a dedicated pump is likely needed.',
          ),
          const SizedBox(height: 8),
          _terminalText(
            context,
            'It does NOT model every hose loss, fitting loss, regulator, elevation change, or imperfect rack balance. Use it as a sizing and planning tool before final calibration.',
          ),
          const SizedBox(height: 8),
          _terminalText(
            context,
            'Current header layout assumption: ${result.headerFeedLabel}. All drops are assumed identical.',
          ),
          const SizedBox(height: 8),
          _terminalText(
            context,
            'If your actual nozzle pressure must stay within a tighter band, override the nozzle data or tighten the warning rules in the HACKABLE constants.',
          ),
        ],
      ),
    );
  }

  // =========================
  // CALCULATION
  // =========================

  void _runCalculation() {
    final widthFt = _readFeetAndInches(
      _widthFtController,
      _widthInController,
    );
    final heightFt = _readFeetAndInches(
      _heightFtController,
      _heightInController,
    );

    final drops = _readInt(_dropsController, fallback: 1).clamp(1, 10000);
    final nozzlesPerDrop =
        _readInt(_nozzlesPerDropController, fallback: 1).clamp(1, 10000);
    final totalNozzles = drops * nozzlesPerDrop;

    final spacingIn = _readDouble(
      _spacingInController,
      fallback: defaultNozzleSpacingIn,
    ).clamp(0.1, 999.0);

    final supplyLengthFt = _readFeetAndInches(
      _supplyLengthFtController,
      _supplyLengthInController,
    );
    final dropLengthFt = _readFeetAndInches(
      _dropLengthFtController,
      _dropLengthInController,
    );

    final targetFlowGphPerFt2 = _readDouble(
      _targetFlowController,
      fallback: defaultTargetFlowGphPerFt2,
    );

    final safetyFactorPercent = _readDouble(
      _safetyFactorController,
      fallback: defaultSafetyFactorPercent,
    ).clamp(0, 500);

    final supplyIdIn = pvcInternalDiametersIn[_supplyPipeSize] ?? 1.610;
    final dropIdIn = pvcInternalDiametersIn[_dropPipeSize] ?? 0.824;

    final nozzleRatedFlow = _useCustomNozzleData
        ? _readDouble(_nozzleRatedFlowController, fallback: defaultNozzleRatedFlowGpm)
        : defaultNozzleRatedFlowGpm;

    final nozzleRatedPressure = _useCustomNozzleData
        ? _readDouble(_nozzleRatedPressureController, fallback: defaultNozzleRatedPressurePsi)
        : defaultNozzleRatedPressurePsi;

    final nozzleMinPressure = _useCustomNozzleData
        ? _readDouble(_nozzleMinPressureController, fallback: defaultNozzleMinPsi)
        : defaultNozzleMinPsi;

    final nozzleMaxPressure = _useCustomNozzleData
        ? _readDouble(_nozzleMaxPressureController, fallback: defaultNozzleMaxPsi)
        : defaultNozzleMaxPsi;

    final areaFt2 = math.max(widthFt, 0) * math.max(heightFt, 0);
    final requiredFlowGph = areaFt2 * targetFlowGphPerFt2;
    final requiredFlowGpm = requiredFlowGph / 60.0;

    final requiredFlowPerNozzleGpm =
        totalNozzles > 0 ? requiredFlowGpm / totalNozzles : 0.0;

    // Nozzle K-value model: Q = K * sqrt(P)
    final nozzleK = nozzleRatedPressure > 0
        ? nozzleRatedFlow / math.sqrt(nozzleRatedPressure)
        : 0.0;

    final nozzlePressurePsi = (nozzleK > 0 && requiredFlowPerNozzleGpm > 0)
        ? math.pow(requiredFlowPerNozzleGpm / nozzleK, 2).toDouble()
        : 0.0;

    // Header effective length depends on feed style.
    final effectiveHeaderLengthFt = _headerFeedLayout == HeaderFeedLayout.centerFed
        ? supplyLengthFt / 2.0
        : supplyLengthFt;

    // Flow in header carries full rack demand.
    final headerVelocityFps =
        _velocityFps(requiredFlowGpm, supplyIdIn);

    // Each drop only carries its own nozzle flow demand.
    final dropFlowGpm = requiredFlowPerNozzleGpm * nozzlesPerDrop;
    final dropVelocityFps = _velocityFps(dropFlowGpm, dropIdIn);

    final headerFrictionPsi = _hazenWilliamsPressureLossPsi(
      flowGpm: requiredFlowGpm,
      lengthFt: effectiveHeaderLengthFt,
      insideDiameterIn: supplyIdIn,
      c: pvcHazenWilliamsC,
    );

    final dropFrictionPsi = _hazenWilliamsPressureLossPsi(
      flowGpm: dropFlowGpm,
      lengthFt: dropLengthFt,
      insideDiameterIn: dropIdIn,
      c: pvcHazenWilliamsC,
    );

    final estimatedSystemPressurePsi =
        nozzlePressurePsi + headerFrictionPsi + dropFrictionPsi;

    final systemPressureLowPsi =
        math.max(0, estimatedSystemPressurePsi * pressureLowFactor);
    final systemPressureHighPsi =
        math.max(0, estimatedSystemPressurePsi * pressureHighFactor);

    final minimumPumpFlowGpm = requiredFlowGpm;
    final recommendedPumpFlowGpm =
        minimumPumpFlowGpm * (1 + (safetyFactorPercent / 100.0));

    final rackCoverageWidthFt =
        drops <= 1 ? (spacingIn / 12.0) : ((drops - 1) * spacingIn / 12.0);
    final rackCoverageHeightFt = nozzlesPerDrop <= 1
        ? (spacingIn / 12.0)
        : ((nozzlesPerDrop - 1) * spacingIn / 12.0);

    final warnings = <String>[];

    if (targetFlowGphPerFt2 < lowAstmFlowWarning ||
        targetFlowGphPerFt2 > highAstmFlowWarning) {
      warnings.add(
        'Target flow is outside your warning band of $lowAstmFlowWarning to $highAstmFlowWarning gal/ft²·hr.',
      );
    }

    if ((spacingIn - 12.0).abs() > 0.01) {
      warnings.add(
        'Nozzle spacing is not 12 in. ASTM-style rack spacing warning triggered.',
      );
    }

    if (rackCoverageWidthFt < widthFt) {
      warnings.add(
        'Rack coverage width appears smaller than specimen width. Check drop count or spacing.',
      );
    }

    if (rackCoverageHeightFt < heightFt) {
      warnings.add(
        'Rack coverage height appears smaller than specimen height. Check nozzle count or spacing.',
      );
    }

    if (headerVelocityFps > headerVelocityWarnFps) {
      warnings.add(
        'Header line velocity is high (${headerVelocityFps.toStringAsFixed(2)} ft/s). Consider increasing supply line size.',
      );
    }

    if (dropVelocityFps > dropVelocityWarnFps) {
      warnings.add(
        'Drop line velocity is high (${dropVelocityFps.toStringAsFixed(2)} ft/s). Consider increasing drop line size.',
      );
    }

    if (nozzlePressurePsi < nozzleMinPressure) {
      warnings.add(
        'Estimated nozzle pressure is below the entered nozzle minimum (${nozzleMinPressure.toStringAsFixed(1)} psi).',
      );
    }

    if (nozzlePressurePsi > nozzleMaxPressure) {
      warnings.add(
        'Estimated nozzle pressure is above the entered nozzle maximum (${nozzleMaxPressure.toStringAsFixed(1)} psi).',
      );
    }

    if (areaFt2 <= 0) {
      warnings.add('Specimen area is zero or invalid.');
    }

    if (requiredFlowGpm <= 0) {
      warnings.add('Required total flow is zero or invalid.');
    }

    setState(() {
      _result = PumpCalcResult(
        areaFt2: areaFt2,
        totalNozzles: totalNozzles,
        requiredFlowGph: requiredFlowGph,
        requiredFlowGpm: requiredFlowGpm,
        requiredFlowPerNozzleGpm: requiredFlowPerNozzleGpm,
        nozzlePressurePsi: nozzlePressurePsi,
        headerVelocityFps: headerVelocityFps,
        dropVelocityFps: dropVelocityFps,
        headerFrictionPsi: headerFrictionPsi,
        dropFrictionPsi: dropFrictionPsi,
        systemPressureLowPsi: systemPressureLowPsi,
        systemPressureHighPsi: systemPressureHighPsi,
        minimumPumpFlowGpm: minimumPumpFlowGpm,
        recommendedPumpFlowGpm: recommendedPumpFlowGpm,
        headerFeedLabel: _headerFeedLayout.label,
        warnings: warnings,
      );
    });
  }

  // =========================
  // MATH HELPERS
  // =========================

  double _velocityFps(double flowGpm, double insideDiameterIn) {
    if (flowGpm <= 0 || insideDiameterIn <= 0) return 0;
    // Standard conversion for gpm + inches to ft/s.
    return 0.4085 * flowGpm / (insideDiameterIn * insideDiameterIn);
  }

  double _hazenWilliamsPressureLossPsi({
    required double flowGpm,
    required double lengthFt,
    required double insideDiameterIn,
    required double c,
  }) {
    if (flowGpm <= 0 || lengthFt <= 0 || insideDiameterIn <= 0 || c <= 0) {
      return 0;
    }

    // Hazen-Williams head loss in feet per 100 ft:
    // hf = 0.2083 * (100/C)^1.852 * Q^1.852 / d^4.8655
    final headLossPer100Ft = 0.2083 *
        math.pow(100.0 / c, 1.852) *
        math.pow(flowGpm, 1.852) /
        math.pow(insideDiameterIn, 4.8655);

    final totalHeadLossFt = headLossPer100Ft * (lengthFt / 100.0);

    // Convert ft of water to psi.
    return totalHeadLossFt / 2.31;
  }

  // =========================
  // INPUT HELPERS
  // =========================

  double _readFeetAndInches(
    TextEditingController feetController,
    TextEditingController inchesController,
  ) {
    final feet = _readDouble(feetController, fallback: 0);
    final inches = _readDouble(inchesController, fallback: 0);
    return feet + (inches / 12.0);
  }

  double _readDouble(
    TextEditingController controller, {
    double fallback = 0,
  }) {
    return double.tryParse(controller.text.trim()) ?? fallback;
  }

  int _readInt(
    TextEditingController controller, {
    int fallback = 0,
  }) {
    return int.tryParse(controller.text.trim()) ?? fallback;
  }

  // =========================
  // WIDGET HELPERS
  // =========================

  Widget _sectionTitle(BuildContext context, String text, Color accent) {
    return Text(
      text,
      style: TextStyle(
        color: accent,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _terminalText(BuildContext context, String text) {
    final color = Theme.of(context).colorScheme.primary;
    return Text(
      text,
      style: TextStyle(
        color: color.withValues(alpha: 0.92),
        height: 1.35,
      ),
    );
  }

  Widget _terminalCard(
    BuildContext context,
    Color borderColor, {
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: borderColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _feetInchesInput(
    BuildContext context, {
    required String label,
    required TextEditingController feetController,
    required TextEditingController inchesController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, label),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _terminalTextField(
                context,
                controller: feetController,
                hintText: 'ft',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _terminalTextField(
                context,
                controller: inchesController,
                hintText: 'in',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _numberField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hint,
    bool isInteger = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, label),
        const SizedBox(height: 6),
        _terminalTextField(
          context,
          controller: controller,
          hintText: hint,
          keyboardType: isInteger
              ? const TextInputType.numberWithOptions(decimal: false)
              : const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _dropdownField<T>(
    BuildContext context, {
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? displayText,
  }) {
    final accent = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: 0.7)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              dropdownColor: Colors.black,
              iconEnabledColor: accent,
              style: TextStyle(color: accent),
              isExpanded: true,
              onChanged: onChanged,
              items: items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(displayText?.call(item) ?? item.toString()),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _terminalTextField(
    BuildContext context, {
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType =
        const TextInputType.numberWithOptions(decimal: true),
  }) {
    final accent = Theme.of(context).colorScheme.primary;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: accent),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: accent.withValues(alpha: 0.45)),
        filled: true,
        fillColor: Colors.black,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent, width: 1.4),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    final accent = Theme.of(context).colorScheme.primary;
    return Text(
      text,
      style: TextStyle(
        color: accent,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum HeaderFeedLayout {
  oneEnd('One-End Fed Header'),
  centerFed('Center-Fed Header');

  const HeaderFeedLayout(this.label);
  final String label;
}

class PumpCalcResult {
  final double areaFt2;
  final int totalNozzles;
  final double requiredFlowGph;
  final double requiredFlowGpm;
  final double requiredFlowPerNozzleGpm;
  final double nozzlePressurePsi;
  final double headerVelocityFps;
  final double dropVelocityFps;
  final double headerFrictionPsi;
  final double dropFrictionPsi;
  final double systemPressureLowPsi;
  final double systemPressureHighPsi;
  final double minimumPumpFlowGpm;
  final double recommendedPumpFlowGpm;
  final String headerFeedLabel;
  final List<String> warnings;

  const PumpCalcResult({
    required this.areaFt2,
    required this.totalNozzles,
    required this.requiredFlowGph,
    required this.requiredFlowGpm,
    required this.requiredFlowPerNozzleGpm,
    required this.nozzlePressurePsi,
    required this.headerVelocityFps,
    required this.dropVelocityFps,
    required this.headerFrictionPsi,
    required this.dropFrictionPsi,
    required this.systemPressureLowPsi,
    required this.systemPressureHighPsi,
    required this.minimumPumpFlowGpm,
    required this.recommendedPumpFlowGpm,
    required this.headerFeedLabel,
    required this.warnings,
  });
}
