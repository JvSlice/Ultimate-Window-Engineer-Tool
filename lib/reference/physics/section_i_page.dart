import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import 'section_props_store.dart';

enum Units { inch, mm }

enum SectionShape { rect, rectTube, circle, pipe }

class SectionIPage extends StatefulWidget {
  const SectionIPage({super.key});

  @override
  State<SectionIPage> createState() => _SectionIPageState();
}

class _SectionIPageState extends State<SectionIPage> {
  Units units = Units.inch;
  SectionShape shape = SectionShape.rect;

  // Inputs (meaning changes by shape)
  final bCtrl = TextEditingController(text: "2.0"); // width / OD
  final hCtrl = TextEditingController(text: "1.0"); // height / ID
  final tCtrl = TextEditingController(text: "0.125"); // wall thickness (tube)

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());
  double _convertVal(double v, double factor) => v * factor;

  void _convertInputs(double factor) {
    void conv(TextEditingController c) {
      final v = double.tryParse(c.text.trim());
      if (v == null) return;
      c.text = _convertVal(v, factor).toStringAsFixed(4);
    }

    conv(bCtrl);
    conv(hCtrl);
    conv(tCtrl);
  }

  @override
  void dispose() {
    bCtrl.dispose();
    hCtrl.dispose();
    tCtrl.dispose();
    super.dispose();
  }

  String get unitLabel => units == Units.inch ? "in" : "mm";
  String get iUnitLabel => units == Units.inch ? "in^4" : "mm^4";
  String get aUnitLabel => units == Units.inch ? "in^2" : "mm^2";
  String get sUnitLabel => units == Units.inch ? "in^3" : "mm^3";
  String get rUnitLabel => units == Units.inch ? "in" : "mm";

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    // Read inputs
    final b = _p(bCtrl);
    final h = _p(hCtrl);
    final t = _p(tCtrl);

    // Results
    double? area;
    double? ix;
    double? iy;

    String formulaText = "";

    if (shape == SectionShape.rect) {
      // Rectangle (b = width, h = height)
      // Ix = b*h^3/12
      // Iy = h*b^3/12
      if (b != null && h != null) {
        area = b * h;
        ix = b * pow(h, 3) / 12.0;
        iy = h * pow(b, 3) / 12.0;
      }
      formulaText =
          "Rectangle (centroid axes)\n"
          "A = b·h\n"
          "Ix = b·h^3 / 12\n"
          "Iy = h·b^3 / 12";
    }

    if (shape == SectionShape.rectTube) {
      // Hollow rectangle: outer b,h and thickness t
      // Inner dims: bi=b-2t, hi=h-2t
      // Ix = (b*h^3 - bi*hi^3)/12
      // Iy = (h*b^3 - hi*bi^3)/12
      if (b != null && h != null && t != null) {
        final bi = b - 2 * t;
        final hi = h - 2 * t;
        if (bi > 0 && hi > 0) {
          area = (b * h) - (bi * hi);
          ix = (b * pow(h, 3) - bi * pow(hi, 3)) / 12.0;
          iy = (h * pow(b, 3) - hi * pow(bi, 3)) / 12.0;
        }
      }
      formulaText =
          "Hollow Rectangle / Tube\n"
          "bi = b - 2t,  hi = h - 2t\n"
          "A = b·h - bi·hi\n"
          "Ix = (b·h^3 - bi·hi^3) / 12\n"
          "Iy = (h·b^3 - hi·bi^3) / 12";
    }

    if (shape == SectionShape.circle) {
      // Solid circle: use b as diameter (D)
      // A = πD^2/4
      // I = πD^4/64 (same for x and y)
      if (b != null) {
        final d = b;
        area = pi * d * d / 4.0;
        ix = pi * pow(d, 4) / 64.0;
        iy = ix;
      }
      formulaText =
          "Solid Circle (D)\n"
          "A = πD^2 / 4\n"
          "I = πD^4 / 64";
    }

    if (shape == SectionShape.pipe) {
      // Pipe: OD=b, ID=h
      // A = π(OD^2 - ID^2)/4
      // I = π(OD^4 - ID^4)/64
      if (b != null && h != null) {
        final od = b;
        final id = h;
        if (id >= 0 && id < od) {
          area = pi * (od * od - id * id) / 4.0;
          ix = pi * (pow(od, 4) - pow(id, 4)) / 64.0;
          iy = ix;
        }
      }
      formulaText =
          "Hollow Circle / Pipe\n"
          "A = π(OD^2 - ID^2) / 4\n"
          "I = π(OD^4 - ID^4) / 64";
    }
    double? sx;
    double? sy;
    double? rx;
    double? ry;

    double? cX; // for Sx (uses height)
    double? cY; // for Sy (uses width)

    // Determine c distances based on current shape outer dims
    if (shape == SectionShape.rect || shape == SectionShape.rectTube) {
      if (h != null && b != null && h > 0 && b > 0) {
        cX = h / 2.0;
        cY = b / 2.0;
      }
    } else if (shape == SectionShape.circle) {
      if (b != null && b > 0) {
        cX = b / 2.0;
        cY = b / 2.0;
      }
    } else if (shape == SectionShape.pipe) {
      if (b != null && b > 0) {
        cX = b / 2.0; // OD/2
        cY = b / 2.0;
      }
    }

    if (area != null &&
        area > 0 &&
        ix != null &&
        iy != null &&
        cX != null &&
        cY != null) {
      sx = ix / cX;
      sy = iy / cY;
      rx = sqrt(ix / area);
      ry = sqrt(iy / area);
    }

    return TerminalScaffold(
      title: "Section Properties (I)",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Units toggle
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => units = Units.inch),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent, width: 2),
                      backgroundColor: units == Units.inch
                          ? accent.withValues(alpha: 0.80)
                          : Colors.transparent,
                    ),
                    child: Text("INCH", style: TextStyle(color: accent)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => units = Units.mm),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent, width: 2),
                      backgroundColor: units == Units.mm
                          ? accent.withValues(alpha: 0.80)
                          : Colors.transparent,
                    ),
                    child: Text("MM", style: TextStyle(color: accent)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Shape selector
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _shapeChip(accent, "RECT", SectionShape.rect),
                _shapeChip(accent, "RECT TUBE", SectionShape.rectTube),
                _shapeChip(accent, "CIRCLE", SectionShape.circle),
                _shapeChip(accent, "PIPE", SectionShape.pipe),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              formulaText,
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),

            const SizedBox(height: 18),

            // Inputs (change labels by shape)
            ..._buildInputs(accent),

            const SizedBox(height: 18),

            terminalResultCard(
              accent: accent,
              lines: [
                "Area (A): ${area == null ? '—' : area.toStringAsFixed(6)} $aUnitLabel",
                "Ix: ${ix == null ? '—' : ix.toStringAsFixed(6)} $iUnitLabel",
                "Iy: ${iy == null ? '—' : iy.toStringAsFixed(6)} $iUnitLabel",
                "Sx: ${sx == null ? '—' : sx.toStringAsFixed(6)} $sUnitLabel",
                "Sy: ${sy == null ? '—' : sy.toStringAsFixed(6)} $sUnitLabel",
                "rx: ${rx == null ? '—' : rx.toStringAsFixed(6)} $rUnitLabel",
                "ry: ${ry == null ? '—' : ry.toStringAsFixed(6)} $rUnitLabel",
              ],
            ),
            const SizedBox(height: 14),

