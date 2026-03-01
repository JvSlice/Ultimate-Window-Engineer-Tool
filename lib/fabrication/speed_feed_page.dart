import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';
import '../data/materials.dart';
import '../data/material_library.dart';

enum ToolType { hss, carbide }

enum Operation { drill, mill }

class SpeedFeedPage extends StatefulWidget {
  const SpeedFeedPage({super.key});

  @override
  State<SpeedFeedPage> createState() => _SpeedFeedPageState();
}

class _SpeedFeedPageState extends State<SpeedFeedPage> {
  Operation op = Operation.drill;
  ToolType toolType = ToolType.hss;

  MaterialSpec material = materialLibrary.first;
  double diameterIn = 0.25; // default 1/4"
  int flutes = 2; // milling
  double chiploadIn = 0.002; // milling (in/tooth)

  late final TextEditingController _diameterController;
  late final TextEditingController _flutesController;
  late final TextEditingController _chiploadController;

  @override
  void initState() {
    super.initState();

    _diameterController = TextEditingController(
      text: diameterIn.toStringAsFixed(4),
    );
    _flutesController = TextEditingController(text: flutes.toStringAsFixed(2));
    _chiploadController = TextEditingController(
      text: chiploadIn.toStringAsFixed(4),
    );
  }

  @override
  void dispose() {
    _diameterController.dispose();
    _flutesController.dispose();
    _chiploadController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    final sfm = _sfmFor(material, op, toolType);
    final rpm = _rpmFromSfm(sfm, diameterIn);

    final drillIpr = _drillIprForDiameter(diameterIn);
    final drillFeedIpm = rpm * drillIpr;

    final millFeedIpm = rpm * chiploadIn * flutes;

    return TerminalScaffold(
      title: "Speed & Feed",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _sectionTitle("Operation", accent),
            const SizedBox(height: 8),
            Row(
              children: Operation.values.map((o) {
                final selected = op == o;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () => setState(() => op = o),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent, width: 2),
                        backgroundColor: selected
                            ? accent.withValues(alpha: 0.25)
                            : Colors.transparent,
                      ),
                      child: Text(
                        o == Operation.drill ? "DRILL" : "MILL",
                        style: TextStyle(color: accent),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            _sectionTitle("Tool", accent),
            const SizedBox(height: 8),
            Row(
              children: ToolType.values.map((t) {
                final selected = toolType == t;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () => setState(() => toolType = t),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent, width: 2),
                        backgroundColor: selected
                            ? accent.withValues(alpha: 0.25)
                            : Colors.transparent,
                      ),
                      child: Text(
                        t == ToolType.hss ? "HSS" : "CARBIDE",
                        style: TextStyle(color: accent),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            _sectionTitle("Material", accent),
            const SizedBox(height: 8),

            // Dropdown styled like your terminal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: accent.withValues(alpha: 0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<MaterialSpec>(
                  value: material,
                  dropdownColor: Colors.black,
                  iconEnabledColor: accent,
                  style: TextStyle(color: accent),
                  items: materialLibrary
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.name, style: TextStyle(color: accent)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => material = v ?? material),
                ),
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle("Diameter (in)", accent),
            const SizedBox(height: 8),
            _numberField(
              accent: accent,
              controller: _diameterController,
              //initial: diameterIn.toString(),
              onChanged: (s) {
                final v = double.tryParse(s);
                if (v != null && v > 0) setState(() => diameterIn = v);
              },
              hint: "e.g. 0.2500",
            ),

            if (op == Operation.mill) ...[
              const SizedBox(height: 20),
              _sectionTitle("Milling Inputs", accent),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      accent: accent,
                      controller: _flutesController,
                      //initial: flutes.toString(),
                      onChanged: (s) {
                        final v = int.tryParse(s);
                        if (v != null && v > 0) setState(() => flutes = v);
                      },
                      hint: "Flutes",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      accent: accent,
                      controller: _chiploadController,
                      //initial: chiploadIn.toString(),
                      onChanged: (s) {
                        final v = double.tryParse(s);
                        if (v != null && v > 0) setState(() => chiploadIn = v);
                      },
                      hint: "Chipload (in/tooth)",
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
            _sectionTitle("Results", accent),
            const SizedBox(height: 8),

            _resultCard(
              accent: accent,
              lines: [
                "SFM: ${sfm.toStringAsFixed(0)}",
                "RPM: ${rpm.toStringAsFixed(0)}",
                if (op == Operation.drill)
                  "Feed: ${drillFeedIpm.toStringAsFixed(1)} IPM (IPR ${drillIpr.toStringAsFixed(4)})",
                if (op == Operation.mill)
                  "Feed: ${millFeedIpm.toStringAsFixed(1)} IPM",
              ],
            ),

            const SizedBox(height: 16),
            Text(
              "Note: These are starting values. Adjust for rigidity, tool length, coolant, and chatter.",
              style: TextStyle(color: accent.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  double _sfmFor(MaterialSpec m, Operation o, ToolType t) {
    final carbide = t == ToolType.carbide;
    switch (o) {
      case Operation.drill:
        return carbide ? m.sfmCarbideDrill : m.sfmHssDrill;
      case Operation.mill:
        return carbide ? m.sfmCarbideMill : m.sfmHssMill;
    }
  }

  double _rpmFromSfm(double sfm, double diaIn) {
    // RPM = (SFM * 3.82) / D(in)
    return (sfm * 3.82) / diaIn;
  }

  double _drillIprForDiameter(double diaIn) {
    // Simple, manual-friendly starting points
    if (diaIn <= 0.125) return 0.0015;
    if (diaIn <= 0.250) return 0.0030;
    if (diaIn <= 0.375) return 0.0045;
    if (diaIn <= 0.500) return 0.0060;
    return 0.0080;
  }

  Widget _sectionTitle(String text, Color accent) {
    return Text(
      text,
      style: TextStyle(
        color: accent,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _resultCard({required Color accent, required List<String> lines}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.7), width: 2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines
            .map(
              (l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(l, style: TextStyle(color: accent)),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _numberField({
    required Color accent,
    required TextEditingController controller,

    required void Function(String) onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
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
        onChanged: onChanged,
      ),
    );
  }
}
