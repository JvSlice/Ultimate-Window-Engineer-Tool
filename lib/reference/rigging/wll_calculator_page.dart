import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

enum RiggingSlingType { chain, wireRope, syntheticWeb }

enum RiggingHitchType { vertical, choker, basket }

enum RiggingAngleReference { fromHorizontal, fromVertical }

class RiggingWllCalculatorPage extends StatefulWidget {
  const RiggingWllCalculatorPage({super.key});

  @override
  State<RiggingWllCalculatorPage> createState() =>
      _RiggingWllCalculatorPageState();
}

class _RiggingWllCalculatorPageState extends State<RiggingWllCalculatorPage> {
  late final TextEditingController _loadController;
  late final TextEditingController _legsController;
  late final TextEditingController _angleController;

  RiggingSlingType _slingType = RiggingSlingType.chain;
  RiggingHitchType _hitchType = RiggingHitchType.vertical;
  RiggingAngleReference _angleReference = RiggingAngleReference.fromHorizontal;

  String _selectedChainGrade = '80';
  String _selectedSize = '3/8"';

  double _totalLoad = 1000;
  int _legs = 2;
  double _angleInput = 60;

  final Map<String, Map<String, double>> _chainWllTable = {
    // Hackable comments:
    // These are practical placeholder values for app structure and workflow.
    // Replace with your preferred company-approved values later.
    '70': {
      '1/4"': 3150,
      '5/16"': 4700,
      '3/8"': 6600,
      '1/2"': 11300,
      '5/8"': 18100,
    },
    '80': {
      '1/4"': 3500,
      '5/16"': 4500,
      '3/8"': 7100,
      '1/2"': 12000,
      '5/8"': 18100,
    },
    '100': {
      '1/4"': 4300,
      '5/16"': 5700,
      '3/8"': 8800,
      '1/2"': 15000,
      '5/8"': 22600,
    },
  };

  final Map<String, double> _wireRopeWllTable = {
    '1/4"': 1400,
    '5/16"': 1960,
    '3/8"': 2800,
    '1/2"': 5000,
    '5/8"': 8000,
  };

  final Map<String, double> _syntheticWebWllTable = {
    '1"': 3200,
    '2"': 6200,
    '3"': 9300,
    '4"': 12200,
  };

  @override
  void initState() {
    super.initState();
    _loadController = TextEditingController(text: '1000');
    _legsController = TextEditingController(text: '2');
    _angleController = TextEditingController(text: '60');
  }

  @override
  void dispose() {
    _loadController.dispose();
    _legsController.dispose();
    _angleController.dispose();
    super.dispose();
  }

  void _recalc() {
    setState(() {
      _totalLoad = double.tryParse(_loadController.text.trim()) ?? 1000;
      _legs = (int.tryParse(_legsController.text.trim()) ?? 2).clamp(1, 8);
      _angleInput = double.tryParse(_angleController.text.trim()) ?? 60;
    });
  }

  List<String> _availableSizes() {
    switch (_slingType) {
      case RiggingSlingType.chain:
        return _chainWllTable[_selectedChainGrade]!.keys.toList();
      case RiggingSlingType.wireRope:
        return _wireRopeWllTable.keys.toList();
      case RiggingSlingType.syntheticWeb:
        return _syntheticWebWllTable.keys.toList();
    }
  }

  void _syncSelectedSizeIfNeeded() {
    final sizes = _availableSizes();
    if (!sizes.contains(_selectedSize)) {
      _selectedSize = sizes.first;
    }
  }

  String _slingTypeLabel(RiggingSlingType type) {
    switch (type) {
      case RiggingSlingType.chain:
        return 'Chain';
      case RiggingSlingType.wireRope:
        return 'Wire Rope';
      case RiggingSlingType.syntheticWeb:
        return 'Synthetic Web';
    }
  }

  String _hitchTypeLabel(RiggingHitchType type) {
    switch (type) {
      case RiggingHitchType.vertical:
        return 'Vertical';
      case RiggingHitchType.choker:
        return 'Choker';
      case RiggingHitchType.basket:
        return 'Basket';
    }
  }

  double _hitchMultiplier(RiggingHitchType type) {
    switch (type) {
      case RiggingHitchType.vertical:
        return 1.0;
      case RiggingHitchType.choker:
        return 0.8;
      case RiggingHitchType.basket:
        return 2.0;
    }
  }

  double _angleFromHorizontal() {
    if (_angleReference == RiggingAngleReference.fromHorizontal) {
      return _angleInput;
    }
    return 90.0 - _angleInput;
  }

