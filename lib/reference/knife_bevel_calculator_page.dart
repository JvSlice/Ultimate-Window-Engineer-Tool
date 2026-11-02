import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_theme.dart';
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
  final _measuredAngle = TextEditingController();
  final _comparisonAngles = TextEditingController(text: '6, 10, 12, 15');
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
      _measuredAngle,
      _comparisonAngles,
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
    if (dimensions.any((value) => value == null) || angle == null) {
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
        measuredGrindingAngleDegrees: _number(_measuredAngle),
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
    final measuredController = TextEditingController(
      text: existing?.measuredAngleDegrees?.toString() ?? '',
    );
    var orientation = existing?.orientation ?? _orientation;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          title: Text(
            existing == null ? 'Save grinding block' : 'Edit grinding block',
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
                controller: measuredController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Measured grind angle override (optional, °)',
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
    final measuredText = measuredController.text.trim();
    final measured = measuredText.isEmpty
        ? null
        : double.tryParse(measuredText);
    nameController.dispose();
    angleController.dispose();
    measuredController.dispose();
    if (accepted != true ||
        name.isEmpty ||
        angle == null ||
        angle <= 0 ||
        angle >= 90 ||
        (measuredText.isNotEmpty &&
            (measured == null || measured <= 0 || measured >= 90))) {
      return;
    }
    final block = SavedKnifeGrindingBlock(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      angleDegrees: angle,
      orientation: orientation,
      measuredAngleDegrees: measured,
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
    final secondary = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: .75);
    final surface = terminalSurfaceForAccent(accent);
    final result = _result;
    final unit = _units.lengthUnit;
    return TerminalScaffold(
      title: 'Knife Bevel & Grinding Setup',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fieldWidth = (constraints.maxWidth - 36)
              .clamp(140.0, 320.0)
              .toDouble();
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                'Knife bevel geometry and fixed-angle grinding setup.',
                style: TextStyle(color: secondary),
              ),
              const SizedBox(height: 8),
              _panel(
                surface,
                accent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
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
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final mode in KnifeBevelMode.values)
                          ChoiceChip(
                            label: Text(switch (mode) {
                              KnifeBevelMode.desiredBevel => 'Set target',
                              KnifeBevelMode.existingBlock => 'Check block',
                              KnifeBevelMode.compareBlocks => 'Compare blocks',
                            }),
                            selected: mode == _mode,
                            onSelected: (_) => setState(() => _mode = mode),
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 2,
                      children: [
                        SizedBox(
                          width: fieldWidth,
                          child: _drop<KnifeGrindType>(
                            'Grind profile',
                            _grind,
                            KnifeGrindType.values,
                            (v) => setState(() => _grind = v),
                            (v) => v.label,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _drop<KnifeGrindingOrientation>(
                            'Grinding side',
                            _orientation,
                            KnifeGrindingOrientation.values,
                            (v) => setState(() => _orientation = v),
                            (v) => v.label,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _field(
                            'Stock thickness ($unit)',
                            _thickness,
                            accent,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _field(
                            'Blade height ($unit)',
                            _height,
                            accent,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _field(
                            'Edge thickness ($unit)',
                            _edge,
                            accent,
                          ),
                        ),
                        if (_mode == KnifeBevelMode.desiredBevel)
                          SizedBox(
                            width: fieldWidth,
                            child: _field(
                              'Target bevel height ($unit)',
                              _bevelHeight,
                              accent,
                            ),
                          ),
                        if (_mode == KnifeBevelMode.existingBlock) ...[
                          SizedBox(
                            width: fieldWidth,
                            child: _field(
                              'Nominal block angle (°)',
                              _blockAngle,
                              accent,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _field(
                              'Measured grinding angle override (optional, °)',
                              _measuredAngle,
                              accent,
                            ),
                          ),
                        ],
                        if (_mode == KnifeBevelMode.compareBlocks)
                          SizedBox(
                            width: constraints.maxWidth - 20,
                            child: _field(
                              'Block angles to compare (comma-separated, degrees)',
                              _comparisonAngles,
                              accent,
                            ),
                          ),
                        if (_grind.isCurved)
                          SizedBox(
                            width: fieldWidth,
                            child: _field(
                              _grind == KnifeGrindType.hollow
                                  ? 'Wheel diameter ($unit)'
                                  : 'Convex profile radius ($unit)',
                              _radius,
                              accent,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'For the verified flat-platen setup, the blade follows the block angle. A measured angle overrides the nominal block angle when provided.',
                      style: TextStyle(color: secondary, fontSize: 12),
                    ),
                    if (_mode == KnifeBevelMode.desiredBevel) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Optional starting presets (editable)',
                        style: TextStyle(color: accent, fontSize: 12),
                      ),
                      Wrap(
                        spacing: 4,
                        children: [
                          for (final type in [
                            KnifeGrindType.fullFlat,
                            KnifeGrindType.saber,
                            KnifeGrindType.scandi,
                          ])
                            ActionChip(
                              label: Text(
                                '${type.label} ${type == KnifeGrindType.fullFlat
                                    ? '100'
                                    : type == KnifeGrindType.saber
                                    ? '70'
                                    : '30'}%',
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
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_mode != KnifeBevelMode.compareBlocks) ...[
                if (result == null)
                  _panel(
                    surface,
                    accent,
                    child: Text(
                      'Enter valid dimensions and an angle below 90°. Edge thickness must be below stock thickness.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  )
                else ...[
                  _resultsPanel(context, result, accent, surface),
                  const SizedBox(height: 8),
                  _panel(
                    surface,
                    accent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blade cross-section',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 250,
                          child: _BladeDiagram(
                            result: result,
                            thickness: _number(_thickness) ?? 0,
                            bladeHeight: _number(_height) ?? 0,
                            edgeThickness: _number(_edge) ?? 0,
                            unit: unit,
                            accent: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _panel(
                    surface,
                    accent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fixed-angle grinding setup',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 230,
                          child: _GrindingSetupDiagram(
                            result: result,
                            accent: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              if (_mode == KnifeBevelMode.compareBlocks ||
                  _mode == KnifeBevelMode.existingBlock) ...[
                const SizedBox(height: 8),
                _panel(
                  surface,
                  accent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grinding block comparison',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Same blade dimensions and grind profile; nominal angle is used unless a saved block has a measured override.',
                        style: TextStyle(color: secondary, fontSize: 12),
                      ),
                      for (final angle in _comparisonValues)
                        _comparisonRow('$angle° block', angle, null, accent),
                      for (final block in _blocks)
                        _comparisonRow(
                          block.name,
                          block.angleDegrees,
                          block.measuredAngleDegrees,
                          accent,
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              _panel(
                surface,
                accent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Saved grinding blocks',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _saveBlock(),
                          icon: Icon(Icons.add, color: accent),
                        ),
                      ],
                    ),
                    if (_blocks.isEmpty)
                      Text(
                        'Save a nominal angle and optional measured angle for reuse.',
                        style: TextStyle(color: secondary, fontSize: 12),
                      ),
                    for (final block in _blocks)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          block.name,
                          style: TextStyle(color: accent),
                        ),
                        subtitle: Text(
                          '${_fmt(block.angleDegrees, 2)}° nominal${block.measuredAngleDegrees == null ? '' : ' · ${_fmt(block.measuredAngleDegrees!, 2)}° measured'} · ${block.orientation.label}',
                          style: TextStyle(color: secondary, fontSize: 12),
                        ),
                        onTap: () => setState(() {
                          _blockAngle.text = '${block.angleDegrees}';
                          _measuredAngle.text =
                              block.measuredAngleDegrees?.toString() ?? '';
                          _orientation = block.orientation;
                          _mode = KnifeBevelMode.existingBlock;
                        }),
                        trailing: Wrap(
                          spacing: 0,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Edit',
                              onPressed: () => _saveBlock(existing: block),
                              icon: Icon(Icons.edit, size: 19, color: accent),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Delete',
                              onPressed: () => _deleteBlock(block),
                              icon: Icon(
                                Icons.delete_outline,
                                size: 19,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _panel(
                surface,
                accent,
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: Text(
                      'How it works',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Text(
                        'In the confirmed fixed-angle setup, the block establishes blade orientation relative to the flat belt/platen. The nominal block angle is used directly; an optional measured angle is a calibration override. For a straight symmetrical bevel, α = atan((t − e)/(2b)) and b = (t − e)/(2 tan α); included angle = 2α. A single-sided grind uses the full thickness reduction. Coverage is bevel height ÷ blade height; a low percentage alone does not identify a Scandi grind. Hollow profiles use wheel radius, and convex profiles use the entered arc radius; their tangent angle changes along the curve, so a single flat-grind angle does not describe the entire face.',
                        style: TextStyle(
                          color: secondary,
                          height: 1.35,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _resultsPanel(
    BuildContext context,
    KnifeBevelResult result,
    Color accent,
    Color surface,
  ) {
    final title = _mode == KnifeBevelMode.desiredBevel
        ? 'Target results'
        : 'Block results';
    final mainLines = <String>[
      'Bevel angle per side: ${_fmt(result.bevelAngleDegrees, 2)}°',
      if (result.requiredBlockAngleDegrees != null)
        'Required nominal block angle: ${_fmt(result.requiredBlockAngleDegrees!, 2)}°',
      if (_mode == KnifeBevelMode.existingBlock)
        'Nominal block angle: ${_fmt(result.nominalBlockAngleDegrees, 2)}°',
      if (_mode == KnifeBevelMode.existingBlock)
        'Angle used: ${_fmt(result.actualGrindingAngleDegrees, 2)}°${result.measuredGrindingAngleDegrees == null ? ' (nominal)' : ' (measured override)'}',
      'Bevel height: ${_length(result.bevelHeight)}',
    ];
    return _panel(
      surface,
      accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: accent, fontWeight: FontWeight.bold),
          ),
          for (final line in mainLines)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                line,
                style: TextStyle(
                  color: accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Divider(height: 12),
          if (_grind.groundSides == 2)
            Text(
              'Included angle: ${_fmt(result.totalIncludedAngleDegrees, 2)}°    Coverage: ${_fmt(result.bevelCoveragePercent, 1)}%',
              style: TextStyle(color: accent, fontSize: 12),
            ),
          if (_grind.groundSides == 1)
            Text(
              'Single-sided face angle: ${_fmt(result.bevelAngleDegrees, 2)}°    Coverage: ${_fmt(result.bevelCoveragePercent, 1)}%',
              style: TextStyle(color: accent, fontSize: 12),
            ),
          Text(
            'Remaining flat height: ${_length(result.remainingFlatHeight)}',
            style: TextStyle(color: accent, fontSize: 12),
          ),
          Text(
            'Selected profile: ${_grind.label} · ${knifeCoverageGuidance(result.bevelCoveragePercent)}',
            style: TextStyle(color: accent, fontSize: 12),
          ),
          if (result.edgeTangentAngleDegrees != null)
            Text(
              'Curved profile tangent: edge ${_fmt(result.edgeTangentAngleDegrees!.abs(), 2)}° · shoulder ${_fmt(result.shoulderTangentAngleDegrees!.abs(), 2)}°',
              style: TextStyle(color: accent, fontSize: 12),
            ),
          if (!result.isAchievable || result.note != null)
            Text(
              result.note ?? 'Bevel height exceeds the available blade height.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _comparisonRow(
    String name,
    double angle,
    double? measured,
    Color accent,
  ) {
    final t = _number(_thickness), h = _number(_height), e = _number(_edge);
    if (t == null || h == null || e == null) return const SizedBox.shrink();
    final result = calculateKnifeBevel(
      KnifeBevelInput(
        mode: KnifeBevelMode.existingBlock,
        grindType: _grind,
        orientation: _orientation,
        stockThickness: t,
        bladeHeight: h,
        edgeThickness: e,
        desiredBevelHeight: _number(_bevelHeight) ?? h,
        blockAngleDegrees: angle,
        measuredGrindingAngleDegrees: measured,
        curvatureRadius: _grind == KnifeGrindType.hollow
            ? (_number(_radius) ?? 0) / 2
            : (_number(_radius) ?? 0),
      ),
    );
    if (result == null) {
      return Text(
        '$name: invalid geometry',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$name${measured == null ? '' : ' (${_fmt(measured, 2)}° measured)'}: ${_fmt(result.bevelHeight, 4)} ${_units.lengthUnit} · ${_fmt(result.bevelCoveragePercent, 1)}% · ${result.isAchievable ? 'fits' : 'exceeds blade height'}',
        style: TextStyle(color: accent, fontSize: 12),
      ),
    );
  }

  List<double> get _comparisonValues => _comparisonAngles.text
      .split(RegExp(r'[,;\s]+'))
      .map(double.tryParse)
      .whereType<double>()
      .where((angle) => angle > 0 && angle < 90)
      .toSet()
      .toList(growable: false);

  Widget _panel(Color surface, Color accent, {required Widget child}) => Card(
    color: surface,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: accent.withValues(alpha: .35)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: child,
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller,
    Color accent,
  ) => Padding(
    padding: const EdgeInsets.only(top: 3, bottom: 3),
    child: TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .8),
        ),
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
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: values
        .map((v) => DropdownMenuItem(value: v, child: Text(labelOf(v))))
        .toList(),
    onChanged: (v) {
      if (v != null) onChanged(v);
    },
  );
}

String _precision(double value) {
  final formatted = value.toStringAsPrecision(5);
  if (formatted.contains('e')) return formatted;
  return formatted
      .replaceFirst(RegExp(r'(\.\d*?[1-9])0+$'), r'$1')
      .replaceFirst(RegExp(r'\.0+$'), '');
}

String _dimensionPrecision(double value) {
  if (value == 0) return '0.000';
  final rounded = value.toStringAsFixed(3);
  if (double.tryParse(rounded) == 0) return _precision(value);
  return rounded;
}

class _BladeDiagram extends StatelessWidget {
  const _BladeDiagram({
    required this.result,
    required this.thickness,
    required this.bladeHeight,
    required this.edgeThickness,
    required this.unit,
    required this.accent,
  });
  final KnifeBevelResult result;
  final double thickness, bladeHeight, edgeThickness;
  final String unit;
  final Color accent;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : 480.0;
      return InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: CustomPaint(
          size: Size(width, 250),
          painter: _BladePainter(
            result,
            thickness,
            bladeHeight,
            edgeThickness,
            unit,
            accent,
          ),
        ),
      );
    },
  );
}

class _GrindingSetupDiagram extends StatelessWidget {
  const _GrindingSetupDiagram({required this.result, required this.accent});
  final KnifeBevelResult result;
  final Color accent;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : 480.0;
      return InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: CustomPaint(
          size: Size(width, 230),
          painter: _GrindingSetupPainter(result, accent),
        ),
      );
    },
  );
}

class _BladePainter extends CustomPainter {
  const _BladePainter(
    this.result,
    this.thickness,
    this.height,
    this.edge,
    this.unit,
    this.color,
  );
  final KnifeBevelResult result;
  final double thickness, height, edge;
  final String unit;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (thickness <= 0 || height <= 0) return;
    final scale = math.min(
      (size.width - 112) / height,
      (size.height - 76) / thickness,
    );
    if (!scale.isFinite || scale <= 0) return;
    final x0 = 58.0;
    final cy = size.height * .43;
    Offset map(KnifePoint p) => Offset(x0 + p.x * scale, cy - p.y * scale);
    final pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7;
    final fill = Paint()
      ..color = color.withValues(alpha: .10)
      ..style = PaintingStyle.fill;
    final upper = [...result.upperBevelProfile];
    if (upper.isNotEmpty && upper.last.x < height) {
      upper.add(KnifePoint(height, thickness / 2));
    }
    final lower = result.geometryClassification == KnifeGrindType.chisel
        ? result.lowerBevelProfile.reversed.toList()
        : result.lowerBevelProfile;
    final path = Path();
    if (upper.isNotEmpty && lower.isNotEmpty) {
      path.moveTo(map(upper.first).dx, map(upper.first).dy);
      for (final point in upper.skip(1)) {
        final p = map(point);
        path.lineTo(p.dx, p.dy);
      }
      if (lower.first.x < height) {
        final spineBottom = map(KnifePoint(height, -thickness / 2));
        path.lineTo(spineBottom.dx, spineBottom.dy);
      }
      for (final point in lower) {
        final p = map(point);
        path.lineTo(p.dx, p.dy);
      }
      path.close();
    }
    canvas.drawPath(path, fill);
    canvas.drawPath(path, pen);
    final centerPaint = Paint()
      ..color = color.withValues(alpha: .65)
      ..strokeWidth = 1;
    for (var x = x0; x < x0 + height * scale; x += 9) {
      canvas.drawLine(
        Offset(x, cy),
        Offset(math.min(x + 5, x0 + height * scale), cy),
        centerPaint,
      );
    }
    final edgeTop = map(KnifePoint(0, edge / 2));
    final shoulderTop = map(KnifePoint(result.bevelHeight, thickness / 2));
    final shoulderBottomY = map(KnifePoint(0, -thickness / 2)).dy;
    final dimensionY = math.min(size.height - 24, shoulderBottomY + 34);
    final extensionPaint = Paint()
      ..color = color.withValues(alpha: .45)
      ..strokeWidth = 1;
    canvas.drawLine(
      map(KnifePoint(0, -thickness / 2)),
      Offset(x0, dimensionY + 3),
      extensionPaint,
    );
    canvas.drawLine(
      map(KnifePoint(result.bevelHeight, -thickness / 2)),
      Offset(x0 + result.bevelHeight * scale, dimensionY + 3),
      extensionPaint,
    );
    _dimension(
      canvas,
      Offset(x0, dimensionY),
      Offset(x0 + result.bevelHeight * scale, dimensionY),
      '${_dimensionPrecision(result.bevelHeight)} $unit bevel',
      color,
    );
    final fullY = math.min(size.height - 7, dimensionY + 20);
    canvas.drawLine(
      map(KnifePoint(0, -thickness / 2)),
      Offset(x0, fullY + 2),
      extensionPaint,
    );
    canvas.drawLine(
      map(KnifePoint(height, -thickness / 2)),
      Offset(x0 + height * scale, fullY + 2),
      extensionPaint,
    );
    _dimension(
      canvas,
      Offset(x0, fullY),
      Offset(x0 + height * scale, fullY),
      '${_dimensionPrecision(height)} $unit blade height',
      color,
    );
    final thicknessX = math.min(size.width - 54, x0 + height * scale + 12);
    _dimension(
      canvas,
      Offset(thicknessX, map(KnifePoint(height, thickness / 2)).dy),
      Offset(thicknessX, map(KnifePoint(height, -thickness / 2)).dy),
      't ${_dimensionPrecision(thickness)} $unit',
      color,
    );
    final edgeX = x0 - 20;
    canvas.drawLine(edgeTop, Offset(edgeX - 2, edgeTop.dy), extensionPaint);
    canvas.drawLine(
      map(KnifePoint(0, -edge / 2)),
      Offset(edgeX - 2, map(KnifePoint(0, -edge / 2)).dy),
      extensionPaint,
    );
    _dimension(
      canvas,
      Offset(edgeX, edgeTop.dy),
      Offset(edgeX, map(KnifePoint(0, -edge / 2)).dy),
      'e ${_dimensionPrecision(edge)} $unit',
      color,
    );
    final shoulderAngleDegrees =
        result.shoulderTangentAngleDegrees?.abs() ?? result.bevelAngleDegrees;
    final angle = shoulderAngleDegrees * math.pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: shoulderTop, radius: 20),
      math.pi,
      -angle,
      false,
      pen,
    );
    _label(
      canvas,
      '${shoulderAngleDegrees.toStringAsFixed(2)}° / side',
      Offset(shoulderTop.dx + 6, shoulderTop.dy - 29),
      color,
    );
    if (result.totalIncludedAngleDegrees != result.bevelAngleDegrees) {
      _label(
        canvas,
        'Included ${result.totalIncludedAngleDegrees.toStringAsFixed(2)}°',
        Offset(x0 + 4, 8),
        color,
      );
    }
    _label(
      canvas,
      'Blade centerline',
      Offset(x0 + height * scale * .55, cy + 4),
      color,
    );
    _label(
      canvas,
      'Bevel shoulder',
      Offset(shoulderTop.dx + 4, shoulderTop.dy - 19),
      color,
    );
  }

  @override
  bool shouldRepaint(covariant _BladePainter old) =>
      old.result != result ||
      old.thickness != thickness ||
      old.height != height ||
      old.edge != edge ||
      old.unit != unit ||
      old.color != color;
}

class _GrindingSetupPainter extends CustomPainter {
  const _GrindingSetupPainter(this.result, this.color);
  final KnifeBevelResult result;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final angle = result.actualGrindingAngleDegrees * math.pi / 180;
    final restY = size.height * .76;
    final beltX = size.width * .17;
    final blockStart = size.width * .24;
    final blockEnd = size.width * .67;
    final bladeEdge = Offset(
      beltX,
      restY + math.tan(angle) * (blockStart - beltX),
    );
    final bladeLength = size.width * .63;
    final bladeSpine = Offset(
      bladeEdge.dx + math.cos(angle) * bladeLength,
      bladeEdge.dy - math.sin(angle) * bladeLength,
    );
    final normal = Offset(math.sin(angle) * 8, math.cos(angle) * 8);
    final pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final thin = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final fill = Paint()
      ..color = color.withValues(alpha: .11)
      ..style = PaintingStyle.fill;
    // Vertical moving belt and flat platen.
    canvas.drawLine(Offset(beltX, 14), Offset(beltX, size.height - 8), pen);
    canvas.drawLine(
      Offset(beltX - 5, 14),
      Offset(beltX - 5, size.height - 8),
      thin,
    );
    _label(canvas, 'BELT / FLAT PLATEN', Offset(4, 2), color);
    // Horizontal tool rest.
    final restEnd = size.width - 12;
    canvas.drawLine(Offset(beltX - 14, restY), Offset(restEnd, restY), pen);
    canvas.drawLine(
      Offset(beltX + 6, restY + 5),
      Offset(restEnd, restY + 5),
      thin,
    );
    _label(
      canvas,
      'HORIZONTAL TOOL REST',
      Offset(size.width * .53, restY + 9),
      color,
    );
    // Fixed-angle block: its support face is exactly parallel to the blade.
    final blockTopStart = Offset(blockStart, restY);
    final blockTopEnd = Offset(
      blockEnd,
      restY - math.tan(angle) * (blockEnd - blockStart),
    );
    final block = Path()
      ..moveTo(blockTopStart.dx, blockTopStart.dy)
      ..lineTo(blockTopEnd.dx, blockTopEnd.dy)
      ..lineTo(blockEnd, restY)
      ..lineTo(blockStart, restY)
      ..close();
    canvas.drawPath(block, fill);
    canvas.drawPath(block, pen);
    _label(
      canvas,
      'FIXED-ANGLE BLOCK',
      Offset(blockStart + 7, restY - 23),
      color,
    );
    // Blade plate, edge touching the belt, supported by the block without pivoting.
    final blade = Path()
      ..moveTo(bladeEdge.dx, bladeEdge.dy)
      ..lineTo(bladeSpine.dx, bladeSpine.dy)
      ..lineTo(bladeSpine.dx + normal.dx, bladeSpine.dy - normal.dy)
      ..lineTo(bladeEdge.dx + normal.dx, bladeEdge.dy - normal.dy)
      ..close();
    canvas.drawPath(blade, fill);
    canvas.drawPath(blade, pen);
    _label(
      canvas,
      'BLADE SPINE',
      Offset(bladeSpine.dx - 54, bladeSpine.dy - 17),
      color,
    );
    _label(
      canvas,
      'Edge contacts belt',
      Offset(beltX + 7, bladeEdge.dy - 13),
      color,
    );
    _label(
      canvas,
      'Flat reference face',
      Offset(blockEnd - 53, blockTopEnd.dy - 13),
      color,
    );
    // Arc center is the true intersection of the block face and horizontal rest.
    canvas.drawArc(
      Rect.fromCircle(center: blockTopStart, radius: 24),
      -angle,
      angle,
      false,
      pen,
    );
    _label(
      canvas,
      'Block ${result.nominalBlockAngleDegrees.toStringAsFixed(2)}°',
      Offset(blockStart + 3, restY - 38),
      color,
    );
    _label(
      canvas,
      'Grinding ${result.actualGrindingAngleDegrees.toStringAsFixed(2)}°',
      Offset(size.width * .40, 13),
      color,
    );
  }

  @override
  bool shouldRepaint(covariant _GrindingSetupPainter old) =>
      old.result != result || old.color != color;
}

void _dimension(
  Canvas canvas,
  Offset start,
  Offset end,
  String label,
  Color color,
) {
  final paint = Paint()
    ..color = color.withValues(alpha: .8)
    ..strokeWidth = 1;
  canvas.drawLine(start, end, paint);
  _arrow(canvas, start, end, paint);
  _arrow(canvas, end, start, paint);
  final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
  _label(canvas, label, Offset(mid.dx - 35, mid.dy - 16), color);
}

void _arrow(Canvas canvas, Offset tip, Offset from, Paint paint) {
  final angle = math.atan2(from.dy - tip.dy, from.dx - tip.dx);
  const size = 5.0;
  final path = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(
      tip.dx + size * math.cos(angle + .45),
      tip.dy + size * math.sin(angle + .45),
    )
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(
      tip.dx + size * math.cos(angle - .45),
      tip.dy + size * math.sin(angle - .45),
    );
  canvas.drawPath(path, paint);
}

void _label(Canvas canvas, String text, Offset at, Color color) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 10),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, at);
}
