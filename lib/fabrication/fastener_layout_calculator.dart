import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../terminal_scaffold.dart';

enum FastenerDisplayMode { fraction, decimal }

class FastenerSideLayout {
  final String name;
  final String reference;
  final double sideLength;
  final double cornerOffset;
  final double minimumSpacing;
  final double availableDistance;
  final int spaces;
  final double spacing;
  final List<double> locations;
  final String? error;

  const FastenerSideLayout({
    required this.name,
    required this.reference,
    required this.sideLength,
    required this.cornerOffset,
    required this.minimumSpacing,
    required this.availableDistance,
    required this.spaces,
    required this.spacing,
    required this.locations,
    this.error,
  });

  bool get isValid => error == null;
  int get fastenerCount => locations.length;
}

class FastenerLayoutResult {
  final FastenerSideLayout top;
  final FastenerSideLayout bottom;
  final FastenerSideLayout left;
  final FastenerSideLayout right;

  const FastenerLayoutResult({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  List<FastenerSideLayout> get sides => [top, bottom, left, right];

  bool get isValid => sides.every((side) => side.isValid);

  int get totalFasteners =>
      sides.fold(0, (total, side) => total + side.fastenerCount);
}

FastenerSideLayout calculateFastenerSideLayout({
  required String name,
  required String reference,
  required double sideLength,
  required double cornerOffset,
  required double minimumSpacing,
}) {
  final availableDistance = sideLength - (2 * cornerOffset);

  String? error;
  if (sideLength <= 0) {
    error = 'Side length must be greater than zero.';
  } else if (cornerOffset < 0) {
    error = 'Corner offset must be greater than or equal to zero.';
  } else if (minimumSpacing <= 0) {
    error = 'Minimum spacing must be greater than zero.';
  } else if (availableDistance <= 0) {
    error = 'Two corner-offset fasteners do not fit on this side.';
  } else if (availableDistance < minimumSpacing) {
    error =
        'No valid layout is possible. Increase side length, reduce corner offset, or reduce minimum spacing.';
  }

  if (error != null) {
    return FastenerSideLayout(
      name: name,
      reference: reference,
      sideLength: sideLength,
      cornerOffset: cornerOffset,
      minimumSpacing: minimumSpacing,
      availableDistance: availableDistance,
      spaces: 0,
      spacing: 0,
      locations: const [],
      error: error,
    );
  }

  final spaces = math.max(1, (availableDistance / minimumSpacing).floor());
  final spacing = availableDistance / spaces;

  if (spacing + 0.0000001 < minimumSpacing) {
    return FastenerSideLayout(
      name: name,
      reference: reference,
      sideLength: sideLength,
      cornerOffset: cornerOffset,
      minimumSpacing: minimumSpacing,
      availableDistance: availableDistance,
      spaces: spaces,
      spacing: spacing,
      locations: const [],
      error: 'Calculated spacing is below the requested minimum.',
    );
  }

  return FastenerSideLayout(
    name: name,
    reference: reference,
    sideLength: sideLength,
    cornerOffset: cornerOffset,
    minimumSpacing: minimumSpacing,
    availableDistance: availableDistance,
    spaces: spaces,
    spacing: spacing,
    locations: List<double>.generate(
      spaces + 1,
      (index) => index == spaces
          ? sideLength - cornerOffset
          : cornerOffset + (spacing * index),
    ),
  );
}

FastenerLayoutResult calculateFastenerLayout({
  required double width,
  required double height,
  required double cornerOffset,
  required double minimumSpacing,
}) {
  return FastenerLayoutResult(
    top: calculateFastenerSideLayout(
      name: 'Top',
      reference: 'from left corner',
      sideLength: width,
      cornerOffset: cornerOffset,
      minimumSpacing: minimumSpacing,
    ),
    bottom: calculateFastenerSideLayout(
      name: 'Bottom',
      reference: 'from left corner',
      sideLength: width,
      cornerOffset: cornerOffset,
      minimumSpacing: minimumSpacing,
    ),
    left: calculateFastenerSideLayout(
      name: 'Left',
      reference: 'from bottom corner',
      sideLength: height,
      cornerOffset: cornerOffset,
      minimumSpacing: minimumSpacing,
    ),
    right: calculateFastenerSideLayout(
      name: 'Right',
      reference: 'from bottom corner',
      sideLength: height,
      cornerOffset: cornerOffset,
      minimumSpacing: minimumSpacing,
    ),
  );
}

String formatFastenerInches(
  double value,
  FastenerDisplayMode mode, {
  int denominator = 16,
}) {
  if (mode == FastenerDisplayMode.decimal) {
    return '${_trimFixed(value, 3)} in';
  }

  final rounded = (value * denominator).round();
  final whole = rounded ~/ denominator;
  var numerator = rounded % denominator;
  var displayDenominator = denominator;

  if (numerator == 0) return '$whole in';

  final divisor = _gcd(numerator, displayDenominator);
  numerator ~/= divisor;
  displayDenominator ~/= divisor;

  if (whole == 0) return '$numerator/$displayDenominator in';
  return '$whole $numerator/$displayDenominator in';
}

String _trimFixed(double value, int places) {
  return value.toStringAsFixed(places).replaceFirst(RegExp(r'\.?0+$'), '');
}

int _gcd(int a, int b) {
  while (b != 0) {
    final temp = b;
    b = a % b;
    a = temp;
  }
  return a.abs();
}

class FastenerLayoutCalculatorPage extends StatefulWidget {
  final double? initialWidth;
  final double? initialHeight;
  final String? sourceMessage;

  const FastenerLayoutCalculatorPage({
    super.key,
    this.initialWidth,
    this.initialHeight,
    this.sourceMessage,
  });

  @override
  State<FastenerLayoutCalculatorPage> createState() =>
      _FastenerLayoutCalculatorPageState();
}

class _FastenerLayoutCalculatorPageState
    extends State<FastenerLayoutCalculatorPage> {
  static const _cornerOffsetKey = 'fastener_layout_corner_offset';
  static const _minimumSpacingKey = 'fastener_layout_minimum_spacing';
  static const _displayModeKey = 'fastener_layout_display_mode';

  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _cornerOffsetController = TextEditingController(text: '3');
  final _minimumSpacingController = TextEditingController(text: '16');

  FastenerDisplayMode _displayMode = FastenerDisplayMode.fraction;

  @override
  void initState() {
    super.initState();
    _widthController.text = _formatControllerNumber(widget.initialWidth);
    _heightController.text = _formatControllerNumber(widget.initialHeight);
    _loadPreferences();

    _widthController.addListener(_refresh);
    _heightController.addListener(_refresh);
    _cornerOffsetController.addListener(_savePreferencesAndRefresh);
    _minimumSpacingController.addListener(_savePreferencesAndRefresh);
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _cornerOffsetController.dispose();
    _minimumSpacingController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final cornerOffset = prefs.getDouble(_cornerOffsetKey);
    final minimumSpacing = prefs.getDouble(_minimumSpacingKey);
    final displayMode = prefs.getString(_displayModeKey);

    setState(() {
      if (cornerOffset != null) {
        _cornerOffsetController.text = _formatControllerNumber(cornerOffset);
      }
      if (minimumSpacing != null) {
        _minimumSpacingController.text = _formatControllerNumber(
          minimumSpacing,
        );
      }
      if (displayMode == FastenerDisplayMode.decimal.name) {
        _displayMode = FastenerDisplayMode.decimal;
      }
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final cornerOffset = _read(_cornerOffsetController);
    final minimumSpacing = _read(_minimumSpacingController);

    if (cornerOffset != null) {
      await prefs.setDouble(_cornerOffsetKey, cornerOffset);
    }
    if (minimumSpacing != null) {
      await prefs.setDouble(_minimumSpacingKey, minimumSpacing);
    }
    await prefs.setString(_displayModeKey, _displayMode.name);
  }

  void _refresh() {
    setState(() {});
  }

  void _savePreferencesAndRefresh() {
    _savePreferences();
    _refresh();
  }

  void _reset() {
    _widthController.clear();
    _heightController.clear();
    _cornerOffsetController.text = '3';
    _minimumSpacingController.text = '16';
    setState(() {
      _displayMode = FastenerDisplayMode.fraction;
    });
    _savePreferences();
  }

  double? _read(TextEditingController controller) {
    return double.tryParse(controller.text.trim());
  }

  String _formatControllerNumber(double? value) {
    if (value == null || value <= 0) return '';
    return _trimFixed(value, 3);
  }

  FastenerLayoutResult? get _result {
    final width = _read(_widthController);
    final height = _read(_heightController);
    final cornerOffset = _read(_cornerOffsetController);
    final minimumSpacing = _read(_minimumSpacingController);

    if (width == null ||
        height == null ||
        cornerOffset == null ||
        minimumSpacing == null) {
      return null;
    }

    return calculateFastenerLayout(
      width: width,
      height: height,
      cornerOffset: cornerOffset,
      minimumSpacing: minimumSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final result = _result;

    return TerminalScaffold(
      title: 'Fastener Layout Calculator',
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
                  if (widget.sourceMessage != null) ...[
                    Text(
                      widget.sourceMessage!,
                      style: TextStyle(color: accent.withValues(alpha: 0.78)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _numberField('Window Width (in)', _widthController),
                  const SizedBox(height: 12),
                  _numberField('Window Height (in)', _heightController),
                  const SizedBox(height: 12),
                  _numberField(
                    'Corner Fastener Offset (in)',
                    _cornerOffsetController,
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    'Minimum On-Center Spacing (in)',
                    _minimumSpacingController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _modeButton('Fractions', FastenerDisplayMode.fraction),
                      const SizedBox(width: 12),
                      _modeButton(
                        'Decimal Inches',
                        FastenerDisplayMode.decimal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
            if (result == null)
              _panel(
                context,
                title: 'Results',
                child: const Text(
                  'Enter window width, height, corner offset, and minimum spacing.',
                ),
              )
            else ...[
              _panel(
                context,
                title: 'Visual Layout',
                child: SizedBox(
                  height: 280,
                  child: CustomPaint(
                    painter: _FastenerLayoutPainter(
                      result: result,
                      accent: accent,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _panel(
                context,
                title: 'Total Perimeter Fasteners',
                child: Text(
                  result.isValid
                      ? '${result.totalFasteners} fasteners'
                      : 'Resolve invalid side layouts before counting fasteners.',
                  style: TextStyle(
                    color: accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _sidePanel(context, result.top, pairedName: 'Top and Bottom'),
              const SizedBox(height: 16),
              _sidePanel(context, result.left, pairedName: 'Left and Right'),
            ],
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

  Widget _modeButton(String label, FastenerDisplayMode mode) {
    final accent = Theme.of(context).colorScheme.primary;
    final selected = _displayMode == mode;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _displayMode = mode;
          });
          _savePreferences();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 2),
          backgroundColor: selected
              ? accent.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
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

  Widget _sidePanel(
    BuildContext context,
    FastenerSideLayout side, {
    required String pairedName,
  }) {
    final accent = Theme.of(context).colorScheme.primary;

    return _panel(
      context,
      title: pairedName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _resultRow(
            'Side Length',
            formatFastenerInches(side.sideLength, _displayMode),
          ),
          _resultRow(
            'Corner Offset',
            formatFastenerInches(side.cornerOffset, _displayMode),
          ),
          _resultRow(
            'Minimum Spacing',
            '${formatFastenerInches(side.minimumSpacing, _displayMode)} o.c.',
          ),
          if (!side.isValid) ...[
            const SizedBox(height: 10),
            Text(
              side.error!,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                height: 1.35,
              ),
            ),
          ] else ...[
            _resultRow(
              'Ideal Equal Spacing',
              '${formatFastenerInches(side.spacing, _displayMode)} o.c.',
            ),
            _resultRow('Number of Spaces', '${side.spaces}'),
            _resultRow('Fasteners per Side', '${side.fastenerCount}'),
            const SizedBox(height: 10),
            Text(
              'Fastener locations ${side.reference}:',
              style: TextStyle(color: accent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: side.locations.map((location) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: accent.withValues(alpha: 0.7)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text(
                      formatFastenerInches(location, _displayMode),
                      style: TextStyle(color: accent),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _FastenerLayoutPainter extends CustomPainter {
  final FastenerLayoutResult result;
  final Color accent;

  const _FastenerLayoutPainter({required this.result, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final framePaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fastenerPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;
    final arrowPaint = Paint()
      ..color = accent.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final invalidPaint = Paint()
      ..color = accent.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final drawingWidth = math.max(120.0, size.width - 96);
    final drawingHeight = math.max(120.0, size.height - 92);
    final windowRatio = result.top.sideLength > 0 && result.left.sideLength > 0
        ? result.top.sideLength / result.left.sideLength
        : 1.0;
    final availableRatio = drawingWidth / drawingHeight;

    late final double frameWidth;
    late final double frameHeight;
    if (windowRatio >= availableRatio) {
      frameWidth = drawingWidth;
      frameHeight = drawingWidth / windowRatio;
    } else {
      frameHeight = drawingHeight;
      frameWidth = drawingHeight * windowRatio;
    }

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 + 6),
      width: frameWidth.clamp(120.0, drawingWidth),
      height: frameHeight.clamp(120.0, drawingHeight),
    );

    canvas.drawRect(rect, result.isValid ? framePaint : invalidPaint);

    if (result.isValid) {
      _drawHorizontal(canvas, rect, result.top, true, fastenerPaint);
      _drawHorizontal(canvas, rect, result.bottom, false, fastenerPaint);
      _drawVertical(canvas, rect, result.left, true, fastenerPaint);
      _drawVertical(canvas, rect, result.right, false, fastenerPaint);

      _drawArrow(
        canvas,
        Offset(rect.left, rect.top - 14),
        Offset(rect.right, rect.top - 14),
        arrowPaint,
      );
      _drawArrow(
        canvas,
        Offset(rect.left, rect.bottom + 14),
        Offset(rect.right, rect.bottom + 14),
        arrowPaint,
      );
      _drawArrow(
        canvas,
        Offset(rect.left - 14, rect.bottom),
        Offset(rect.left - 14, rect.top),
        arrowPaint,
      );
      _drawArrow(
        canvas,
        Offset(rect.right + 14, rect.bottom),
        Offset(rect.right + 14, rect.top),
        arrowPaint,
      );
    }

    _drawLabel(canvas, 'Top: left → right', Offset(rect.left, rect.top - 32));
    _drawLabel(
      canvas,
      'Bottom: left → right',
      Offset(rect.left, rect.bottom + 22),
    );
    _drawLabel(canvas, 'Left: bottom → top', Offset(4, rect.center.dy - 8));
    _drawLabel(
      canvas,
      'Right: bottom → top',
      Offset(rect.right + 20, rect.center.dy - 8),
    );
  }

  void _drawHorizontal(
    Canvas canvas,
    Rect rect,
    FastenerSideLayout side,
    bool top,
    Paint paint,
  ) {
    for (final location in side.locations) {
      final ratio = side.sideLength == 0 ? 0.0 : location / side.sideLength;
      final point = Offset(
        rect.left + (rect.width * ratio.clamp(0.0, 1.0)),
        top ? rect.top : rect.bottom,
      );
      canvas.drawCircle(point, 4, paint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);

    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    const arrowLength = 7.0;
    final first = Offset(
      end.dx - arrowLength * math.cos(angle - math.pi / 6),
      end.dy - arrowLength * math.sin(angle - math.pi / 6),
    );
    final second = Offset(
      end.dx - arrowLength * math.cos(angle + math.pi / 6),
      end.dy - arrowLength * math.sin(angle + math.pi / 6),
    );
    canvas
      ..drawLine(end, first, paint)
      ..drawLine(end, second, paint);
  }

  void _drawVertical(
    Canvas canvas,
    Rect rect,
    FastenerSideLayout side,
    bool left,
    Paint paint,
  ) {
    for (final location in side.locations) {
      final ratio = side.sideLength == 0 ? 0.0 : location / side.sideLength;
      final point = Offset(
        left ? rect.left : rect.right,
        rect.bottom - (rect.height * ratio.clamp(0.0, 1.0)),
      );
      canvas.drawCircle(point, 4, paint);
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: accent.withValues(alpha: 0.78), fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _FastenerLayoutPainter oldDelegate) {
    return oldDelegate.result != result || oldDelegate.accent != accent;
  }
}
