//place holder to drop codeimport 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import '../../widgets/calc_button.dart';

enum FractionToolMode {
  fractionToDecimal,
  decimalToFraction,
  inchToMm,
  mmToInch,
}

class FractionDecimalPage extends StatefulWidget {
  const FractionDecimalPage({super.key});

  @override
  State<FractionDecimalPage> createState() => _FractionDecimalPageState();
}

class _FractionDecimalPageState extends State<FractionDecimalPage> {
  FractionToolMode mode = FractionToolMode.fractionToDecimal;

  final inputCtrl = TextEditingController(text: "");

  String resultPrimary = "—";
  String resultSecondary = "—";
  String warning = "";

  static const List<int> _allowedDenominators = [2, 4, 8, 16, 32, 64];

  @override
  void dispose() {
    inputCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final raw = inputCtrl.text.trim();

    setState(() {
      resultPrimary = "—";
      resultSecondary = "—";
      warning = "";

      if (raw.isEmpty) {
        warning = "Enter a value.";
        return;
      }

      switch (mode) {
        case FractionToolMode.fractionToDecimal:
          final inches = _parseInchFraction(raw);
          if (inches == null) {
            warning = "Enter a valid fraction like 7/16 or 3 7/16.";
            return;
          }
          resultPrimary = "${inches.toStringAsFixed(6)} in";
          resultSecondary = "${(inches * 25.4).toStringAsFixed(3)} mm";
          break;

        case FractionToolMode.decimalToFraction:
          final value = double.tryParse(raw);
          if (value == null) {
            warning = "Enter a valid decimal inch value.";
            return;
          }
          resultPrimary = "${_decimalToFractionString(value)} in";
          resultSecondary = "${(value * 25.4).toStringAsFixed(3)} mm";
          break;

        case FractionToolMode.inchToMm:
          final inches = _parseInchFraction(raw) ?? double.tryParse(raw);
          if (inches == null) {
            warning = "Enter inches as decimal or fraction.";
            return;
          }
          resultPrimary = "${(inches * 25.4).toStringAsFixed(3)} mm";
          resultSecondary = "${_decimalToFractionString(inches)} in";
          break;

        case FractionToolMode.mmToInch:
          final mm = double.tryParse(raw);
          if (mm == null) {
            warning = "Enter a valid mm value.";
            return;
          }
          final inches = mm / 25.4;
          resultPrimary = "${inches.toStringAsFixed(6)} in";
          resultSecondary = "${_decimalToFractionString(inches)} in";
          break;
      }
    });
  }

  double? _parseInchFraction(String input) {
    final s = input.trim();

    if (s.contains(' ')) {
      final parts = s.split(RegExp(r'\s+'));
      if (parts.length != 2) return null;

      final whole = double.tryParse(parts[0]);
      final frac = _parseSimpleFraction(parts[1]);
      if (whole == null || frac == null) return null;

      return whole >= 0 ? whole + frac : whole - frac;
    }

    if (s.contains('/')) {
      return _parseSimpleFraction(s);
    }

    return double.tryParse(s);
  }

  double? _parseSimpleFraction(String s) {
    final parts = s.split('/');
    if (parts.length != 2) return null;

    final nume = double.tryParse(parts[0].trim());
    final deno = double.tryParse(parts[1].trim());

    if (nume == null || deno == null || deno == 0) return null;
    return nume / deno;
  }

  String _decimalToFractionString(double value) {
    final negative = value < 0;
    final absValue = value.abs();

    final whole = absValue.floor();
    final frac = absValue - whole;

    if (frac < 0.000001) {
      return "${negative ? "-" : ""}$whole";
    }

    int bestNum = 0;
    int bestDen = 1;
    double bestError = double.infinity;

    for (final den in _allowedDenominators) {
      final num = (frac * den).round();
      final err = (frac - (num / den)).abs();
      if (err < bestError) {
        bestError = err;
        bestNum = num;
        bestDen = den;
      }
    }

    if (bestNum == 0) {
      return "${negative ? "-" : ""}$whole";
    }

    if (bestNum == bestDen) {
      return "${negative ? "-" : ""}${whole + 1}";
    }

    final reduced = _reduceFraction(bestNum, bestDen);
    final n = reduced.$1;
    final d = reduced.$2;

    final sign = negative ? "-" : "";

    if (whole == 0) {
      return "$sign$n/$d";
    }
    return "$sign$whole $n/$d";
  }

  (int, int) _reduceFraction(int n, int d) {
    int a = n.abs();
    int b = d.abs();
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    final gcd = a == 0 ? 1 : a;
    return (n ~/ gcd, d ~/ gcd);
  }

  Widget _modeButton(Color accent, String label, FractionToolMode value) {
    final selected = mode == value;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            mode = value;
            resultPrimary = "—";
            resultSecondary = "—";
            warning = "";
          });
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 2),
          backgroundColor: selected
              ? accent.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: accent, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  String get _inputLabel {
    switch (mode) {
      case FractionToolMode.fractionToDecimal:
        return "Fraction Input";
      case FractionToolMode.decimalToFraction:
        return "Decimal Inches";
      case FractionToolMode.inchToMm:
        return "Inches Input";
      case FractionToolMode.mmToInch:
        return "Millimeters";
    }
  }

  String get _hintText {
    switch (mode) {
      case FractionToolMode.fractionToDecimal:
        return "ex: 7/16 or 3 7/16";
      case FractionToolMode.decimalToFraction:
        return "ex: 3.4375";
      case FractionToolMode.inchToMm:
        return "ex: 1.25 or 1 1/4";
      case FractionToolMode.mmToInch:
        return "ex: 31.75";
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: "Fraction / Decimal",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Quick shop conversion tool for fractions, decimal inches, and mm.",
              style: TextStyle(color: accent.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _modeButton(
                  accent,
                  "Frac → Dec",
                  FractionToolMode.fractionToDecimal,
                ),
                const SizedBox(width: 8),
                _modeButton(
                  accent,
                  "Dec → Frac",
                  FractionToolMode.decimalToFraction,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _modeButton(accent, "In → mm", FractionToolMode.inchToMm),
                const SizedBox(width: 8),
                _modeButton(accent, "mm → In", FractionToolMode.mmToInch),
              ],
            ),

            const SizedBox(height: 18),

            terminalNumberField(
              accent: accent,
              label: _inputLabel,
              hint: _hintText,
              controller: inputCtrl,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: terminalCalcButton(accent: accent, onPressed: _calculate),
            ),

            const SizedBox(height: 18),

            if (warning.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  warning,
                  style: TextStyle(
                    color: accent.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            terminalResultCard(
              accent: accent,
              lines: [
                "Primary: $resultPrimary",
                "Secondary: $resultSecondary",
                "Fraction rounding: nearest 1/64",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
