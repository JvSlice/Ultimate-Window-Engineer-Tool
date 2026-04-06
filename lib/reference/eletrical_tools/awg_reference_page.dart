import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class AwgReferencePage extends StatelessWidget {
  const AwgReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = <Map<String, String>>[
      {'awg': '24', 'diameter': '0.0201"', 'area': '0.205 mm²', 'common': 'Small signal / control'},
      {'awg': '22', 'diameter': '0.0253"', 'area': '0.326 mm²', 'common': 'Light control wiring'},
      {'awg': '20', 'diameter': '0.0320"', 'area': '0.519 mm²', 'common': 'Low current circuits'},
      {'awg': '18', 'diameter': '0.0403"', 'area': '0.823 mm²', 'common': 'Control / low power'},
      {'awg': '16', 'diameter': '0.0508"', 'area': '1.31 mm²', 'common': 'General low voltage'},
      {'awg': '14', 'diameter': '0.0641"', 'area': '2.08 mm²', 'common': 'Branch / moderate load'},
      {'awg': '12', 'diameter': '0.0808"', 'area': '3.31 mm²', 'common': 'Heavier branch circuits'},
      {'awg': '10', 'diameter': '0.1019"', 'area': '5.26 mm²', 'common': 'Higher current load'},
      {'awg': '8', 'diameter': '0.1285"', 'area': '8.37 mm²', 'common': 'Feeders / larger load'},
      {'awg': '6', 'diameter': '0.1620"', 'area': '13.3 mm²', 'common': 'High current circuits'},
      {'awg': '4', 'diameter': '0.2043"', 'area': '21.2 mm²', 'common': 'Large feeders'},
      {'awg': '2', 'diameter': '0.2576"', 'area': '33.6 mm²', 'common': 'Very high current'},
      {'awg': '1/0', 'diameter': '0.3249"', 'area': '53.5 mm²', 'common': 'Battery / feeder cable'},
    ];

    Widget refCard(String title, String body) {
      return Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(body),
              ],
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: 'AWG Quick Reference',
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            refCard(
              'Notes',
              'This is a quick field reference only.\n'
              'Final conductor sizing depends on code, insulation, temperature rating, bundling, distance, and voltage drop.',
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('AWG')),
                      DataColumn(label: Text('Diameter')),
                      DataColumn(label: Text('Area')),
                      DataColumn(label: Text('Common Use')),
                    ],
                    rows: rows.map((row) {
                      return DataRow(
                        cells: [
                          DataCell(Text(row['awg']!)),
                          DataCell(Text(row['diameter']!)),
                          DataCell(Text(row['area']!)),
                          DataCell(Text(row['common']!)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            refCard(
              'General Rule of Thumb',
              'Smaller AWG number = larger wire.\n'
              'Larger wire generally carries more current and has less voltage drop.',
            ),
            refCard(
              'Good Future Upgrade',
              'Later we can make this page searchable or add:\n'
              '- resistance per 1000 ft\n'
              '- typical ampacity columns\n'
              '- voltage drop calculator\n'
              '- copper vs aluminum data',
            ),
          ],
        ),
      ),
    );
  }
}
