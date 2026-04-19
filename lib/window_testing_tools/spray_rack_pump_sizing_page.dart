import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';

class SprayRackPumpSizingPage extends StatefulWidget {
  const SprayRackPumpSizingPage({super.key});

  @override
  State<SprayRackPumpSizingPage> createState() =>
      _SprayRackPumpSizingPageState();
}

class _SprayRackPumpSizingPageState extends State<SprayRackPumpSizingPage> {
  // =========================================================
  // HACKABLE CONSTANTS
  // =========================================================

  // ASTM-style defaults / warning bands requested by user
  static const double defaultTargetFlowGphPerFt2 = 5.0;
  static const double warningFlowLowGphPerFt2 = 4.0;
  static const double warningFlowHighGphPerFt2 = 6.0;
  static const double defaultSpacingIn = 12.0;

  // Default nozzle model:
  // WhirlJet 1/4BX-5 using simple Q = K * sqrt(P) estimate
  static const double defaultNozzleRatedFlowGpm = 0.50;
  static const double defaultNozzleRatedPressurePsi = 10.0;
  static const double defaultNozzleMinPressurePsi = 3.0;
  static const double defaultNozzleMaxPressurePsi = 100.0;

  // PVC Hazen-Williams roughness
  static const double pvcC = 150.0;

  // Velocity warning thresholds
  static const double headerVelocityWarningFps = 8.0;
  static const double dropVelocityWarningFps = 6.0;

  // Pressure display range factors
  static const double pressureLowFactor = 0.90;
  static const double pressureHighFactor = 1.15;

  static const double defaultSafetyFactorPercent = 15.0;

  // Approximate Sch 40 PVC IDs in inches
  static const Map<String, double> pipeIdsIn = {
    '1/2"': 0.622,
    '3/4"': 0.824,
    '1"': 1.049,
    '1-1/4"': 1.380,
    '1-1/2"': 1.610,
    '2"': 2.067,
    '2-1/2"': 2.469,
    '3"': 3.068,
  };

