import 'package:flutter/material.dart';

Widget terminalCalcButton({
  required Color accent,
  required VoidCallback onPressed,
  String label = "Calculate",
}) {
  return OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(Icons.calculate, color: accent),
    label: Text(label, style: TextStyle(color: accent)),
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: accent, width: 2),
    ),
  );
}
