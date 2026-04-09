import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';

class RiggingHardwareReferencePage extends StatelessWidget {
  const RiggingHardwareReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TerminalScaffold(
      title: 'Rigging Hardware Reference',
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section(context, 'Shackles', [
              'Anchor (bow) shackle: allows multi-direction loading.',
              'Chain (D) shackle: inline loading only.',
              'Never side-load shackles unless rated.',
              'Pin must always be fully engaged.',
              'Load should sit in the bow, not on the pin.',
            ]),

            _section(context, 'Eyebolts', [
              'Rated capacity drops drastically with angle.',
              'Shoulder eyebolts required for angular loading.',
              'Non-shoulder = vertical only.',
              'Always align shoulder flush with surface.',
              'Use washers/spacers if needed to align.',
            ]),

            _section(context, 'Hooks', [
              'Never tip-load a hook.',
              'Use safety latch hooks when possible.',
              'Load must sit in saddle.',
              'Avoid side loading unless rated.',
            ]),

            _section(context, 'Synthetic Slings', [
              'Inspect for cuts, burns, and stitching damage.',
              'Edges require protection.',
              'Capacity affected by knots and chokers.',
            ]),

            _section(context, 'Wire Rope', [
              'Watch for broken wires and kinks.',
              'Never shock load.',
              'Use proper clips (never saddle on dead end).',
            ]),

            _section(context, 'General Rules', [
              'Never exceed WLL.',
              'Always consider angle effects.',
              'Avoid shock loading.',
              'Verify center of gravity before lift.',
              'When in doubt, oversize the rigging.',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...items.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
