import 'package:flutter/material.dart';

Widget terminalNumberField({
  required Color accent,
  required String label,
  required String hint,
  required TextEditingController controller,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: accent),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: accent.withValues(alpha: 0.4)),
            border: InputBorder.none,
          ),
        ),
      ),
    ],
  );
}

Widget terminalResultCard({
  required Color accent,
  required List<String> lines,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: accent.withValues(alpha: 0.7), width: 2),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.22),
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map((l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(l, style: TextStyle(color: accent)),
              ))
          .toList(),
    ),
  );
}