OutlinedButton(
  onPressed: () => _storeSection(
    context: context,
    area: area,
    ix: ix,
    iy: iy,
    sx: sx,
    sy: sy,
    rx: rx,
    ry: ry,
  ),
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: accent, width: 2),
    foregroundColor: accent,
    padding: const EdgeInsets.symmetric(vertical: 14),
  ).copyWith(
    overlayColor: WidgetStateProperty.all(accent.withValues(alpha: 0.08)),
  ),
  child: const Text("STORE I-VALUE"),
),
          ],
        ),
      ),
    );
  }

  void _storeSection({
  required BuildContext context,
  required double? area,
  required double? ix,
  required double? iy,
  required double? sx,
  required double? sy,
  required double? rx,
  required double? ry,
}) {
  // Don’t store junk if not solved yet
  if (area == null || ix == null || iy == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enter valid dimensions first.")),
    );
    return;
  }

  // Build a “record” to store (adjust names to match your store file)
  final record = SectionPropsRecord(
    timestamp: DateTime.now(),
    units: units.name,          // "inch" or "mm"
    shape: shape.name,          // "rect", "rectTube", etc
    b: _p(bCtrl),
    h: _p(hCtrl),
    t: _p(tCtrl),
    area: area,
    ix: ix,
    iy: iy,
    sx: sx,
    sy: sy,
    rx: rx,
    ry: ry,
  );

  SectionPropsStore.instance.add(record);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Stored section properties.")),
  );
}

  Widget _shapeChip(Color accent, String label, SectionShape s) {
    final selected = shape == s;
    return SizedBox(
      width: 140,
      height: 44,
      child: OutlinedButton(
        onPressed: () => setState(() => shape = s),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 2),
          backgroundColor: selected
              ? accent.withValues(alpha: 0.80)
              : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(color: accent, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  List<Widget> _buildInputs(Color accent) {
    // For your terminalNumberField helper (same one you used elsewhere)
    switch (shape) {
      case SectionShape.rect:
        return [
          terminalNumberField(
            accent: accent,
            label: "Width b ($unitLabel)",
            hint: unitLabel,
            controller: bCtrl,
          ),
          const SizedBox(height: 12),
          terminalNumberField(
            accent: accent,
            label: "Height h ($unitLabel)",
            hint: unitLabel,
            controller: hCtrl,
          ),
        ];

      case SectionShape.rectTube:
        return [
          terminalNumberField(
            accent: accent,
            label: "Outer width b ($unitLabel)",
            hint: unitLabel,
            controller: bCtrl,
          ),
          const SizedBox(height: 12),
          terminalNumberField(
            accent: accent,
            label: "Outer height h ($unitLabel)",
            hint: unitLabel,
            controller: hCtrl,
          ),
          const SizedBox(height: 12),
          terminalNumberField(
            accent: accent,
            label: "Wall thickness t ($unitLabel)",
            hint: unitLabel,
            controller: tCtrl,
          ),
        ];

      case SectionShape.circle:
        return [
          terminalNumberField(
            accent: accent,
            label: "Diameter D ($unitLabel)",
            hint: unitLabel,
            controller: bCtrl,
          ),
        ];

      case SectionShape.pipe:
        return [
          terminalNumberField(
            accent: accent,
            label: "Outer diameter OD ($unitLabel)",
            hint: unitLabel,
            controller: bCtrl,
          ),
          const SizedBox(height: 12),
          terminalNumberField(
            accent: accent,
            label: "Inner diameter ID ($unitLabel)",
            hint: unitLabel,
            controller: hCtrl,
          ),
        ];
    }
  }
}