  double _angleFromVertical() {
    if (_angleReference == RiggingAngleReference.fromVertical) {
      return _angleInput;
    }
    return 90.0 - _angleInput;
  }

  double _baseSingleLegVerticalWll() {
    switch (_slingType) {
      case RiggingSlingType.chain:
        return _chainWllTable[_selectedChainGrade]![_selectedSize] ?? 0;
      case RiggingSlingType.wireRope:
        return _wireRopeWllTable[_selectedSize] ?? 0;
      case RiggingSlingType.syntheticWeb:
        return _syntheticWebWllTable[_selectedSize] ?? 0;
    }
  }

  double _adjustedSingleLegWll() {
    return _baseSingleLegVerticalWll() * _hitchMultiplier(_hitchType);
  }

  double _baseSharePerLeg() {
    return _legs <= 0 ? double.infinity : _totalLoad / _legs;
  }

  double _tensionPerLeg() {
    final angleH = _angleFromHorizontal();
    final radians = angleH * math.pi / 180.0;
    final sine = math.sin(radians);

    if (_legs <= 0 || sine <= 0) {
      return double.infinity;
    }

    return _totalLoad / (_legs * sine);
  }

  double _marginLb() {
    return _adjustedSingleLegWll() - _tensionPerLeg();
  }

  double _marginPercent() {
    final demand = _tensionPerLeg();
    if (!demand.isFinite || demand <= 0) return double.infinity;
    return (_marginLb() / demand) * 100.0;
  }

  bool _passes() {
    return _adjustedSingleLegWll() >= _tensionPerLeg();
  }

  List<String> _warnings() {
    final warnings = <String>[];
    final angleH = _angleFromHorizontal();

    if (_totalLoad <= 0) {
      warnings.add('Total load must be greater than 0.');
    }

    if (_legs < 1) {
      warnings.add('At least 1 leg is required.');
    }

    if (angleH <= 0 || angleH >= 90) {
      warnings.add(
        'Angle from horizontal must be greater than 0° and less than 90°.',
      );
    }

    if (angleH > 0 && angleH < 30) {
      warnings.add(
        'Very shallow angle. Leg tension rises dramatically below 30° from horizontal.',
      );
    } else if (angleH >= 30 && angleH < 45) {
      warnings.add('Low angle. Verify rigging selection carefully.');
    }

    if (_hitchType == RiggingHitchType.choker) {
      warnings.add(
        'Choker values vary by manufacturer and sling style. Confirm actual rated data.',
      );
    }

    if (_slingType == RiggingSlingType.syntheticWeb &&
        _hitchType == RiggingHitchType.choker) {
      warnings.add(
        'Synthetic web chokers can be especially configuration-sensitive. Confirm tag data.',
      );
    }

    if (_passes() == false &&
        _adjustedSingleLegWll().isFinite &&
        _tensionPerLeg().isFinite) {
      warnings.add(
        'Selected sling configuration does not meet required demand.',
      );
    }

    warnings.add(
      'Reference values should be replaced with your approved plant/company rigging table.',
    );

    return warnings;
  }

  String _fmt(double value, {int digits = 1}) {
    if (!value.isFinite) return '---';
    return value.toStringAsFixed(digits);
  }

