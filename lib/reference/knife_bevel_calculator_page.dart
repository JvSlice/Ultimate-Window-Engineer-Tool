import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../terminal_scaffold.dart';
import 'knife_bevel_calculator.dart';

class KnifeBevelCalculatorPage extends StatefulWidget {
  const KnifeBevelCalculatorPage({super.key});

  @override
  State<KnifeBevelCalculatorPage> createState() =>
      _KnifeBevelCalculatorPageState();
}

class _KnifeBevelCalculatorPageState extends State<KnifeBevelCalculatorPage> {
  final _thickness = TextEditingController(text: '0.125');
  final _height = TextEditingController(text: '1.25');
  final _edge = TextEditingController(text: '0.010');
  final _bevelHeight = TextEditingController(text: '0.75');
  final _blockAngle = TextEditingController(text: '12');
  final _seatOffset = TextEditingController(text: '0');
  final _radius = TextEditingController(text: '8');
  KnifeUnitSystem _units = KnifeUnitSystem.imperial;
  KnifeBevelMode _mode = KnifeBevelMode.desiredBevel;
  KnifeGrindType _grind = KnifeGrindType.fullFlat;
  KnifeGrindingOrientation _orientation = KnifeGrindingOrientation.right;
  final KnifeGrindingBlockStore _store = KnifeGrindingBlockStore();
  List<SavedKnifeGrindingBlock> _blocks = [];

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  Future<void> _loadBlocks() async {
    final blocks = await _store.load();
    if (mounted) setState(() => _blocks = blocks);
  }

  List<TextEditingController> get _lengthControllers => [
    _thickness,
    _height,
    _edge,
    _bevelHeight,
    _radius,
  ];

