import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/programing_reference_items.dart';

class ProgrammingReferenceCard extends StatelessWidget {
  const ProgrammingReferenceCard({super.key, required this.item});

  final ProgrammingReferenceItem item;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: accent.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        collapsedIconColor: accent,
        iconColor: accent,
        title: Text(
          item.title,
          style: textTheme.titleMedium?.copyWith(
            color: accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            item.summary,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _SectionLabel(label: 'When to use', accent: accent),
          Text(item.whenToUse, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          _SectionLabel(label: 'Common mistake', accent: accent),
          Text(item.commonMistake, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          _SectionLabel(label: 'Code example', accent: accent),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: accent.withValues(alpha: 0.45)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              item.code,
              style: TextStyle(
                color: accent,
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: item.code));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied')),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Code'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: accent.withValues(alpha: 0.35),
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(color: accent, fontSize: 11),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: TextStyle(color: accent, fontWeight: FontWeight.bold),
      ),
    );
  }
}
