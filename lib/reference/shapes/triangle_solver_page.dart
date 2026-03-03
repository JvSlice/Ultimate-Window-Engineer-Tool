import 'dart:math';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

enum TriangleMode { sss, sas, asa, aas, ssa }

class TriangleSolution {
  final double a, b, c; // sides
  final double A, B, C; // angles in degrees
  final double area;

  const TriangleSolution({
    required this.a,
    required this.b,
    required this.c,
    required this.A,
    required this.B,
    required this.C,
    required this.area,
  });
}

class TriangleSolverPage extends StatefulWidget {
  const TriangleSolverPage({super.key});

  @override
  State<TriangleSolverPage> createState() => _TriangleSolverPageState();
}

class _TriangleSolverPageState extends State<TriangleSolverPage> {
  TriangleMode mode = TriangleMode.sss;

  // Inputs
  final aCtrl = TextEditingController(text: "");
  final bCtrl = TextEditingController(text: "");
  final cCtrl = TextEditingController(text: "");
  final aAngCtrl = TextEditingController(text: "");
  final bAngCtrl = TextEditingController(text: "");
  final cAngCtrl = TextEditingController(text: "");

  

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());
  double _toRad(double deg) => deg * pi / 180.0;
  double _toDeg(double rad) => rad * 180.0 / pi;

  @override
  void dispose() {
    aCtrl.dispose();
    bCtrl.dispose();
    cCtrl.dispose();
    aAngCtrl.dispose();
    bAngCtrl.dispose();
    cAngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

   

    return TerminalScaffold(
      title: "Triangle Solver",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Select input type:",
              style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _modeButton(accent, "SSS", TriangleMode.sss),
                _modeButton(accent, "SAS", TriangleMode.sas),
                _modeButton(accent, "ASA", TriangleMode.asa),
                _modeButton(accent, "AAS", TriangleMode.aas),
                _modeButton(accent, "SSA*", TriangleMode.ssa),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              mode == TriangleMode.ssa
                  ? "*SSA can have 0, 1, or 2 solutions."
                  : "Enter the known values. Leave others blank.",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),

            const SizedBox(height: 18),

            ..._buildInputs(accent),

            const SizedBox(height: 18),

            if (solutions.isEmpty)
              terminalResultCard(
                accent: accent,
                lines: const [
                  "No valid solution yet (check triangle inequality / angles).",
                ],
              )
            else
              Column(
                children: [
                  for (int i = 0; i < solutions.length; i++) ...[
                    terminalResultCard(
                      accent: accent,
                      lines: _solutionLines(solutions[i], index: solutions.length > 1 ? i + 1 : null),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(Color accent, String label, TriangleMode m) {
    final selected = mode == m;
    return SizedBox(
      width: 92,
      height: 42,
      child: OutlinedButton(
        onPressed: () => setState(() => mode = m),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 2),
          backgroundColor: selected ? accent.withValues(alpha: 0.80) : Colors.transparent,
        ),
        child: Text(label, style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
      ),
    );
  }

  List<Widget> _buildInputs(Color accent) {
    // We'll keep a consistent layout:
    // sides a,b,c and angles A,B,C fields; but we only "require" certain ones per mode.
    return [
      Text("Sides", style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      terminalNumberField(accent: accent, label: "a", hint: "side a", controller: aCtrl),
      const SizedBox(height: 10),
      terminalNumberField(accent: accent, label: "b", hint: "side b", controller: bCtrl),
      const SizedBox(height: 10),
      terminalNumberField(accent: accent, label: "c", hint: "side c", controller: cCtrl),
      const SizedBox(height: 18),
      Text("Angles (degrees)", style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      terminalNumberField(accent: accent, label: "A", hint: "angle A", controller: aAngCtrl),
      const SizedBox(height: 10),
      terminalNumberField(accent: accent, label: "B", hint: "angle B", controller: bAngCtrl),
      const SizedBox(height: 10),
      terminalNumberField(accent: accent, label: "C", hint: "angle C", controller: cAngCtrl),
    ];
  }

  terminalCaclcButton(accent: accent, onPressed: _calculate),

  List<String> _solutionLines(TriangleSolution s, {int? index}) {
    final header = (index == null) ? "Solution:" : "Solution $index:";
    return [
      header,
      "a = ${s.a.toStringAsFixed(4)}",
      "b = ${s.b.toStringAsFixed(4)}",
      "c = ${s.c.toStringAsFixed(4)}",
      "A = ${s.A.toStringAsFixed(2)}°",
      "B = ${s.B.toStringAsFixed(2)}°",
      "C = ${s.C.toStringAsFixed(2)}°",
      "Area = ${s.area.toStringAsFixed(4)}",
    ];
  }

  // -------- SOLVER --------
  List<TriangleSolution> _solve() {
    final a = _p(aCtrl);
    final b = _p(bCtrl);
    final c = _p(cCtrl);
    final A = _p(aAngCtrl);
    final B = _p(bAngCtrl);
    final C = _p(cAngCtrl);

    switch (mode) {
      case TriangleMode.sss:
        if (a == null || b == null || c == null) return [];
        return _solveSSS(a, b, c);

      case TriangleMode.sas:
        // Use: a, b, C (included angle between a and b), OR a,c,B OR b,c,A
        // We'll prefer the one that is fully provided.
        if (a != null && b != null && C != null) return _solveSAS(a, b, C, includedBetween: "ab");
        if (a != null && c != null && B != null) return _solveSAS(a, c, B, includedBetween: "ac");
        if (b != null && c != null && A != null) return _solveSAS(b, c, A, includedBetween: "bc");
        return [];

      case TriangleMode.asa:
        // ASA: two angles with included side between them
        // We'll allow: A,B,c OR A,C,b OR B,C,a
        if (A != null && B != null && c != null) return _solveASA(A, B, c, includedSideName: "c");
        if (A != null && C != null && b != null) return _solveASA(A, C, b, includedSideName: "b");
        if (B != null && C != null && a != null) return _solveASA(B, C, a, includedSideName: "a");
        return [];

      case TriangleMode.aas:
        // AAS: two angles and a NON-included side
        // We'll accept any two angles + any one side, compute the rest.
        if ((A != null && B != null && (a != null || b != null || c != null)) ||
            (A != null && C != null && (a != null || b != null || c != null)) ||
            (B != null && C != null && (a != null || b != null || c != null))) {
          return _solveAAS(A, B, C, a, b, c);
        }
        return [];

      case TriangleMode.ssa:
        // SSA: two sides and an angle NOT between them.
        // We'll support common: A with a and b (or c), etc.
        // Use whichever triple is provided.
        if (A != null && a != null && b != null) return _solveSSA(angleDeg: A, oppositeSide: a, otherSide: b, angleName: "A", oppName: "a", otherName: "b");
        if (A != null && a != null && c != null) return _solveSSA(angleDeg: A, oppositeSide: a, otherSide: c, angleName: "A", oppName: "a", otherName: "c");
        if (B != null && b != null && a != null) return _solveSSA(angleDeg: B, oppositeSide: b, otherSide: a, angleName: "B", oppName: "b", otherName: "a");
        if (B != null && b != null && c != null) return _solveSSA(angleDeg: B, oppositeSide: b, otherSide: c, angleName: "B", oppName: "b", otherName: "c");
        if (C != null && c != null && a != null) return _solveSSA(angleDeg: C, oppositeSide: c, otherSide: a, angleName: "C", oppName: "c", otherName: "a");
        if (C != null && c != null && b != null) return _solveSSA(angleDeg: C, oppositeSide: c, otherSide: b, angleName: "C", oppName: "c", otherName: "b");
        return [];
    }
  }

  List<TriangleSolution> _solveSSS(double a, double b, double c) {
    if (a <= 0 || b <= 0 || c <= 0) return [];
    if (a + b <= c || a + c <= b || b + c <= a) return [];

    final A = _toDeg(acos(((b * b) + (c * c) - (a * a)) / (2 * b * c)));
    final B = _toDeg(acos(((a * a) + (c * c) - (b * b)) / (2 * a * c)));
    final C = 180.0 - A - B;

    final s = (a + b + c) / 2.0;
    final area = sqrt(max(0, s * (s - a) * (s - b) * (s - c)));

    return [TriangleSolution(a: a, b: b, c: c, A: A, B: B, C: C, area: area)];
  }

  List<TriangleSolution> _solveSAS(double side1, double side2, double includedAngleDeg, {required String includedBetween}) {
    if (side1 <= 0 || side2 <= 0 || includedAngleDeg <= 0 || includedAngleDeg >= 180) return [];

    final C = includedAngleDeg;
    final c = sqrt(side1 * side1 + side2 * side2 - 2 * side1 * side2 * cos(_toRad(C)));

    // Now solve the rest via law of sines
    final A = _toDeg(asin((side1 * sin(_toRad(C))) / c));
    final B = 180.0 - A - C;

    // Map sides to a,b,c depending on which included pair we used
    double a, b, cc;
    double AA, BB, CC;

    if (includedBetween == "ab") {
      a = side1;
      b = side2;
      cc = c;
      CC = C;
      AA = A;
      BB = B;
    } else if (includedBetween == "ac") {
      // side1=a, side2=c, included angle is B
      a = side1;
      cc = side2;
      b = c; // computed side opposite included angle
      BB = C;
      // A computed corresponds to angle opposite side1
      AA = A;
      CC = 180.0 - AA - BB;
    } else {
      // "bc": side1=b, side2=c, included angle is A
      b = side1;
      cc = side2;
      a = c; // computed
      AA = C;
      // A from asin corresponds to angle opposite side1 (b) -> that's B
      BB = A;
      CC = 180.0 - AA - BB;
    }

    final area = 0.5 * side1 * side2 * sin(_toRad(includedAngleDeg));

    return [TriangleSolution(a: a, b: b, c: cc, A: AA, B: BB, C: CC, area: area)];
  }

  List<TriangleSolution> _solveASA(double angle1, double angle2, double includedSide, {required String includedSideName}) {
    if (angle1 <= 0 || angle2 <= 0) return [];
    final angle3 = 180.0 - angle1 - angle2;
    if (angle3 <= 0) return [];

    // Included side is between the two given angles:
    // If included side is c => angles are A and B.
    double A, B, C, a, b, c;
    if (includedSideName == "c") {
      A = angle1; B = angle2; C = angle3;
      c = includedSide;
      a = c * sin(_toRad(A)) / sin(_toRad(C));
      b = c * sin(_toRad(B)) / sin(_toRad(C));
    } else if (includedSideName == "b") {
      A = angle1; C = angle2; B = angle3;
      b = includedSide;
      a = b * sin(_toRad(A)) / sin(_toRad(B));
      c = b * sin(_toRad(C)) / sin(_toRad(B));
    } else {
      B = angle1; C = angle2; A = angle3;
      a = includedSide;
      b = a * sin(_toRad(B)) / sin(_toRad(A));
      c = a * sin(_toRad(C)) / sin(_toRad(A));
    }

    final area = 0.5 * a * b * sin(_toRad(C)); // any equivalent
    return [TriangleSolution(a: a, b: b, c: c, A: A, B: B, C: C, area: area)];
  }

  List<TriangleSolution> _solveAAS(double? A, double? B, double? C, double? a, double? b, double? c) {
    // Compute missing angle first.
    double? AA = A;
    double? BB = B;
    double? CC = C;

    final angles = [AA, BB, CC].whereType<double>().toList();
    if (angles.length < 2) return [];

    if (AA == null) AA = 180.0 - (BB ?? 0) - (CC ?? 0);
    if (BB == null) BB = 180.0 - (AA ?? 0) - (CC ?? 0);
    if (CC == null) CC = 180.0 - (AA ?? 0) - (BB ?? 0);

    if (AA <= 0 || BB <= 0 || CC <= 0) return [];

    // Need one side
    if (a == null && b == null && c == null) return [];

    // Use law of sines with whatever side we have
    double scale;
    if (a != null) {
      scale = a / sin(_toRad(AA));
    } else if (b != null) {
      scale = b / sin(_toRad(BB));
    } else {
      scale = c! / sin(_toRad(CC));
    }

    final aa = scale * sin(_toRad(AA));
    final bb = scale * sin(_toRad(BB));
    final cc = scale * sin(_toRad(CC));

    final s = (aa + bb + cc) / 2.0;
    final area = sqrt(max(0, s * (s - aa) * (s - bb) * (s - cc)));

    return [TriangleSolution(a: aa, b: bb, c: cc, A: AA, B: BB, C: CC, area: area)];
  }

  List<TriangleSolution> _solveSSA({
    required double angleDeg,
    required double oppositeSide,
    required double otherSide,
    required String angleName,
    required String oppName,
    required String otherName,
  }) {
    // SSA: given angle A and sides a (opposite A) and b (adjacent)
    // Use law of sines: sin(B) = b * sin(A) / a
    if (angleDeg <= 0 || angleDeg >= 180) return [];
    if (oppositeSide <= 0 || otherSide <= 0) return [];

    final A = angleDeg;
    final sinB = otherSide * sin(_toRad(A)) / oppositeSide;

    if (sinB.abs() > 1.0) return []; // no solution

    final B1 = _toDeg(asin(sinB));
    final B2 = 180.0 - B1;

    List<TriangleSolution> sols = [];

    for (final B in [B1, B2]) {
      final C = 180.0 - A - B;
      if (C <= 0) continue;

      // Find third side using law of sines: c/sin(C) = a/sin(A)
      final c = oppositeSide * sin(_toRad(C)) / sin(_toRad(A));

      // Determine mapping to a,b,c and A,B,C based on which was the given angle/side.
      // We'll just output with "a opposite A" convention for the solution:
      // a = oppositeSide (given), A = given angle.
      final a = oppositeSide;
      final b = otherSide;
      final area = 0.5 * a * b * sin(_toRad(C)); // works

      sols.add(TriangleSolution(a: a, b: b, c: c, A: A, B: B, C: C, area: area));
    }

    // Remove near-duplicate solutions (when B1 == B2 for right cases)
    sols = sols.toSet().toList();

    return sols;
  }
}


