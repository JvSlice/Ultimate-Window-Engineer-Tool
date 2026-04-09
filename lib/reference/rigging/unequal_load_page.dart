import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class RiggingUnequalLoadingPage extends StatefulWidget {
  const RiggingUnequalLoadingPage({super.key});

  @override
  State<RiggingUnequalLoadingPage> createState() =>
      _RiggingUnequalLoadingPageState();
}

class _RiggingUnequalLoadingPageState extends State<RiggingUnequalLoadingPage> {
  late final TextEditingController _loadController;
  late final TextEditingController _spanController;
  late final TextEditingController _offsetController;
  late final TextEditingController _angleController;

  double _load = 1000;
  double _span = 48; // distance between pick points
  double _offset = 0; // center of gravity offset
  double _angle = 60;

  @override
  void initState() {
    super.initState();
    _loadController = TextEditingController(text: '1000');
    _spanController = TextEditingController(text: '48');
    _offsetController = TextEditingController(text: '0');
    _angleController = TextEditingController(text: '60');
  }

  void _recalc() {
    setState(() {
      _load = double.tryParse(_loadController.text) ?? 1000;
      _span = double.tryParse(_spanController.text) ?? 48;
      _offset = double.tryParse(_offsetController.text) ?? 0;
      _angle = double.tryParse(_angleController.text) ?? 60;
    });
  }

  double _leftReaction() {
    // Simple beam statics:
    // R_left = W * ( (span/2 + offset) / span )
    return _load * ((_span / 2 + _offset) / _span);
  }

  double _rightReaction() {
    return _load - _leftReaction();
  }

  double _tension(double reaction) {
    final rad = _angle * math.pi / 180;
    final sin = math.sin(rad);
    if (sin <= 0) return double.infinity;
    return reaction / sin;
  }

  String _fmt(double v) {
    if (!v.isFinite) return '---';
    return v.toStringAsFixed(1);
  }

  List<String> _warnings() {
    final w = <String>[];

    if (_span <= 0) {
      w.add('Span must be greater than 0.');
    }

    if (_offset.abs() > _span / 2) {
      w.add('Offset exceeds pick span — unstable configuration.');
    }

    if (_angle < 30) {
      w.add('Low angle — tension increases rapidly.');
    }

    if (_offset != 0) {
      w.add('Uneven loading — one leg will carry more load.');
    }

    return w;
  }

  @override
  Widget build(BuildContext context) {
    final leftR = _leftReaction();
    final rightR = _rightReaction();

    final leftT = _tension(leftR);
    final rightT = _tension(rightR);

    final maxT = math.max(leftT, rightT);
    final minT = math.min(leftT, rightT);

    final imbalance = maxT > 0 ? ((maxT - minT) / maxT) * 100 : double.infinity;

    final warnings = _warnings();

    return TerminalScaffold(
      title: 'Unequal Leg Loading',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Panel(
                title: 'Inputs',
                child: Column(
                  children: [
                    _field('Total Load', _loadController, 'lb'),
                    const SizedBox(height: 10),
                    _field('Pick Span', _spanController, 'in'),
                    const SizedBox(height: 10),
                    _field('COG Offset (+ right)', _offsetController, 'in'),
                    const SizedBox(height: 10),
                    _field('Sling Angle', _angleController, 'deg'),
                    const SizedBox(height: 12),

                    OutlinedButton(
                      onPressed: _recalc,
                      child: const Text('Run Calc'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _Panel(
                title: 'Results',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Left Reaction', '${_fmt(leftR)} lb'),
                    _row('Right Reaction', '${_fmt(rightR)} lb'),
                    const SizedBox(height: 10),

                    _row('Left Tension', '${_fmt(leftT)} lb', true),
                    _row('Right Tension', '${_fmt(rightT)} lb', true),

                    const SizedBox(height: 10),
                    _row('Critical Leg', '${_fmt(maxT)} lb', true),
                    _row('Imbalance', '${_fmt(imbalance)} %'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _Panel(
                title: 'Warnings',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: warnings
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('• $e'),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),

              _Panel(
                title: 'Visual',
                child: SizedBox(
                  height: 240,
                  child: CustomPaint(
                    painter: _UnequalPainter(span: _span, offset: _offset),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, String suffix) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => _recalc(),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _row(String label, String value, [bool bold = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _UnequalPainter extends CustomPainter {
  final double span;
  final double offset;

  _UnequalPainter({required this.span, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.6;
    final leftX = size.width * 0.2;
    final rightX = size.width * 0.8;

    final cogX = size.width / 2 + (offset / span) * (rightX - leftX);

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // beam
    canvas.drawLine(Offset(leftX, centerY), Offset(rightX, centerY), paint);

    // pick points
    canvas.drawCircle(Offset(leftX, centerY), 6, paint);
    canvas.drawCircle(Offset(rightX, centerY), 6, paint);

    // center of gravity
    canvas.drawCircle(Offset(cogX, centerY), 8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
