import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../terminal_scaffold.dart';

enum TorqueUnit { inchPounds, footPounds, newtonMeters }

extension TorqueUnitLabel on TorqueUnit {
  String get label {
    switch (this) {
      case TorqueUnit.inchPounds:
        return 'in-lb';
      case TorqueUnit.footPounds:
        return 'ft-lb';
      case TorqueUnit.newtonMeters:
        return 'N·m';
    }
  }
}

class TorqueExtensionResult {
  final double desiredTorqueInLb;
  final double wrenchLengthIn;
  final double extensionLengthIn;
  final double angleDegrees;
  final double effectiveLengthIn;
  final double wrenchSettingInLb;
  final double adjustmentPercent;

  const TorqueExtensionResult({
    required this.desiredTorqueInLb,
    required this.wrenchLengthIn,
    required this.extensionLengthIn,
    required this.angleDegrees,
    required this.effectiveLengthIn,
    required this.wrenchSettingInLb,
    required this.adjustmentPercent,
  });

  double actualTorqueInLbForSetting(double settingInLb) {
    return settingInLb * effectiveLengthIn / wrenchLengthIn;
  }
}

double torqueToInLb(double value, TorqueUnit unit) {
  switch (unit) {
    case TorqueUnit.inchPounds:
      return value;
    case TorqueUnit.footPounds:
      return value * 12.0;
    case TorqueUnit.newtonMeters:
      return value / 0.112985;
  }
}

double torqueFromInLb(double value, TorqueUnit unit) {
  switch (unit) {
    case TorqueUnit.inchPounds:
      return value;
    case TorqueUnit.footPounds:
      return value / 12.0;
    case TorqueUnit.newtonMeters:
      return value * 0.112985;
  }
}

TorqueExtensionResult? calculateTorqueExtension({
  required double desiredTorque,
  required TorqueUnit unit,
  required double wrenchLengthIn,
  required double extensionLengthIn,
  required double angleDegrees,
}) {
  if (desiredTorque <= 0 || wrenchLengthIn <= 0 || extensionLengthIn < 0) {
    return null;
  }

  final desiredInLb = torqueToInLb(desiredTorque, unit);
  final effectiveLength =
      wrenchLengthIn +
      extensionLengthIn * math.cos(angleDegrees * math.pi / 180);

  if (effectiveLength <= 0) return null;

  final setting = desiredInLb * wrenchLengthIn / effectiveLength;
  final adjustmentPercent = ((setting / desiredInLb) - 1.0) * 100.0;

  return TorqueExtensionResult(
    desiredTorqueInLb: desiredInLb,
    wrenchLengthIn: wrenchLengthIn,
    extensionLengthIn: extensionLengthIn,
    angleDegrees: angleDegrees,
    effectiveLengthIn: effectiveLength,
    wrenchSettingInLb: setting,
    adjustmentPercent: adjustmentPercent,
  );
}

class TorqueWrenchExtensionPage extends StatefulWidget {
  const TorqueWrenchExtensionPage({super.key});

  @override
  State<TorqueWrenchExtensionPage> createState() =>
      _TorqueWrenchExtensionPageState();
}

class _TorqueWrenchExtensionPageState extends State<TorqueWrenchExtensionPage> {
  final _desiredTorqueController = TextEditingController(text: '50');
  final _wrenchLengthController = TextEditingController(text: '18');
  final _extensionLengthController = TextEditingController(text: '3');
  final _angleController = TextEditingController(text: '0');

