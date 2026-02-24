import 'package:flutter/material.dart';
import '../terminal_scaffold.dart';
import '../drill_index_data.dart'; // wheni move index remove . .

class DrillIndexPage extends StatefulWidget {
  const DrillIndexPage({super.key});

  @override
  State<DrillIndexPage> createState() => _DrillIndexPageState();
}

class _DrillIndexPageState extends State<DrillIndexPage> {
  DrillFilter filter = DrillFilter.all;
  String query = "";
  // 5 sorted and filtered gitter
  List<DrillSize> get visibleDrills {
    final sorted = [...drillIndex];
    sorted.sort((a, b) => a.decimal.compareTo(b.decimal));

    Iterable<DrillSize> result = sorted;

    if (filter != DrillFilter.all) {
      DrillKind match;
      switch (filter) {
        case DrillFilter.fraction:
          match = DrillKind.fraction;
          break;
        case DrillFilter.letter:
          match = DrillKind.letter;
          break;
        case DrillFilter.number:
          match = DrillKind.number;
          break;
        case DrillFilter.metric:
          match = DrillKind.metric;
          break;
        case DrillFilter.all:
          return sorted;
      }
      result = result.where((d) => d.kind == match);
    }
    if (query.isNotEmpty) {
      result = result.where(
        (d) =>
            d.name.toLowerCase().contains(query.toLowerCase()) ||
            d.decimal.toString().contains(query) ||
            d.metric.toString().contains(query),
      );
    }
    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Colors.green;
    final filtered = drillIndex.where((d) {
      return d.name.toLowerCase().contains(query.toLowerCase()) ||
          d.decimal.toString().contains(query);
    }).toList();
    return TerminalScaffold(
      title: "Drill Index",
      accent: accent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                //serach
                TextField(
                  style: TextStyle(color: accent),
                  decoration: InputDecoration(
                    labelText: "Search Drill Size",
                    labelStyle: TextStyle(color: accent),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accent, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accent, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // segimented controll for table
                Row(
                  children: DrillFilter.values.map((f) {
                    final selected = filter == f;
                    return Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => filter = f);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: accent, width: 2),
                          backgroundColor: selected
                              ? accent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            filterLabel(f),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // table
                Expanded(
                  child: ListView.builder(
                    itemCount: visibleDrills.length,
                    itemBuilder: (context, index) {
                      final drill = visibleDrills[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: accent),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              drill.name,
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  drill.decimal.toStringAsFixed(4),
                                  style: TextStyle(color: accent),
                                ),
                                Text(
                                  "${drill.metric.toStringAsFixed(3)} mm",
                                  style: TextStyle(
                                    color: accent.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
