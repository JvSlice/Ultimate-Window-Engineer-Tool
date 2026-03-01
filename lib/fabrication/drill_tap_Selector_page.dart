import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/drill_index_data.dart';
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
    final accent = Theme.of(context).colorScheme.primary;

    return TerminalScaffold(
      title: 'Drill & Tap Selector',

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent, width: 2),
                boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
                ],
              ),
              child: DropdownButton<ThreadSpec>(
                value: selectedThread,
                isExpanded: true,
                hint: Text('Select Thread Size', style: TextStyle(color: accent)),
                dropdownColor: const Color(0xFF0B0F14),
                iconEnabledColor: accent,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white),
                items: _threadsForSystem(system)
                .map((t)=> DropdownMenuItem(
                  value: t,
                  child: Text(t.label, style: accent)),
                ))
                .toList(),
                onChanged: (value){
                  setState(() {
                    setState(() => selectedThread = value);
                  },
                  ),
            ),
                }
              )
            )
       
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
    final t = selectedThread;
    if (t == null) return const SizedBox.shrink();
    final targetIn = tapDrillDecimalInches(t, engagement);

    final drill = _closestDrill(
      targetIn,
      allowedKinds: allowedKindsForThread(t),
    );

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
  } // end of widget build
}

DrillSize _closestDrill(
  double targetInches, {
  required Set<DrillKind> allowedKinds,
}) {
  DrillSize? best;
  var bestDelta = double.infinity;
  for (final d in drillIndex) {
    if (!allowedKinds.contains(d.kind)) continue;
    final delta = (d.decimal - targetInches).abs();
    if (delta < bestDelta) {
      bestDelta = delta;
      best = d;
    }
  }
  return best!;
}

Set<DrillKind> allowedKindsForThread(ThreadSpec t) {
  switch (t.system) {
    case ThreadSystem.unc:
    case ThreadSystem.unf:
      return {DrillKind.fraction, DrillKind.letter, DrillKind.number};
    case ThreadSystem.metric:
      return {
        DrillKind.metric,
        DrillKind.fraction,
        DrillKind.letter,
        DrillKind.number,
      };
  }
}
