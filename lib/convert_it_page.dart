import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/conversions/unit_conversions.dart';
import 'terminal_scaffold.dart';

class ConverItPage extends StatelessWidget {
  const ConverItPage({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    const accent = Colors.green;
    return const TerminalScaffold(
      title: 'Convert It',
      accent: accent,
      child: Padding(
        padding: const EdgeInsetsGeometry.all(24),
        child: ConvertItBody(accent: accent),
      ),
    );
  }
}

class ConvertItBody extends StatefulWidget {
  final Color accent;
  const ConvertItBody({super.key, required this.accent});

  @override
  State<ConvertItBody> createState() => _ConvertItBodyState();
}

class _ConvertItBodyState extends State<ConvertItBody> {
  final TextEditingController controller = TextEditingController();
  ConversionTypes selectedType = ConversionTypes.inchesToCm;
  Direction direction = Direction.to;

  String result = "";
  void convert() {
    final input = double.tryParse(controller.text);
    if (input == null) return;

    setState(() {
      result = performConversion(
        input: input,
        type: selectedType,
        direction: direction,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: widget.accent),
              decoration: InputDecoration(
                labelText: "Enter Value",
                labelStyle: TextStyle(color: widget.accent),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<ConversionTypes>(
              value: selectedType,
              dropdownColor: Colors.black,
              style: TextStyle(color: widget.accent),
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              items: ConversionTypes.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(conversionLabel(type)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => direction = Direction.to),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: widget.accent, width: 2),
                      backgroundColor: direction == Direction.to
                          ? widget.accent.withValues(alpha: 0.15)
                          : null,
                    ),
                    child: Text(
                      "To",
                      style: TextStyle(
                        color: widget.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => direction = Direction.from),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: widget.accent, width: 2),
                      backgroundColor: direction == Direction.from
                          ? widget.accent.withValues(alpha: 0.15)
                          : null,
                    ),
                    child: Text(
                      "From",
                      style: TextStyle(
                        color: widget.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: convert,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.accent, width: 2),
                  backgroundColor: widget.accent.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  "Run Conversion",
                  style: TextStyle(
                    color: widget.accent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Text(
              result,
              style: TextStyle(
                color: widget.accent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // this doesn't work 
            Opacity(opacity: .065,
            child: Text(
                'Convert Tool v0.1',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.accent,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
              ),

          ],

        ),
      ),
    ); // add stuff after this one
  }
}