  TorqueUnit _unit = TorqueUnit.footPounds;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _desiredTorqueController,
      _wrenchLengthController,
      _extensionLengthController,
      _angleController,
    ]) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _desiredTorqueController.dispose();
    _wrenchLengthController.dispose();
    _extensionLengthController.dispose();
    _angleController.dispose();
    super.dispose();
  }

  double? _read(TextEditingController controller) {
    return double.tryParse(controller.text.trim());
  }

  TorqueExtensionResult? get _result {
    final desired = _read(_desiredTorqueController);
    final wrenchLength = _read(_wrenchLengthController);
    final extensionLength = _read(_extensionLengthController);
    final angle = _read(_angleController);

    if (desired == null ||
        wrenchLength == null ||
        extensionLength == null ||
        angle == null) {
      return null;
    }

    return calculateTorqueExtension(
      desiredTorque: desired,
      unit: _unit,
      wrenchLengthIn: wrenchLength,
      extensionLengthIn: extensionLength,
      angleDegrees: angle,
    );
  }

  void _reset() {
    _desiredTorqueController.text = '50';
    _wrenchLengthController.text = '18';
    _extensionLengthController.text = '3';
    _angleController.text = '0';
    setState(() {
      _unit = TorqueUnit.footPounds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final result = _result;

    return TerminalScaffold(
      title: 'Torque Wrench Extension',
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _panel(
              context,
              title: 'Inputs',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _numberField(
                    'Desired Fastener Torque',
                    _desiredTorqueController,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TorqueUnit>(
                    initialValue: _unit,
                    decoration: const InputDecoration(
                      labelText: 'Torque Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: TorqueUnit.values.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _unit = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    'Torque Wrench Length (in)',
                    _wrenchLengthController,
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    'Extension Length (in)',
                    _extensionLengthController,
                  ),
                  const SizedBox(height: 12),
                  _numberField('Extension Angle (degrees)', _angleController),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _angleChip('0° inline', 0),
                      _angleChip('90° perpendicular', 90),
                      _angleChip('180° backward', 180),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: BorderSide(color: accent),
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _panel(
              context,
              title: 'Diagram',
              child: SizedBox(
                height: 220,
                child: CustomPaint(
                  painter: _TorqueExtensionPainter(accent: accent),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _panel(
              context,
              title: 'Results',
              child: result == null
                  ? Text(
                      'Enter valid positive torque and wrench dimensions. Effective length must be greater than zero.',
                      style: TextStyle(color: accent),
                    )
                  : Column(
                      children: [
                        _row(
                          'Required Wrench Setting',
                          _formatTorqueSet(result.wrenchSettingInLb),
                        ),
                        _row(
                          'Desired Fastener Torque',
                          _formatTorqueSet(result.desiredTorqueInLb),
                        ),
                        _row(
                          'Effective Wrench Length',
                          '${_trim(result.effectiveLengthIn)} in',
                        ),
                        _row(
                          'Adjustment',
                          '${_trim(result.adjustmentPercent)}%',
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            _panel(
              context,
              title: 'Notes',
              child: Text(
                'Measure torque-wrench length from the center of the handle force point to the center of the square drive. Measure extension length from the square drive center to the fastener center.\n\n'
                'Manufacturer-specified torque always overrides general reference values. Fastener torque depends on grade, material, thread, lubrication, coating, and anchor type.',
                style: TextStyle(color: accent, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _angleChip(String label, double angle) {
    final accent = Theme.of(context).colorScheme.primary;
    return ChoiceChip(
      label: Text(label),
      selected: _read(_angleController) == angle,
      selectedColor: accent.withValues(alpha: 0.18),
      side: BorderSide(color: accent.withValues(alpha: 0.65)),
      labelStyle: TextStyle(color: accent),
      onSelected: (_) {
        _angleController.text = _trim(angle);
      },
    );
  }

  Widget _panel(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final accent = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        border: Border.all(color: accent, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatTorqueSet(double inLb) {
    return '${_trim(torqueFromInLb(inLb, TorqueUnit.inchPounds))} in-lb  |  '
        '${_trim(torqueFromInLb(inLb, TorqueUnit.footPounds))} ft-lb  |  '
        '${_trim(torqueFromInLb(inLb, TorqueUnit.newtonMeters))} N·m';
  }
}

String _trim(double value) {
  return value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
}

class _TorqueExtensionPainter extends CustomPainter {
  final Color accent;

  const _TorqueExtensionPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final thinPaint = Paint()
      ..color = accent.withValues(alpha: 0.55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final handle = Offset(size.width * 0.15, size.height * 0.62);
    final drive = Offset(size.width * 0.62, size.height * 0.62);
    final fastener = Offset(size.width * 0.84, size.height * 0.62);
    final perpendicular = Offset(size.width * 0.62, size.height * 0.32);

    canvas.drawLine(handle, drive, linePaint);
    canvas.drawLine(drive, fastener, linePaint);
    canvas.drawLine(drive, perpendicular, thinPaint);
    canvas.drawCircle(handle, 5, dotPaint);
    canvas.drawCircle(drive, 5, dotPaint);
    canvas.drawCircle(fastener, 6, dotPaint);

    _label(canvas, 'force point', Offset(handle.dx - 28, handle.dy + 14));
    _label(canvas, 'square drive', Offset(drive.dx - 32, drive.dy + 14));
    _label(canvas, 'fastener', Offset(fastener.dx - 20, fastener.dy + 14));
    _label(canvas, 'wrench length', Offset(size.width * 0.31, handle.dy - 24));
    _label(
      canvas,
      'extension length',
      Offset(size.width * 0.68, handle.dy - 24),
    );
    _label(canvas, 'angle', Offset(drive.dx + 8, drive.dy - 38));
  }

  void _label(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: accent.withValues(alpha: 0.8), fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _TorqueExtensionPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}
