import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class RiggingCOGEstimatorPage extends StatefulWidget {
  const RiggingCOGEstimatorPage({super.key});

  @override
  State<RiggingCOGEstimatorPage> createState() =>
      _RiggingCOGEstimatorPageState();
}

class _RiggingCOGEstimatorPageState extends State<RiggingCOGEstimatorPage> {
  final _lengthController = TextEditingController(text: '48');
  final _widthController = TextEditingController(text: '24');

  final _xController = TextEditingController(text: '24');
  final _yController = TextEditingController(text: '12');

  double length = 48;
  double width = 24;
  double x = 24;
  double y = 12;

  void _recalc() {
    setState(() {
      length = double.tryParse(_lengthController.text) ?? 48;
      width = double.tryParse(_widthController.text) ?? 24;
      x = double.tryParse(_xController.text) ?? 0;
      y = double.tryParse(_yController.text) ?? 0;
    });
  }

  List<String> _warnings() {
    final w = <String>[];

    if (x < 0 || x > length) {
      w.add('COG X is outside the object.');
    }

    if (y < 0 || y > width) {
      w.add('COG Y is outside the object.');
    }

    if (x != length / 2 || y != width / 2) {
      w.add('Load is not balanced — expect uneven rigging loads.');
    }

    return w;
  }

  @override
  Widget build(BuildContext context) {
    final warnings = _warnings();

    return TerminalScaffold(
      title: 'COG Estimator',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _panel(
                'Inputs',
                Column(
                  children: [
                    _field('Length', _lengthController, 'in'),
                    const SizedBox(height: 10),
                    _field('Width', _widthController, 'in'),
                    const SizedBox(height: 10),
                    _field('COG X', _xController, 'in'),
                    const SizedBox(height: 10),
                    _field('COG Y', _yController, 'in'),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _recalc,
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _panel(
                'Visual',
                SizedBox(
                  height: 260,
                  child: CustomPaint(
                    painter: _COGPainter(
                      length: length,
                      width: width,
                      x: x,
                      y: y,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _panel(
                'Warnings',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: warnings
                      .map((e) => Text('• $e'))
                      .toList(),
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

  Widget _panel(String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _COGPainter extends CustomPainter {
  final double length;
  final double width;
  final double x;
  final double y;

  _COGPainter({
    required this.length,
    required this.width,
    required this.x,
    required this.y,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(20, 20, size.width - 40, size.height - 40);

    final scaleX = rect.width / length;
    final scaleY = rect.height / width;

    final cogX = rect.left + x * scaleX;
    final cogY = rect.top + y * scaleY;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(rect, paint);

    // center
    final center = Offset(
      rect.left + rect.width / 2,
      rect.top + rect.height / 2,
    );

    canvas.drawCircle(center, 4, paint);

    // COG
    canvas.drawCircle(Offset(cogX, cogY), 6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
