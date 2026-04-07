import 'package:flutter/material.dart';

import 'search_models.dart';

class MainMenuSearchOverlay extends StatelessWidget {
  final Color accent;
  final Size size;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<SearchHit> hits;
  final VoidCallback onClose;

  const MainMenuSearchOverlay({
    super.key,
    required this.accent,
    required this.size,
    required this.controller,
    required this.focusNode,
    required this.hits,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width > 900 ? 760 : size.width * 0.92,
      constraints: BoxConstraints(
        maxHeight: size.height * 0.72,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: accent, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.search, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  style: TextStyle(color: accent),
                  decoration: InputDecoration(
                    hintText: 'Search tools or type: 25 psi to psf',
                    hintStyle: TextStyle(
                      color: accent.withValues(alpha: 0.40),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) {
                    if (hits.isNotEmpty) {
                      hits.first.onTap();
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: accent.withValues(alpha: 0.25), height: 1),
          const SizedBox(height: 8),
          Flexible(
            child: hits.isEmpty
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 12,
                      ),
                      child: Text(
                        controller.text.trim().isEmpty
                            ? 'Try: tap drill, e1300, awg 12, torque, glass, 25 psi to psf'
                            : 'No results found',
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: hits.length,
                    separatorBuilder: (_, _) =>
                        Divider(color: accent.withValues(alpha: 0.12), height: 1),
                    itemBuilder: (context, index) {
                      final hit = hits[index];
                      final isInstant = hit.kindLabel == 'instant';

                      return InkWell(
                        onTap: hit.onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isInstant
                                    ? Icons.bolt_outlined
                                    : Icons.subdirectory_arrow_right,
                                color: accent.withValues(alpha: 0.78),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hit.title,
                                      style: TextStyle(
                                        color: accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      hit.subtitle,
                                      style: TextStyle(
                                        color: accent.withValues(alpha: 0.60),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
