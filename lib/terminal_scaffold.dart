import 'package:flutter/material.dart';

class TerminalScaffold extends StatelessWidget {
  final Widget child;
  final String title;

  const TerminalScaffold({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.black,
                    accent.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),

          // Scanlines
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ScanlinesPainter(accent: accent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ===== HEADER =====
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // LEFT: Home (hamburger)
                      SizedBox(
                        width: 48,
                        child: IconButton(
                          icon: Icon(Icons.menu, color: accent),
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                        ),
                      ),

                      // CENTER: Title
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      // RIGHT: Back (only if possible)
                      SizedBox(
                        width: 48,
                        child: Builder(
                          builder: (context) {
                            final canPop =
                                Navigator.of(context).canPop();

                            if (!canPop) {
                              return const SizedBox.shrink();
                            }

                            return IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: accent,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== PAGE CONTENT =====
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
    final paint = Paint()
      ..color = accent.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScanlinesPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}