  @override
  Widget build(BuildContext context) {
    _syncSelectedSizeIfNeeded();

    final angleH = _angleFromHorizontal();
    final angleV = _angleFromVertical();
    final baseVerticalWll = _baseSingleLegVerticalWll();
    final adjustedWll = _adjustedSingleLegWll();
    final tensionPerLeg = _tensionPerLeg();
    final baseShare = _baseSharePerLeg();
    final warnings = _warnings();

    return TerminalScaffold(
      title: 'Rigging WLL Calculator',
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            final inputPanel = _Panel(
              title: 'Inputs',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sling Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<RiggingSlingType>(
                    segments: const [
                      ButtonSegment(
                        value: RiggingSlingType.chain,
                        label: Text('Chain'),
                      ),
                      ButtonSegment(
                        value: RiggingSlingType.wireRope,
                        label: Text('Wire Rope'),
                      ),
                      ButtonSegment(
                        value: RiggingSlingType.syntheticWeb,
                        label: Text('Web'),
                      ),
                    ],
                    selected: {_slingType},
                    onSelectionChanged: (values) {
                      setState(() {
                        _slingType = values.first;
                        _syncSelectedSizeIfNeeded();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_slingType == RiggingSlingType.chain) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedChainGrade,
                      decoration: const InputDecoration(
                        labelText: 'Chain Grade',
                        border: OutlineInputBorder(),
                      ),
                      items: _chainWllTable.keys
                          .map(
                            (grade) => DropdownMenuItem(
                              value: grade,
                              child: Text('Grade $grade'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedChainGrade = value;
                          _syncSelectedSizeIfNeeded();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  DropdownButtonFormField<String>(
                    value: _selectedSize,
                    decoration: const InputDecoration(
                      labelText: 'Sling Size',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableSizes()
                        .map(
                          (size) =>
                              DropdownMenuItem(value: size, child: Text(size)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedSize = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _loadController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _recalc(),
                    decoration: const InputDecoration(
                      labelText: 'Total Load',
                      suffixText: 'lb',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _legsController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _recalc(),
                    decoration: const InputDecoration(
                      labelText: 'Number of Legs',
                      suffixText: 'legs',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Angle Reference',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<RiggingAngleReference>(
                    segments: const [
                      ButtonSegment(
                        value: RiggingAngleReference.fromHorizontal,
                        label: Text('From Horizontal'),
                      ),
                      ButtonSegment(
                        value: RiggingAngleReference.fromVertical,
                        label: Text('From Vertical'),
                      ),
                    ],
                    selected: {_angleReference},
                    onSelectionChanged: (values) {
                      setState(() {
                        _angleReference = values.first;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _angleController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _recalc(),
                    decoration: InputDecoration(
                      labelText:
                          _angleReference ==
                              RiggingAngleReference.fromHorizontal
                          ? 'Sling Angle'
                          : 'Angle Off Vertical',
                      suffixText: 'deg',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Hitch Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<RiggingHitchType>(
                    segments: const [
                      ButtonSegment(
                        value: RiggingHitchType.vertical,
                        label: Text('Vertical'),
                      ),
                      ButtonSegment(
                        value: RiggingHitchType.choker,
                        label: Text('Choker'),
                      ),
                      ButtonSegment(
                        value: RiggingHitchType.basket,
                        label: Text('Basket'),
                      ),
                    ],
                    selected: {_hitchType},
                    onSelectionChanged: (values) {
                      setState(() {
                        _hitchType = values.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton(
                        onPressed: _recalc,
                        child: const Text('Run Calc'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _slingType = RiggingSlingType.chain;
                            _hitchType = RiggingHitchType.vertical;
                            _angleReference =
                                RiggingAngleReference.fromHorizontal;
                            _selectedChainGrade = '80';
                            _selectedSize = '3/8"';
                            _loadController.text = '1000';
                            _legsController.text = '2';
                            _angleController.text = '60';
                            _recalc();
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            );

            final resultPanel = _Panel(
              title: 'Results',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _resultRow(
                    context,
                    'Sling Type',
                    _slingTypeLabel(_slingType),
                  ),
                  if (_slingType == RiggingSlingType.chain)
                    _resultRow(context, 'Chain Grade', _selectedChainGrade),
                  _resultRow(context, 'Size', _selectedSize),
                  _resultRow(
                    context,
                    'Hitch Type',
                    _hitchTypeLabel(_hitchType),
                  ),
                  _resultRow(
                    context,
                    'Angle From Horizontal',
                    '${_fmt(angleH)}°',
                  ),
                  _resultRow(
                    context,
                    'Angle From Vertical',
                    '${_fmt(angleV)}°',
                  ),
                  _resultRow(
                    context,
                    'Base Vertical WLL',
                    '${_fmt(baseVerticalWll)} lb',
                  ),
                  _resultRow(
                    context,
                    'Adjusted WLL',
                    '${_fmt(adjustedWll)} lb',
                    emphasize: true,
                  ),
                  _resultRow(
                    context,
                    'Base Share Per Leg',
                    '${_fmt(baseShare)} lb',
                  ),
                  _resultRow(
                    context,
                    'Required Tension Per Leg',
                    '${_fmt(tensionPerLeg)} lb',
                    emphasize: true,
                  ),
                  _resultRow(context, 'Margin', '${_fmt(_marginLb())} lb'),
                  _resultRow(
                    context,
                    'Margin %',
                    '${_fmt(_marginPercent())} %',
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _passes() ? 'STATUS: PASS' : 'STATUS: FAIL',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );

            final notesPanel = _Panel(
              title: 'Warnings / Notes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: warnings
                    .map(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• $w'),
                      ),
                    )
                    .toList(),
              ),
            );

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Column(children: [inputPanel])),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          resultPanel,
                          const SizedBox(height: 16),
                          notesPanel,
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  inputPanel,
                  const SizedBox(height: 16),
                  resultPanel,
                  const SizedBox(height: 16),
                  notesPanel,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _resultRow(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    final style = emphasize
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
