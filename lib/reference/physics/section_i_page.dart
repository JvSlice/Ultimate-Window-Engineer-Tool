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
  final bCtrl = TextEditingController(text: "2.0"); // width / OD / diameter
  final hCtrl = TextEditingController(text: "1.0"); // height / ID
  final tCtrl = TextEditingController(text: "0.125"); // wall thickness (tube)

  // Stored results (so we can calculate on-demand)
  double? _area;
  double? _ix;
  double? _iy;
  double? _sx;
  double? _sy;
  double? _rx;
  double? _ry;
  String _formulaText = "";

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  @override
  void initState() {
    super.initState();
    _calculate(); // optional: pre-calc once on load
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

  SectionIUnits _storeUnits() =>
      units == Units.inch ? SectionIUnits.inch : SectionIUnits.mm;

  void _calculate() {
    final b = _p(bCtrl);
    final h = _p(hCtrl);
    final t = _p(tCtrl);

    double? area;
    double? ix;
    double? iy;
    String formulaText = "";

    if (shape == SectionShape.rect) {
      if (b != null && h != null && b > 0 && h > 0) {
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
      if (b != null && h != null && t != null && b > 0 && h > 0 && t > 0) {
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
      // Use b as Diameter D
      if (b != null && b > 0) {
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
      // OD=b, ID=h
      if (b != null && h != null && b > 0 && h >= 0) {
        final od = b;
        final id = h;
        if (id < od) {
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

    // Section modulus + radius of gyration
    double? sx;
    double? sy;
    double? rx;
    double? ry;

    double? cX; // for Sx (uses height or diameter)
    double? cY; // for Sy (uses width or diameter)

    if (shape == SectionShape.rect || shape == SectionShape.rectTube) {
      if (h != null && b != null && h > 0 && b > 0) {
        cX = h / 2.0;
        cY = b / 2.0;
      }
    } else if (shape == SectionShape.circle || shape == SectionShape.pipe) {
      if (b != null && b > 0) {
        cX = b / 2.0; // OD/2 for pipe, D/2 for circle
        cY = b / 2.0;
      }
    }

    if (area != null &&
        area > 0 &&
        ix != null &&
        iy != null &&
        cX != null &&
        cY != null &&
        cX > 0 &&
        cY > 0) {
      sx = ix / cX;
      sy = iy / cY;
      rx = sqrt(ix / area);
      ry = sqrt(iy / area);
    }

    setState(() {
      _area = area;
      _ix = ix;
      _iy = iy;
      _sx = sx;
      _sy = sy;
      _rx = rx;
      _ry = ry;
      _formulaText = formulaText;
    });
  }

  void _storeSection() {
    // Must have a valid calc first
    if (_area == null ||
        _ix == null ||
        _iy == null ||
        _sx == null ||
        _sy == null ||
        _rx == null ||
        _ry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nothing to store yet — press Calculate.")),
      );
      return;
    }

    lastSectionProps.value = SectionProps(
      area: _area!,
      ix: _ix!,
      iy: _iy!,
      sx: _sx!,
      sy: _sy!,
      rx: _rx!,
      ry: _ry!,
      units: _storeUnits(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Stored section properties.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

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
              _formulaText,
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),

            const SizedBox(height: 18),

            // Inputs (change labels by shape)
            ..._buildInputs(accent),

            const SizedBox(height: 18),

            terminalResultCard(
              accent: accent,
              lines: [
                "Area (A): ${_area == null ? '—' : _area!.toStringAsFixed(6)} $aUnitLabel",
                "Ix: ${_ix == null ? '—' : _ix!.toStringAsFixed(6)} $iUnitLabel",
                "Iy: ${_iy == null ? '—' : _iy!.toStringAsFixed(6)} $iUnitLabel",
                "Sx: ${_sx == null ? '—' : _sx!.toStringAsFixed(6)} $sUnitLabel",
                "Sy: ${_sy == null ? '—' : _sy!.toStringAsFixed(6)} $sUnitLabel",
                "rx: ${_rx == null ? '—' : _rx!.toStringAsFixed(6)} $rUnitLabel",
                "ry: ${_ry == null ? '—' : _ry!.toStringAsFixed(6)} $rUnitLabel",
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _calculate,
                    icon: Icon(Icons.calculate, color: accent),
                    label: Text("Calculate", style: TextStyle(color: accent)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent, width: 2),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _storeSection,
                    icon: Icon(Icons.save, color: accent),
                    label: Text("Store", style: TextStyle(color: accent)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shapeChip(Color accent, String label, SectionShape s) {
    final selected = shape == s;
    return SizedBox(
      width: 140,
      height: 44,
      child: OutlinedButton(
        onPressed: () {
          setState(() => shape = s);
          _calculate(); // recalc using new shape
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 2),
          backgroundColor:
              selected ? accent.withValues(alpha: 0.80) : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(color: accent, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  List<Widget> _buildInputs(Color accent) {
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