  @override
  void dispose() {
    for (final controller in [
      ..._lengthControllers,
      _blockAngle,
      _seatOffset,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim());

  KnifeBevelResult? get _result {
    final dimensions = _lengthControllers.map(_number).toList();
    final angle = _number(_blockAngle);
    final offset = _number(_seatOffset);
    if (dimensions.any((value) => value == null) ||
        angle == null ||
        offset == null) {
      return null;
    }
    return calculateKnifeBevel(
      KnifeBevelInput(
        mode: _mode,
        grindType: _grind,
        orientation: _orientation,
        stockThickness: dimensions[0]!,
        bladeHeight: dimensions[1]!,
        edgeThickness: dimensions[2]!,
        desiredBevelHeight: dimensions[3]!,
        blockAngleDegrees: angle,
        seatOffsetDegrees: offset,
        curvatureRadius: _grind == KnifeGrindType.hollow
            ? dimensions[4]! / 2
            : dimensions[4]!,
      ),
    );
  }

  void _setUnits(KnifeUnitSystem next) {
    if (next == _units) return;
    for (final controller in _lengthControllers) {
      final value = _number(controller);
      if (value != null) {
        controller.text = _fmt(convertKnifeLength(value, _units, next), 5);
      }
    }
    setState(() => _units = next);
  }

  String _fmt(double value, [int digits = 3]) =>
      value.toStringAsFixed(digits).replaceFirst(RegExp(r'\.?0+$'), '');
  String _length(double value) => '${_fmt(value, 4)} ${_units.lengthUnit}';

  Future<void> _saveBlock({SavedKnifeGrindingBlock? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final angleController = TextEditingController(
      text: '${existing?.angleDegrees ?? _number(_blockAngle) ?? 12}',
    );
    final offsetController = TextEditingController(
      text: '${existing?.seatOffsetDegrees ?? _number(_seatOffset) ?? 0}',
    );
    var orientation = existing?.orientation ?? _orientation;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          backgroundColor: const Color(0xFF101810),
          title: Text(
            existing == null ? 'Save grinding block' : 'Edit grinding block',
            style: const TextStyle(color: Colors.greenAccent),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: angleController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Block angle from belt perpendicular (°)',
                ),
              ),
              TextField(
                controller: offsetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Seat/contact offset (°)',
                ),
              ),
              DropdownButton<KnifeGrindingOrientation>(
                value: orientation,
                items: KnifeGrindingOrientation.values
                    .map(
                      (o) => DropdownMenuItem(value: o, child: Text(o.label)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) dialogSetState(() => orientation = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    final name = nameController.text.trim();
    final angle = double.tryParse(angleController.text);
    final offset = double.tryParse(offsetController.text);
    nameController.dispose();
    angleController.dispose();
    offsetController.dispose();
    if (accepted != true || name.isEmpty || angle == null || offset == null) {
      return;
    }
    final block = SavedKnifeGrindingBlock(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      angleDegrees: angle,
      orientation: orientation,
      seatOffsetDegrees: offset,
    );
    final updated = [..._blocks.where((item) => item.id != block.id), block];
    await _store.save(updated);
    if (mounted) setState(() => _blocks = updated);
  }

  Future<void> _deleteBlock(SavedKnifeGrindingBlock block) async {
    final updated = _blocks.where((item) => item.id != block.id).toList();
    await _store.save(updated);
    if (mounted) setState(() => _blocks = updated);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final result = _result;
    final unit = _units.lengthUnit;
    return TerminalScaffold(
      title: 'Knife Bevel & Grinding Setup',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Calculate bevel geometry from dimensions or estimate the grind produced by a block setup.',
            style: TextStyle(color: accent),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final units in KnifeUnitSystem.values)
                ChoiceChip(
                  label: Text(
                    units == KnifeUnitSystem.imperial
                        ? 'Imperial (in)'
                        : 'Metric (mm)',
                  ),
                  selected: units == _units,
                  onSelected: (_) => _setUnits(units),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final mode in KnifeBevelMode.values)
                ChoiceChip(
                  label: Text(
                    mode == KnifeBevelMode.desiredBevel
                        ? 'Set bevel target'
                        : 'Check existing block',
                  ),
                  selected: mode == _mode,
                  onSelected: (_) => setState(() => _mode = mode),
                ),
            ],
          ),
          _drop<KnifeGrindType>(
            'Grind profile',
            _grind,
            KnifeGrindType.values,
            (v) => setState(() => _grind = v),
            (v) => v.label,
          ),
          _drop<KnifeGrindingOrientation>(
            'Grinding side',
            _orientation,
            KnifeGrindingOrientation.values,
            (v) => setState(() => _orientation = v),
            (v) => v.label,
          ),
          _field('Blade stock thickness ($unit)', _thickness, accent),
          _field('Blade height from edge to spine ($unit)', _height, accent),
          _field('Edge thickness ($unit)', _edge, accent),
          if (_mode == KnifeBevelMode.desiredBevel)
            _field('Target bevel height ($unit)', _bevelHeight, accent)
          else ...[
            _field(
              'Block angle from belt perpendicular (°)',
              _blockAngle,
              accent,
            ),
            _field(
              'Blade seat/contact offset from block (°)',
              _seatOffset,
              accent,
            ),
          ],
          if (_grind.isCurved)
            _field(
              _grind == KnifeGrindType.hollow
                  ? 'Wheel diameter ($unit)'
                  : 'Convex profile radius ($unit)',
              _radius,
              accent,
            ),
          Text(
            'A block angle alone does not determine bevel angle. Enter the measured blade-to-support contact offset; use 0° only when the blade sits flush to the block reference face.',
            style: TextStyle(color: accent.withValues(alpha: .8)),
          ),
          if (_mode == KnifeBevelMode.desiredBevel) ...[
            const SizedBox(height: 8),
            Text(
              'Quick height presets',
              style: TextStyle(color: Colors.greenAccent),
            ),
            Wrap(
              spacing: 6,
              children: [
                for (final type in [
                  KnifeGrindType.fullFlat,
                  KnifeGrindType.saber,
                  KnifeGrindType.scandi,
                ])
                  ActionChip(
                    label: Text(
                      '${type.label} (${(type == KnifeGrindType.fullFlat
                          ? 100
                          : type == KnifeGrindType.saber
                          ? 70
                          : 30)}%)',
                    ),
                    onPressed: () {
                      final h = _number(_height);
                      if (h != null) {
                        setState(
                          () => _bevelHeight.text = _fmt(
                            knifePresetHeight(type, h),
                            5,
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (result == null)
            _card(accent, const [
              'Enter valid positive dimensions; edge thickness must be below stock thickness.',
            ])
          else ...[
            _card(accent, [
              'Bevel angle (each side): ${_fmt(result.bevelAngleDegrees, 2)}°',
              'Included angle: ${_fmt(result.totalIncludedAngleDegrees, 2)}°',
              'Bevel height: ${_length(result.bevelHeight)}${result.isAchievable ? '' : ' — exceeds blade height'}',
              if (result.requiredBlockAngleDegrees != null)
                'Required block setting: ${_fmt(result.requiredBlockAngleDegrees!, 2)}° from belt perpendicular',
              'Geometry classification: ${result.geometryClassification.label} (tool coverage heuristic)',
              if (result.note != null) result.note!,
            ]),
            const SizedBox(height: 12),
            _Diagram(
              result: result,
              stockThickness: _number(_thickness) ?? 0,
              bladeHeight: _number(_height) ?? 0,
              accent: accent,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Saved grinding blocks',
                  style: TextStyle(color: accent, fontSize: 18),
                ),
              ),
              IconButton(
                onPressed: () => _saveBlock(),
                icon: Icon(Icons.add, color: accent),
              ),
            ],
          ),
          if (_blocks.isEmpty)
            Text(
              'Save block name, angle, orientation, and contact offset for comparison.',
              style: TextStyle(color: accent.withValues(alpha: .8)),
            ),
          for (final block in _blocks)
            Card(
              color: const Color(0xFF101810),
              child: ListTile(
                title: Text(block.name, style: TextStyle(color: accent)),
                subtitle: Text(
                  '${block.angleDegrees}° ${block.orientation.label}, seat offset ${block.seatOffsetDegrees}°',
                  style: TextStyle(color: accent.withValues(alpha: .8)),
                ),
                onTap: () => setState(() {
                  _blockAngle.text = '${block.angleDegrees}';
                  _seatOffset.text = '${block.seatOffsetDegrees}';
                  _orientation = block.orientation;
                  _mode = KnifeBevelMode.existingBlock;
                }),
                trailing: Wrap(
                  children: [
                    IconButton(
                      onPressed: () => _saveBlock(existing: block),
                      icon: Icon(Icons.edit, color: accent),
                    ),
                    IconButton(
                      onPressed: () => _deleteBlock(block),
                      icon: Icon(Icons.delete_outline, color: accent),
                    ),
                  ],
                ),
              ),
            ),
          if (_mode == KnifeBevelMode.existingBlock && _blocks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Block comparison (current blade dimensions and seat/contact settings)',
              style: TextStyle(color: accent, fontSize: 17),
            ),
            for (final angle in [10.0, 12.0, 15.0, 20.0])
              _compareAngle(angle, accent),
            for (final block in _blocks) _comparison(block, accent),
          ],
          const SizedBox(height: 16),
          Text(
            'Model notes: straight symmetric bevel uses α = atan((t − e)/(2b)); single-sided bevel uses α = atan((t − e)/b). The inverse solves b from α. Hollow geometry uses the entered wheel diameter; convex geometry uses the entered arc radius. Circle solutions that cannot meet the selected edge and face geometry are rejected. Coverage bands used for FFG/Saber/Scandi labels are guidance, not a universal grind standard.',
            style: TextStyle(color: accent, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _comparison(SavedKnifeGrindingBlock block, Color accent) {
    final t = _number(_thickness), h = _number(_height), e = _number(_edge);
    if (t == null || h == null || e == null) return const SizedBox.shrink();
    final r = calculateKnifeBevel(
      KnifeBevelInput(
        mode: KnifeBevelMode.existingBlock,
        grindType: KnifeGrindType.fullFlat,
        orientation: block.orientation,
        stockThickness: t,
        bladeHeight: h,
        edgeThickness: e,
        desiredBevelHeight: h,
        blockAngleDegrees: block.angleDegrees,
        seatOffsetDegrees: block.seatOffsetDegrees,
        curvatureRadius: 0,
      ),
    );
    if (r == null) return const SizedBox.shrink();
    return Text(
      '${block.name}: ${_fmt(r.bevelAngleDegrees, 2)}° / ${_length(r.bevelHeight)} bevel — ${r.geometryClassification.label}',
      style: TextStyle(color: accent),
    );
  }

  Widget _compareAngle(double angle, Color accent) {
    final t = _number(_thickness),
        h = _number(_height),
        e = _number(_edge),
        offset = _number(_seatOffset);
    if (t == null || h == null || e == null || offset == null) {
      return const SizedBox.shrink();
    }
    final r = calculateKnifeBevel(
      KnifeBevelInput(
        mode: KnifeBevelMode.existingBlock,
        grindType: KnifeGrindType.fullFlat,
        orientation: _orientation,
        stockThickness: t,
        bladeHeight: h,
        edgeThickness: e,
        desiredBevelHeight: h,
        blockAngleDegrees: angle,
        seatOffsetDegrees: offset,
        curvatureRadius: 0,
      ),
    );
    return Text(
      '$angle° block: ${r == null ? 'invalid geometry' : '${_fmt(r.bevelAngleDegrees, 2)}° bevel / ${_length(r.bevelHeight)} — ${r.geometryClassification.label}'}',
      style: TextStyle(color: accent),
    );
  }

  Widget _field(String label, TextEditingController controller, Color accent) =>
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          style: TextStyle(color: accent),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: accent.withValues(alpha: .85)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: accent.withValues(alpha: .4)),
            ),
          ),
        ),
      );

  Widget _drop<T>(
    String label,
    T value,
    List<T> values,
    ValueChanged<T> onChanged,
    String Function(T) labelOf,
  ) => DropdownButtonFormField<T>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: values
        .map((v) => DropdownMenuItem(value: v, child: Text(labelOf(v))))
        .toList(),
    onChanged: (v) {
      if (v != null) onChanged(v);
    },
  );

  Widget _card(Color accent, List<String> lines) => Card(
    color: const Color(0xFF101810),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines
            .map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(line, style: TextStyle(color: accent)),
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _Diagram extends StatelessWidget {
  const _Diagram({
    required this.result,
    required this.stockThickness,
    required this.bladeHeight,
    required this.accent,
  });
  final KnifeBevelResult result;
  final double stockThickness;
  final double bladeHeight;
  final Color accent;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : 600.0;
      return InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: SizedBox(
          width: width,
          height: 380,
          child: Column(
            children: [
              SizedBox(
                width: width,
                height: 260,
                child: CustomPaint(
                  painter: _BevelPainter(
                    result,
                    stockThickness,
                    bladeHeight,
                    accent,
                  ),
                ),
              ),
              SizedBox(
                width: width,
                height: 120,
                child: CustomPaint(painter: _SetupPainter(result, accent)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SetupPainter extends CustomPainter {
  const _SetupPainter(this.result, this.color);
  final KnifeBevelResult result;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final x = size.width * .70;
    final base = size.height - 18.0;
    final radians = result.actualBladeOrientationDegrees * math.pi / 180;
    final length = math.min(size.width * .45, 150.0);
    final end = Offset(
      x - math.sin(radians) * length,
      base - math.cos(radians) * length,
    );
    canvas.drawLine(Offset(x, 6), Offset(x, base), pen);
    canvas.drawLine(
      Offset(x - length * .55, base),
      Offset(x + length * .55, base),
      pen,
    );
    canvas.drawLine(Offset(x, base), end, pen);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(x, base), radius: 24),
      -math.pi / 2 - radians,
      radians,
      false,
      pen,
    );
    final angleLabel =
        '${result.actualBladeOrientationDegrees.abs().toStringAsFixed(1)}° blade to belt perpendicular';
    final tp = TextPainter(
      text: TextSpan(
        text: angleLabel,
        style: TextStyle(color: color, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * .62);
    tp.paint(canvas, Offset(8, 12));
    final belt = TextPainter(
      text: TextSpan(
        text: 'BELT',
        style: TextStyle(color: color, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    belt.paint(canvas, Offset(x + 5, 5));
  }

  @override
  bool shouldRepaint(covariant _SetupPainter old) =>
      old.result != result || old.color != color;
}

class _BevelPainter extends CustomPainter {
  _BevelPainter(this.result, this.thickness, this.height, this.color);
  final KnifeBevelResult result;
  final double thickness, height;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min((size.width - 56) / height, 125 / thickness);
    final origin = Offset(24, size.height / 2);
    Offset map(KnifePoint p) =>
        Offset(origin.dx + p.x * scale, origin.dy - p.y * scale);
    final pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fill = Paint()
      ..color = color.withValues(alpha: .08)
      ..style = PaintingStyle.fill;
    final outline = Path()
      ..moveTo(origin.dx, origin.dy - thickness * scale / 2)
      ..lineTo(origin.dx + height * scale, origin.dy - thickness * scale / 2)
      ..lineTo(origin.dx + height * scale, origin.dy + thickness * scale / 2)
      ..lineTo(origin.dx, origin.dy + thickness * scale / 2)
      ..close();
    canvas.drawPath(outline, fill);
    canvas.drawPath(outline, pen);
    for (final profile in [
      result.upperBevelProfile,
      result.lowerBevelProfile,
    ]) {
      if (profile.length < 2) continue;
      final path = Path()..moveTo(map(profile.first).dx, map(profile.first).dy);
      for (final point in profile.skip(1)) {
        final p = map(point);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, pen);
    }
    final top = Offset(origin.dx, origin.dy - thickness * scale / 2);
    final end = Offset(
      origin.dx + result.bevelHeight * scale,
      origin.dy - thickness * scale / 2,
    );
    canvas.drawLine(
      top + const Offset(0, -18),
      end + const Offset(0, -18),
      pen,
    );
    _label(
      canvas,
      result.bevelHeight.toStringAsFixed(3),
      Offset((top.dx + end.dx) / 2, top.dy - 30),
      color,
    );
    final ang = result.bevelAngleDegrees * math.pi / 180;
    final arcRect = Rect.fromCircle(center: top, radius: 24);
    canvas.drawArc(arcRect, 0, -ang, false, pen);
    _label(
      canvas,
      '${result.bevelAngleDegrees.toStringAsFixed(1)}°',
      top + const Offset(35, -24),
      color,
    );
    canvas.drawLine(
      Offset(
        origin.dx + height * scale + 12,
        origin.dy - thickness * scale / 2,
      ),
      Offset(
        origin.dx + height * scale + 12,
        origin.dy + thickness * scale / 2,
      ),
      pen,
    );
    _label(
      canvas,
      't=${thickness.toStringAsFixed(3)}',
      Offset(origin.dx + height * scale + 14, origin.dy - 5),
      color,
    );
  }

  void _label(Canvas canvas, String text, Offset at, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(covariant _BevelPainter old) =>
      old.result != result ||
      old.thickness != thickness ||
      old.height != height ||
      old.color != color;
}
