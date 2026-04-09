import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

enum HitchType { vertical, choker, basket }

enum AngleReference { fromHorizontal, fromVertical }

class RiggingLoadCalculatorPage extends StatefulWidget {
  const RiggingLoadCalculatorPage({super.key});

  @override
  State<RiggingLoadCalculatorPage> createState() =>
      _RiggingLoadCalculatorPageState();
}

class _RiggingLoadCalculatorPageState extends State<RiggingLoadCalculatorPage> {
  late final TextEditingController _loadController;
  late final TextEditingController _legsController;
  late final TextEditingController _angleController;

  HitchType _hitchType = HitchType.vertical;
  AngleReference _angleReference = AngleReference.fromHorizontal;

  double _totalLoad = 1000.0;
  int _legs = 2;
  double _angleInput = 60.0;

  @override
  void initState() {
    super.initState();
    _loadController = TextEditingController(
      text: _totalLoad.toStringAsFixed(0),
    );
    _legsController = TextEditingController(text: _legs.toString());
    _angleController = TextEditingController(
      text: _angleInput.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _loadController.dispose();
    _legsController.dispose();
    _angleController.dispose();
    super.dispose();
  }

  void _recalculate() {
    setState(() {
      _totalLoad = _parseDouble(_loadController.text, fallback: 1000.0);
      _legs = _parseInt(_legsController.text, fallback: 2).clamp(1, 8);
      _angleInput = _parseDouble(_angleController.text, fallback: 60.0);
    });
  }

  double _parseDouble(String value, {required double fallback}) {
    return double.tryParse(value.trim()) ?? fallback;
  }

  int _parseInt(String value, {required int fallback}) {
    return int.tryParse(value.trim()) ?? fallback;
  }

  String _hitchLabel(HitchType type) {
    switch (type) {
      case HitchType.vertical:
        return 'Vertical';
      case HitchType.choker:
        return 'Choker';
      case HitchType.basket:
        return 'Basket';
    }
  }

  double _hitchMultiplier(HitchType type) {
    switch (type) {
      // Hackable comments:
      // These are common field-reference multipliers, not a substitute
      // for manufacturer data or formal rigging procedures.
      case HitchType.vertical:
        return 1.0;
      case HitchType.choker:
        return 0.8;
      case HitchType.basket:
        return 2.0;
    }
  }

  double _angleFromHorizontalDegrees() {
    if (_angleReference == AngleReference.fromHorizontal) {
      return _angleInput;
    }
    return 90.0 - _angleInput;
  }

  double _angleFromVerticalDegrees() {
    if (_angleReference == AngleReference.fromVertical) {
      return _angleInput;
    }
    return 90.0 - _angleInput;
  }

  double _tensionFactor() {
    // Standard equal-leg approximation:
    // Tension per leg = Total Load / (legs * sin(angle from horizontal))
    final angleH = _angleFromHorizontalDegrees();
    final radians = angleH * math.pi / 180.0;
    final sine = math.sin(radians);

    if (sine <= 0) {
      return double.infinity;
    }
    return 1.0 / sine;
  }

  double _baseSharePerLeg() {
    return _totalLoad / _legs;
  }

  double _tensionPerLeg() {
    final factor = _tensionFactor();
    if (!factor.isFinite) return double.infinity;
    return _baseSharePerLeg() * factor;
  }

  double _effectiveDemandPerLegAfterHitch() {
    final multiplier = _hitchMultiplier(_hitchType);
    if (multiplier <= 0) return double.infinity;
    return _tensionPerLeg() / multiplier;
  }

  List<String> _warnings() {
    final warnings = <String>[];

    final angleH = _angleFromHorizontalDegrees();
    final angleV = _angleFromVerticalDegrees();

    if (_totalLoad <= 0) {
      warnings.add('Total load must be greater than 0.');
    }

    if (_legs < 1) {
      warnings.add('Number of legs must be at least 1.');
    }

    if (angleH <= 0 || angleH >= 90) {
      warnings.add(
        'Angle from horizontal must stay between 0° and 90° (not inclusive).',
      );
    }

    if (angleV < 0 || angleV >= 90) {
      warnings.add('Angle from vertical must stay between 0° and 90°.');
    }

    if (angleH > 0 && angleH < 30) {
      warnings.add(
        'Very shallow sling angle. Tension rises dramatically below 30° from horizontal.',
      );
    } else if (angleH >= 30 && angleH < 45) {
      warnings.add(
        'Low sling angle. Use caution and verify capacity carefully.',
      );
    }

    if (_hitchType == HitchType.basket && _legs == 1) {
      warnings.add(
        'Basket hitch is typically used as a doubled support configuration. Review setup carefully.',
      );
    }

    if (_hitchType == HitchType.choker) {
      warnings.add(
        'Choker hitch reduces effective capacity. Confirm actual sling manufacturer rating.',
      );
    }

    if (_tensionPerLeg().isInfinite) {
      warnings.add('Invalid geometry. Check angle input.');
    }

    return warnings;
  }

  String _format(double value, {int digits = 1}) {
    if (!value.isFinite) return '---';
    return value.toStringAsFixed(digits);
  }

  @override
  Widget build(BuildContext context) {
    final angleH = _angleFromHorizontalDegrees();
    final angleV = _angleFromVerticalDegrees();
    final baseShare = _baseSharePerLeg();
    final tensionPerLeg = _tensionPerLeg();
    final hitchMultiplier = _hitchMultiplier(_hitchType);
    final effectiveDemand = _effectiveDemandPerLegAfterHitch();
    final percentIncrease = tensionPerLeg.isFinite && baseShare > 0
        ? ((tensionPerLeg / baseShare) - 1.0) * 100.0
        : double.infinity;
    final warnings = _warnings();

    return TerminalScaffold(
      title: 'Rigging Load Calculator',
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;

            final inputPanel = _Panel(
              title: 'Inputs',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNumberField(
                    label: 'Total Load',
                    controller: _loadController,
                    suffix: 'lb',
                    onChanged: (_) => _recalculate(),
                  ),
                  const SizedBox(height: 12),
                  _buildNumberField(
                    label: 'Number of Sling Legs',
                    controller: _legsController,
                    suffix: 'legs',
                    onChanged: (_) => _recalculate(),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Angle Reference',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<AngleReference>(
                    segments: const [
                      ButtonSegment(
                        value: AngleReference.fromHorizontal,
                        label: Text('From Horizontal'),
                      ),
                      ButtonSegment(
                        value: AngleReference.fromVertical,
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

                  _buildNumberField(
                    label: _angleReference == AngleReference.fromHorizontal
                        ? 'Sling Angle'
                        : 'Angle Off Vertical',
                    controller: _angleController,
                    suffix: 'deg',
                    onChanged: (_) => _recalculate(),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Hitch Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<HitchType>(
                    segments: const [
                      ButtonSegment(
                        value: HitchType.vertical,
                        label: Text('Vertical'),
                      ),
                      ButtonSegment(
                        value: HitchType.choker,
                        label: Text('Choker'),
                      ),
                      ButtonSegment(
                        value: HitchType.basket,
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
                        onPressed: _recalculate,
                        child: const Text('Run Calc'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _totalLoad = 1000;
                            _legs = 2;
                            _angleInput = 60;
                            _hitchType = HitchType.vertical;
                            _angleReference = AngleReference.fromHorizontal;

                            _loadController.text = '1000';
                            _legsController.text = '2';
                            _angleController.text = '60';
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            );

            final resultsPanel = _Panel(
              title: 'Results',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _resultRow(context, 'Hitch Type', _hitchLabel(_hitchType)),
                  _resultRow(
                    context,
                    'Hitch Multiplier',
                    '${_format(hitchMultiplier, digits: 2)} x',
                  ),
                  _resultRow(
                    context,
                    'Angle From Horizontal',
                    '${_format(angleH)}°',
                  ),
                  _resultRow(
                    context,
                    'Angle From Vertical',
                    '${_format(angleV)}°',
                  ),
                  _resultRow(
                    context,
                    'Base Share Per Leg',
                    '${_format(baseShare)} lb',
                  ),
                  _resultRow(
                    context,
                    'Actual Tension Per Leg',
                    '${_format(tensionPerLeg)} lb',
                    emphasize: true,
                  ),
                  _resultRow(
                    context,
                    'Angle Increase Over Base Share',
                    percentIncrease.isFinite
                        ? '${_format(percentIncrease)} %'
                        : '---',
                  ),
                  _resultRow(
                    context,
                    'Effective Demand After Hitch',
                    '${_format(effectiveDemand)} lb',
                    emphasize: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Interpretation:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use "Actual Tension Per Leg" to understand what each leg is carrying based on sling angle. '
                    'Use "Effective Demand After Hitch" as a quick field-style comparison number after hitch reduction.',
                  ),
                ],
              ),
            );

            final warningPanel = _Panel(
              title: 'Warnings / Notes',
              child: warnings.isEmpty
                  ? const Text('No warnings.')
                  : Column(
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

            final diagramPanel = _Panel(
              title: 'Quick Visual',
              child: SizedBox(
                height: 260,
                child: CustomPaint(
                  painter: _RiggingDiagramPainter(
                    angleFromHorizontalDeg: angleH.isFinite ? angleH : 0,
                    legs: _legs,
                  ),
                  child: const Center(),
                ),
              ),
            );

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          inputPanel,
                          const SizedBox(height: 16),
                          warningPanel,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          resultsPanel,
                          const SizedBox(height: 16),
                          diagramPanel,
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
                  resultsPanel,
                  const SizedBox(height: 16),
                  warningPanel,
                  const SizedBox(height: 16),
                  diagramPanel,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required String suffix,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _resultRow(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    final valueStyle = emphasize
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
          Text(value, style: valueStyle),
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

class _RiggingDiagramPainter extends CustomPainter {
  _RiggingDiagramPainter({
    required this.angleFromHorizontalDeg,
    required this.legs,
  });

  final double angleFromHorizontalDeg;
  final int legs;

  @override
  void paint(Canvas canvas, Size size) {
    final centerTop = Offset(size.width / 2, size.height * 0.20);
    final hookPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final slingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final loadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Hook
    canvas.drawCircle(centerTop, 14, hookPaint);

    // Load block
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.76),
      width: size.width * 0.38,
      height: size.height * 0.18,
    );
    canvas.drawRect(rect, loadPaint);

    final validAngle =
        angleFromHorizontalDeg > 0 && angleFromHorizontalDeg < 90;
    if (!validAngle) {
      textPainter.text = const TextSpan(
        text: 'Invalid angle',
        style: TextStyle(fontSize: 16),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          size.height / 2 - textPainter.height / 2,
        ),
      );
      return;
    }

    final angleRad = angleFromHorizontalDeg * math.pi / 180.0;
    final drop = size.height * 0.42;
    final horizontalRun = drop / math.tan(angleRad);

    final leftTop = centerTop;
    final rightTop = centerTop;

    final leftBottom = Offset((size.width / 2) - horizontalRun, rect.top);
    final rightBottom = Offset((size.width / 2) + horizontalRun, rect.top);

    // Keep diagram reasonable on extreme values.
    if (leftBottom.dx < 8 || rightBottom.dx > size.width - 8) {
      textPainter.text = const TextSpan(
        text: 'Angle too shallow to display cleanly',
        style: TextStyle(fontSize: 14),
      );
      textPainter.layout(maxWidth: size.width - 20);
      textPainter.paint(canvas, Offset(10, size.height * 0.48));
      return;
    }

    // Two-leg visual by default.
    canvas.drawLine(leftTop, leftBottom, slingPaint);
    canvas.drawLine(rightTop, rightBottom, slingPaint);

    // Show vertical centerline.
    final centerlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      centerTop,
      Offset(size.width / 2, rect.top),
      centerlinePaint,
    );

    // Labels
    textPainter.text = TextSpan(
      text: '${angleFromHorizontalDeg.toStringAsFixed(1)}°',
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 + 12, rect.top - 34));

    textPainter.text = TextSpan(
      text: '$legs leg${legs == 1 ? '' : 's'}',
      style: const TextStyle(fontSize: 14),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(12, 12));

    textPainter.text = const TextSpan(
      text: 'Load',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2, rect.center.dy - 8),
    );
  }

  @override
  bool shouldRepaint(covariant _RiggingDiagramPainter oldDelegate) {
    return oldDelegate.angleFromHorizontalDeg != angleFromHorizontalDeg ||
        oldDelegate.legs != legs;
  }
}
