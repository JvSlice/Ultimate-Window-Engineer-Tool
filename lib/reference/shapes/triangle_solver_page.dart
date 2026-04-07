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

  // Results (only update when Calculate is pressed)

  List<TriangleSolution> _solutions = [];

  String? _error;

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  double _toRad(double deg) => deg * pi / 180.0;

  double _toDeg(double rad) => rad * 180.0 / pi;

  void _calculate() {

    final sols = _solve();

    setState(() {

      _solutions = sols;

      _error = sols.isEmpty

          ? "No valid solution (check triangle inequality / angles)."

          : null;

    });

  }

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

              style: TextStyle(

                color: accent,

                fontSize: 18,

                fontWeight: FontWeight.w800,

              ),

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

            const SizedBox(height: 16),

            // ✅ Calculate button (your reusable widget)

            terminalCalcButton(

              accent: accent,

              onPressed: _calculate,

            ),

            const SizedBox(height: 18),

            if (_solutions.isEmpty)

              terminalResultCard(

                accent: accent,

                lines: [

                  _error ?? "Press Calculate to solve.",

                ],

              )

            else

              Column(

                children: [

                  for (int i = 0; i < _solutions.length; i++) ...[

                    terminalResultCard(

                      accent: accent,

                      lines: _solutionLines(

                        _solutions[i],

                        index: _solutions.length > 1 ? i + 1 : null,

                      ),

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

        onPressed: () {

          setState(() {

            mode = m;

            _solutions = [];

            _error = null;

          });

        },

        style: OutlinedButton.styleFrom(

          side: BorderSide(color: accent, width: 2),

          backgroundColor:

              selected ? accent.withValues(alpha: 0.80) : Colors.transparent,

        ),

        child: Text(

          label,

          style: TextStyle(color: accent, fontWeight: FontWeight.w800),

        ),

      ),

    );

  }

  List<Widget> _buildInputs(Color accent) {

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

        // Prefer: a, b, C (included between a & b) OR a,c,B OR b,c,A

        if (a != null && b != null && C != null) return _solveSAS(a, b, C, includedBetween: "ab");

        if (a != null && c != null && B != null) return _solveSAS(a, c, B, includedBetween: "ac");

        if (b != null && c != null && A != null) return _solveSAS(b, c, A, includedBetween: "bc");

        return [];

      case TriangleMode.asa:

        // ASA: A,B,c OR A,C,b OR B,C,a

        if (A != null && B != null && c != null) return _solveASA(A, B, c, includedSideName: "c");

        if (A != null && C != null && b != null) return _solveASA(A, C, b, includedSideName: "b");

        if (B != null && C != null && a != null) return _solveASA(B, C, a, includedSideName: "a");

        return [];

      case TriangleMode.aas:

        // Two angles + any side

        final anglesCount = [A, B, C].whereType<double>().length;

        final hasSide = (a != null || b != null || c != null);

        if (anglesCount >= 2 && hasSide) {

          return _solveAAS(A, B, C, a, b, c);

        }

        return [];

      case TriangleMode.ssa:

        // Angle + opposite side + another side

        if (A != null && a != null && b != null) return _solveSSA(angleDeg: A, oppositeSide: a, otherSide: b);

        if (A != null && a != null && c != null) return _solveSSA(angleDeg: A, oppositeSide: a, otherSide: c);

        if (B != null && b != null && a != null) return _solveSSA(angleDeg: B, oppositeSide: b, otherSide: a);

        if (B != null && b != null && c != null) return _solveSSA(angleDeg: B, oppositeSide: b, otherSide: c);

        if (C != null && c != null && a != null) return _solveSSA(angleDeg: C, oppositeSide: c, otherSide: a);

        if (C != null && c != null && b != null) return _solveSSA(angleDeg: C, oppositeSide: c, otherSide: b);

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

  List<TriangleSolution> _solveSAS(

    double side1,

    double side2,

    double includedAngleDeg, {

    required String includedBetween,

  }) {

    if (side1 <= 0 || side2 <= 0) return [];

    if (includedAngleDeg <= 0 || includedAngleDeg >= 180) return [];

    // side opposite included angle:

    final sideOppIncluded = sqrt(

      side1 * side1 + side2 * side2 - 2 * side1 * side2 * cos(_toRad(includedAngleDeg)),

    );

    if (sideOppIncluded <= 0) return [];

    // Law of sines:

    final angleOppSide1 = _toDeg(asin((side1 * sin(_toRad(includedAngleDeg))) / sideOppIncluded));

    final angleOppSide2 = 180.0 - angleOppSide1 - includedAngleDeg;

    // Map into a,b,c and A,B,C

    if (includedBetween == "ab") {

      final a = side1;

      final b = side2;

      final c = sideOppIncluded;

      final C = includedAngleDeg;

      final A = angleOppSide1;

      final B = angleOppSide2;

      final area = 0.5 * a * b * sin(_toRad(C));

      return [TriangleSolution(a: a, b: b, c: c, A: A, B: B, C: C, area: area)];

    } else if (includedBetween == "ac") {

      // included angle is B between a and c

      final a = side1;

      final c = side2;

      final b = sideOppIncluded;

      final B = includedAngleDeg;

      final A = angleOppSide1;

      final C = 180.0 - A - B;

      final area = 0.5 * a * c * sin(_toRad(B));

      return [TriangleSolution(a: a, b: b, c: c, A: A, B: B, C: C, area: area)];

    } else {

      // "bc": included angle is A between b and c

      final b = side1;

      final c = side2;

      final a = sideOppIncluded;

      final A = includedAngleDeg;

      final B = angleOppSide1; // opposite b

      final C = 180.0 - A - B;

      final area = 0.5 * b * c * sin(_toRad(A));

      return [TriangleSolution(a: a, b: b, c: c, A: A, B: B, C: C, area: area)];

    }

  }

  List<TriangleSolution> _solveASA(

    double angle1,

    double angle2,

    double includedSide, {

    required String includedSideName,

  }) {

    if (angle1 <= 0 || angle2 <= 0 || includedSide <= 0) return [];

    final angle3 = 180.0 - angle1 - angle2;

    if (angle3 <= 0) return [];

    double A, B, C, a, b, c;

    if (includedSideName == "c") {

      A = angle1;

      B = angle2;

      C = angle3;

      c = includedSide;

      a = c * sin(_toRad(A)) / sin(_toRad(C));

      b = c * sin(_toRad(B)) / sin(_toRad(C));

    } else if (includedSideName == "b") {

      A = angle1;

      C = angle2;

      B = angle3;

      b = includedSide;

      a = b * sin(_toRad(A)) / sin(_toRad(B));

      c = b * sin(_toRad(C)) / sin(_toRad(B));

    } else {

      B = angle1;

      C = angle2;

      A = angle3;

      a = includedSide;

      b = a * sin(_toRad(B)) / sin(_toRad(A));

      c = a * sin(_toRad(C)) / sin(_toRad(A));

    }

    final s = (a + b + c) / 2.0;

    final area = sqrt(max(0, s * (s - a) * (s - b) * (s - c)));

    return [TriangleSolution(a: a, b: b, c: c, A: A, B: B, C: C, area: area)];

  }

  List<TriangleSolution> _solveAAS(double? A, double? B, double? C, double? a, double? b, double? c) {

    double? AA = A;

    double? BB = B;

    double? CC = C;

    final angles = [AA, BB, CC].whereType<double>().toList();

    if (angles.length < 2) return [];

    AA ??= 180.0 - (BB ?? 0) - (CC ?? 0);

    BB ??= 180.0 - (AA ?? 0) - (CC ?? 0);

    CC ??= 180.0 - (AA ?? 0) - (BB ?? 0);

    if (AA <= 0 || BB <= 0 || CC <= 0) return [];

    if (a == null && b == null && c == null) return [];

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

  }) {

    if (angleDeg <= 0 || angleDeg >= 180) return [];

    if (oppositeSide <= 0 || otherSide <= 0) return [];

    final A = angleDeg;

    final sinB = otherSide * sin(_toRad(A)) / oppositeSide;

    if (sinB.abs() > 1.0) return [];

    final B1 = _toDeg(asin(sinB));

    final B2 = 180.0 - B1;

    final sols = <TriangleSolution>[];

    for (final B in [B1, B2]) {

      final C = 180.0 - A - B;

      if (C <= 0) continue;

      final c = oppositeSide * sin(_toRad(C)) / sin(_toRad(A));

      final a = oppositeSide;

      final b = otherSide;

      final s = (a + b + c) / 2.0;

      final area = sqrt(max(0, s * (s - a) * (s - b) * (s - c)));

      sols.add(TriangleSolution(a: a, b: b, c: c, A: A, B: B, C: C, area: area));

    }

    // De-dupe if only one unique solution

    if (sols.length == 2) {

      final s0 = sols[0];

      final s1 = sols[1];

      final same =

          (s0.C - s1.C).abs() < 1e-9 && (s0.c - s1.c).abs() < 1e-9;

      if (same) return [s0];

    }

    return sols;

  }

}
 



