import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class RiggingHitchReferencePage extends StatelessWidget {
  const RiggingHitchReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TerminalScaffold(
      title: 'Hitch Types',
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tile(
              context,
              'Vertical Hitch',
              'Multiplier: 1.0x',
              'Straight lift. Full rated capacity.',
            ),
            _tile(
              context,
              'Choker Hitch',
              'Multiplier: ~0.8x',
              'Reduces capacity. Tightens around load.',
            ),
            _tile(
              context,
              'Basket Hitch',
              'Multiplier: 2.0x (ideal)',
              'Doubles capacity when evenly loaded.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    String multiplier,
    String desc,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(title: Text(title), subtitle: Text('$multiplier\n$desc')),
    );
  }
}
