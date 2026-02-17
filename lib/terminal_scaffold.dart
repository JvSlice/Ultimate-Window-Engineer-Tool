import 'package:flutter/material.dart';

class TerminalScaffold extends StatelessWidget {
  final Widget child;
  final Color accent;
  final String title;
  const TerminalScaffold({
    super.key,
    required this.child,
    required this.accent,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Hamburger menu

          //Glow here
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Colors.black, accent.withValues(alpha: 0.08)],
                ),
              ),
            ),
          ),

          // Scanlines here
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: ScanlinesPainter(accent: accent)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: accent),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      title, // title 2 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      //overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        Expanded(child: child),
        ],
        
      ),
    ),
        ], 
      ),
    );

      

  }
}

class ScanlinesPainter extends CustomPainter {
  final Color accent;
  ScanlinesPainter({required this.accent});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = accent.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant ScanlinesPainter oldDelegate) {
    // TODO: implement ==
    return oldDelegate.accent != accent;
  }
}
