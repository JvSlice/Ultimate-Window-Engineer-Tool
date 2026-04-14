import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class RiggingAngleVisualizerPage extends StatefulWidget {
  const RiggingAngleVisualizerPage({super.key});

  @override
  State<RiggingAngleVisualizerPage> createState() =>
      _RiggingAngleVisualizerPageState();
}

class _RiggingAngleVisualizerPageState
    extends State<RiggingAngleVisualizerPage> {
  final _angleController = TextEditingController(text: '60');

  double angle = 60;

  void _recalc() {
    setState(() {
      angle = double.tryParse(_angleController.text) ?? 60;
    });
  }

  double _factor() {
    final rad = angle * math.pi / 180;
    final sin = math.sin(rad);
    if (sin <= 0) return double.infinity;
    return 1 / sin;
  }

  @override
  Widget build(BuildContext context) {
    final factor = _factor();

    return TerminalScaffold(
      title: 'Angle Visualizer',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      TextField(
                        controller: _angleController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _recalc(),
                        decoration: const InputDecoration(
                          labelText: 'Angle from Horizontal',
                          suffixText: 'deg',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _recalc,
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Text(
                        'Load Multiplier: ${factor.isFinite ? factor.toStringAsFixed(2) : "---"}x',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: CustomPaint(
                  painter: _AnglePainter(angle: angle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnglePainter extends CustomPainter {
  final double angle;

  _AnglePainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final centerTop = Offset(size.width / 2, size.height * 0.2);
    final centerBottom = Offset(size.width / 2, size.height * 0.8);

    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final rad = angle * math.pi / 180;

    final spread = size.width * 0.3;

    final left = Offset(
      centerBottom.dx - spread,
      centerBottom.dy,
    );

    final right = Offset(
      centerBottom.dx + spread,
      centerBottom.dy,
    );

    canvas.drawLine(centerTop, left, paint);
    canvas.drawLine(centerTop, right, paint);

    canvas.drawCircle(centerTop, 10, paint);

    // load
    final rect = Rect.fromCenter(
      center: centerBottom,
      width: 100,
      height: 40,
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
