import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';
import 'thread_data.dart';
import 'tap_drill_calc.dart';

class DrillTapSelectorPage extends StatefulWidget {
  const DrillTapSelectorPage({super.key});

  @override
  State<DrillTapSelectorPage> createState() => _DrillTapSelectorPageState();
}

class _DrillTapSelectorPageState extends State<DrillTapSelectorPage> {
  ThreadSystem system = ThreadSystem.unc;
  double engagement = 0.75;

  ThreadSpec? selectedThread;

  @override
  Widget build(BuildContext context) {
    const accent = Colors.green;

    return TerminalScaffold(
      title: 'Drill & Tap Selector',
      accent: accent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // system selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ThreadSystem.values.map((s) {
                final selected = system == s;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          system = s;
                          selectedThread = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent, width: 2),
                        backgroundColor: selected
                            ? accent.withValues(alpha: 0.80)
                            : Colors.transparent,
                      ),
                      child: Text(
                        s.name.toUpperCase(),
                        style: TextStyle(color: accent),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // thread dropdown
            DropdownButton<ThreadSpec>(
              value: selectedThread,
              hint: const Text('Select Thread Size'),
              style: TextStyle(color: Colors.black),
              items: _threadsForSystem(system)
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedThread = value;
                });
              },
            ),
            //Engagement Selector
            Row(
              children: [0.75, 0.65, 0.50].map((e) {
                final selected = engagement == e;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          engagement = e;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent, width: 2),
                        backgroundColor: selected
                            ? accent.withValues(alpha: 0.80)
                            : Colors.transparent,
                      ),
                      child: Text(
                        '${(e * 100).toInt()}%',
                        style: TextStyle(color: accent.withValues(alpha: 0.80)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // result
            if (selectedThread != null) _buildResult(accent),
          ],
        ),
      ),
    );
  }

  List<ThreadSpec> _threadsForSystem(ThreadSystem s) {
    switch (s) {
      case ThreadSystem.unc:
        return commonUNC;
      case ThreadSystem.unf:
        return commonUNF;
      case ThreadSystem.metric:
        return commonMetric;
    }
  }

  Widget _buildResult(Color accent) {
    final decimal = tapDrillDecimalInches(selectedThread!, engagement);

    final drill = closestDrill(decimal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Drill:',
          style: TextStyle(
            fontSize: 18,
            color: accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          drill.name,
          style: TextStyle(fontSize: 16, color: accent.withValues(alpha: 0.80)),
        ),
        Text(
          '${drill.decimal.toStringAsFixed(4)} in',
          style: TextStyle(fontSize: 16, color: accent.withValues(alpha: 0.80)),
        ),
        Text(
          '${drill.metric.toStringAsFixed(3)} mm',
          style: TextStyle(fontSize: 16, color: accent.withValues(alpha: 0.80)),
        ),
      ],
    );
  }
}
