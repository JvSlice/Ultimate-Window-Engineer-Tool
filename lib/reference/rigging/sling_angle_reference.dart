import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class RiggingAngleChartPage extends StatelessWidget {
  const RiggingAngleChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final angles = [
      {'angle': 90, 'factor': 1.0},
      {'angle': 60, 'factor': 1.15},
      {'angle': 45, 'factor': 1.41},
      {'angle': 30, 'factor': 2.0},
    ];

    return TerminalScaffold(
      title: 'Angle Reference',
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: angles.map((a) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text('${a['angle']}°'),
                subtitle: Text('Load Increase: ${a['factor']}x'),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