  // =========================================================
  // INPUT CONTROLLERS
  // =========================================================

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
  bool _overrideNozzleData = false;

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
        TextEditingController(text: defaultSpacingIn.toStringAsFixed(0));

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
      text: defaultNozzleMinPressurePsi.toStringAsFixed(0),
    );
    _nozzleMaxPressureController = TextEditingController(
      text: defaultNozzleMaxPressurePsi.toStringAsFixed(0),
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
    final Color accent = Theme.of(context).colorScheme.primary;
    final PumpCalcResult? result = _result;

    return TerminalScaffold(
      title: 'Spray Rack Pump Sizing',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              context,
              title: 'Specimen Size',
              child: Row(
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
            ),
            const SizedBox(height: 14),
            _sectionCard(
              context,
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
                          integerOnly: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          context,
                          label: 'Nozzles per Drop',
                          controller: _nozzlesPerDropController,
                          integerOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    context,
                    label: 'Nozzle Spacing (in)',
                    controller: _spacingInController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              context,
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
                          items: pipeIdsIn.keys.toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _supplyPipeSize = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dropdownField<String>(
                          context,
                          label: 'Drop Line Size',
                          value: _dropPipeSize,
                          items: pipeIdsIn.keys.toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _dropPipeSize = value;
                            });
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
                    displayText: (item) => item.label,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _headerFeedLayout = value;
                      });
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
            ),
            const SizedBox(height: 14),
            _sectionCard(
              context,
              title: 'Nozzle Data',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _overrideNozzleData
                        ? 'Custom nozzle values active'
                        : 'Default nozzle: WhirlJet 1/4BX-5',
                    style: TextStyle(color: accent),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: accent,
                    title: Text(
                      'Override Default Nozzle Data',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Use rated flow and pressure from known nozzle data.',
                      style: TextStyle(color: accent.withOpacity(0.75)),
                    ),
                    value: _overrideNozzleData,
                    onChanged: (value) {
                      setState(() {
                        _overrideNozzleData = value;
                      });
                    },
                  ),
                  if (_overrideNozzleData) ...[
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
            ),
            const SizedBox(height: 14),
            _sectionCard(
              context,
              title: 'Spray / Pump Assumptions',
              child: Row(
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
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _runCalculation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: accent,
                  side: BorderSide(color: accent, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Run Calc',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (result != null) ...[
              if (result.warnings.isNotEmpty)
                _warningCard(context, result.warnings),
              if (result.warnings.isNotEmpty) const SizedBox(height: 14),
              _sectionCard(
                context,
                title: 'Results',
                child: Column(
                  children: [
                    _resultRow(
                      'Specimen Area',
                      '${result.areaFt2.toStringAsFixed(2)} ft²',
                    ),
                    _resultRow('Total Nozzles', '${result.totalNozzles}'),
                    _resultRow(
                      'Required Total Flow',
                      '${result.requiredFlowGph.toStringAsFixed(1)} gph | ${result.requiredFlowGpm.toStringAsFixed(2)} gpm',
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
                      '${result.headerFrictionLossPsi.toStringAsFixed(2)} psi',
                    ),
                    _resultRow(
                      'Drop Friction Loss',
                      '${result.dropFrictionLossPsi.toStringAsFixed(2)} psi',
                    ),
                    _resultRow(
                      'Estimated Pressure Range',
                      '${result.systemPressureLowPsi.toStringAsFixed(1)} - ${result.systemPressureHighPsi.toStringAsFixed(1)} psi',
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
              ),
              const SizedBox(height: 14),
              _sectionCard(
                context,
                title: 'Notes',
                child: Text(
                  'This is a planning estimate for spray-rack sizing. It does not account for every hose loss, fitting, valve, elevation change, or calibration detail. Use it to decide whether your feed setup is probably adequate or if a pump is likely needed.',
                  style: TextStyle(color: accent.withOpacity(0.9), height: 1.35),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _runCalculation() {
    final double widthFt = _readFeetAndInches(
      _widthFtController,
      _widthInController,
    );
    final double heightFt = _readFeetAndInches(
      _heightFtController,
      _heightInController,
    );

    final int drops = _readInt(_dropsController, fallback: 1).clamp(1, 10000);
    final int nozzlesPerDrop =
        _readInt(_nozzlesPerDropController, fallback: 1).clamp(1, 10000);
    final int totalNozzles = drops * nozzlesPerDrop;

    final double spacingIn = _readDouble(
      _spacingInController,
      fallback: defaultSpacingIn,
    );

    final double supplyLengthFt = _readFeetAndInches(
      _supplyLengthFtController,
      _supplyLengthInController,
    );
    final double dropLengthFt = _readFeetAndInches(
      _dropLengthFtController,
      _dropLengthInController,
    );

    final double targetFlowGphPerFt2 = _readDouble(
      _targetFlowController,
      fallback: defaultTargetFlowGphPerFt2,
    );

    final double safetyFactorPercent = _readDouble(
      _safetyFactorController,
      fallback: defaultSafetyFactorPercent,
    );

    final double supplyIdIn = pipeIdsIn[_supplyPipeSize] ?? 1.610;
    final double dropIdIn = pipeIdsIn[_dropPipeSize] ?? 0.824;

    final double nozzleRatedFlowGpm = _overrideNozzleData
        ? _readDouble(
            _nozzleRatedFlowController,
            fallback: defaultNozzleRatedFlowGpm,
          )
        : defaultNozzleRatedFlowGpm;

    final double nozzleRatedPressurePsi = _overrideNozzleData
        ? _readDouble(
            _nozzleRatedPressureController,
            fallback: defaultNozzleRatedPressurePsi,
          )
        : defaultNozzleRatedPressurePsi;

    final double nozzleMinPressurePsi = _overrideNozzleData
        ? _readDouble(
            _nozzleMinPressureController,
            fallback: defaultNozzleMinPressurePsi,
          )
        : defaultNozzleMinPressurePsi;

    final double nozzleMaxPressurePsi = _overrideNozzleData
        ? _readDouble(
            _nozzleMaxPressureController,
            fallback: defaultNozzleMaxPressurePsi,
          )
        : defaultNozzleMaxPressurePsi;

    final double areaFt2 = math.max(0.0, widthFt) * math.max(0.0, heightFt);
    final double requiredFlowGph = areaFt2 * targetFlowGphPerFt2;
    final double requiredFlowGpm = requiredFlowGph / 60.0;

    final double requiredFlowPerNozzleGpm =
        totalNozzles > 0 ? requiredFlowGpm / totalNozzles : 0.0;

    // Q = K * sqrt(P)
    final double nozzleK = nozzleRatedPressurePsi > 0.0
        ? nozzleRatedFlowGpm / math.sqrt(nozzleRatedPressurePsi)
        : 0.0;

    final double nozzlePressurePsi =
        (nozzleK > 0.0 && requiredFlowPerNozzleGpm > 0.0)
            ? math.pow(requiredFlowPerNozzleGpm / nozzleK, 2).toDouble()
            : 0.0;

    final double effectiveHeaderLengthFt =
        _headerFeedLayout == HeaderFeedLayout.centerFed
            ? supplyLengthFt / 2.0
            : supplyLengthFt;

    final double headerVelocityFps =
        _velocityFps(requiredFlowGpm, supplyIdIn);

    final double dropFlowGpm = requiredFlowPerNozzleGpm * nozzlesPerDrop;
    final double dropVelocityFps = _velocityFps(dropFlowGpm, dropIdIn);

    final double headerFrictionLossPsi = _hazenWilliamsPressureLossPsi(
      flowGpm: requiredFlowGpm,
      lengthFt: effectiveHeaderLengthFt,
      insideDiameterIn: supplyIdIn,
      c: pvcC,
    );

    final double dropFrictionLossPsi = _hazenWilliamsPressureLossPsi(
      flowGpm: dropFlowGpm,
      lengthFt: dropLengthFt,
      insideDiameterIn: dropIdIn,
      c: pvcC,
    );

    final double estimatedSystemPressurePsi =
        nozzlePressurePsi + headerFrictionLossPsi + dropFrictionLossPsi;

    final double systemPressureLowPsi =
        math.max(0.0, estimatedSystemPressurePsi * pressureLowFactor);
    final double systemPressureHighPsi =
        math.max(0.0, estimatedSystemPressurePsi * pressureHighFactor);

    final double minimumPumpFlowGpm = requiredFlowGpm;
    final double recommendedPumpFlowGpm =
        minimumPumpFlowGpm * (1.0 + (safetyFactorPercent / 100.0));

    final double rackCoverageWidthFt =
        drops <= 1 ? (spacingIn / 12.0) : ((drops - 1) * spacingIn / 12.0);
    final double rackCoverageHeightFt = nozzlesPerDrop <= 1
        ? (spacingIn / 12.0)
        : ((nozzlesPerDrop - 1) * spacingIn / 12.0);

    final List<String> warnings = <String>[];

    if (targetFlowGphPerFt2 < warningFlowLowGphPerFt2 ||
        targetFlowGphPerFt2 > warningFlowHighGphPerFt2) {
      warnings.add(
        'Target flow is outside your warning band of '
        '$warningFlowLowGphPerFt2 to $warningFlowHighGphPerFt2 gal/ft²·hr.',
      );
    }

    if ((spacingIn - 12.0).abs() > 0.01) {
      warnings.add(
        'Nozzle spacing is not 12 in. ASTM spacing warning triggered.',
      );
    }

    if (rackCoverageWidthFt < widthFt) {
      warnings.add(
        'Rack coverage width appears smaller than specimen width.',
      );
    }

    if (rackCoverageHeightFt < heightFt) {
      warnings.add(
        'Rack coverage height appears smaller than specimen height.',
      );
    }

    if (headerVelocityFps > headerVelocityWarningFps) {
      warnings.add(
        'Header velocity is high at ${headerVelocityFps.toStringAsFixed(2)} ft/s.',
      );
    }

    if (dropVelocityFps > dropVelocityWarningFps) {
      warnings.add(
        'Drop velocity is high at ${dropVelocityFps.toStringAsFixed(2)} ft/s.',
      );
    }

    if (nozzlePressurePsi < nozzleMinPressurePsi) {
      warnings.add(
        'Estimated nozzle pressure is below entered nozzle minimum.',
      );
    }

    if (nozzlePressurePsi > nozzleMaxPressurePsi) {
      warnings.add(
        'Estimated nozzle pressure is above entered nozzle maximum.',
      );
    }

    if (areaFt2 <= 0.0) {
      warnings.add('Specimen area is zero or invalid.');
    }

    if (requiredFlowGpm <= 0.0) {
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
        headerFrictionLossPsi: headerFrictionLossPsi,
        dropFrictionLossPsi: dropFrictionLossPsi,
        systemPressureLowPsi: systemPressureLowPsi,
        systemPressureHighPsi: systemPressureHighPsi,
        minimumPumpFlowGpm: minimumPumpFlowGpm,
        recommendedPumpFlowGpm: recommendedPumpFlowGpm,
        warnings: warnings,
      );
    });
  }

  double _readFeetAndInches(
    TextEditingController feetController,
    TextEditingController inchesController,
  ) {
    final double feet = _readDouble(feetController, fallback: 0.0);
    final double inches = _readDouble(inchesController, fallback: 0.0);
    return feet + (inches / 12.0);
  }

  double _readDouble(
    TextEditingController controller, {
    double fallback = 0.0,
  }) {
    return double.tryParse(controller.text.trim()) ?? fallback;
  }

  int _readInt(
    TextEditingController controller, {
    int fallback = 0,
  }) {
    return int.tryParse(controller.text.trim()) ?? fallback;
  }

  double _velocityFps(double flowGpm, double insideDiameterIn) {
    if (flowGpm <= 0.0 || insideDiameterIn <= 0.0) return 0.0;
    return 0.4085 * flowGpm / (insideDiameterIn * insideDiameterIn);
  }

  double _hazenWilliamsPressureLossPsi({
    required double flowGpm,
    required double lengthFt,
    required double insideDiameterIn,
    required double c,
  }) {
    if (flowGpm <= 0.0 ||
        lengthFt <= 0.0 ||
        insideDiameterIn <= 0.0 ||
        c <= 0.0) {
      return 0.0;
    }

    final double headLossPer100Ft = 0.2083 *
        math.pow(100.0 / c, 1.852).toDouble() *
        math.pow(flowGpm, 1.852).toDouble() /
        math.pow(insideDiameterIn, 4.8655).toDouble();

    final double totalHeadLossFt = headLossPer100Ft * (lengthFt / 100.0);
    return totalHeadLossFt / 2.31;
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final Color accent = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _warningCard(BuildContext context, List<String> warnings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Warnings',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          for (final String warning in warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• $warning',
                style: const TextStyle(color: Colors.amber),
              ),
            ),
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
    bool integerOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, label),
        const SizedBox(height: 6),
        _terminalTextField(
          context,
          controller: controller,
          keyboardType: integerOnly
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
    final Color accent = Theme.of(context).colorScheme.primary;

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
            border: Border.all(color: accent),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.black,
              iconEnabledColor: accent,
              style: TextStyle(color: accent),
              onChanged: onChanged,
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(displayText?.call(item) ?? item.toString()),
                );
              }).toList(),
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
    final Color accent = Theme.of(context).colorScheme.primary;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: accent),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: accent.withOpacity(0.45)),
        filled: true,
        fillColor: Colors.black,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent),
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
    final Color accent = Theme.of(context).colorScheme.primary;
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
              style: const TextStyle(color: Colors.white),
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
  final double headerFrictionLossPsi;
  final double dropFrictionLossPsi;
  final double systemPressureLowPsi;
  final double systemPressureHighPsi;
  final double minimumPumpFlowGpm;
  final double recommendedPumpFlowGpm;
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
    required this.headerFrictionLossPsi,
    required this.dropFrictionLossPsi,
    required this.systemPressureLowPsi,
    required this.systemPressureHighPsi,
    required this.minimumPumpFlowGpm,
    required this.recommendedPumpFlowGpm,
    required this.warnings,
  });
}
