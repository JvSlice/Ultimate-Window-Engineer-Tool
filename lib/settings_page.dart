import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'terminal_scaffold.dart';

class SettingsPage extends StatelessWidget {
  final AppThemeController themeController;
  const SettingsPage({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final accent = themeController.accentColor;

        return TerminalScaffold(
          title: 'Settings',
          
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Accent Color",
                  style: TextStyle(
                    color: accent,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Live preview bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    border: Border.all(color: accent, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Current: ${themeController.accentChoice.name}",
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _accentButton(
                      label: "Green",
                      accent: accent,
                      selected:
                          themeController.accentChoice == AccentChoice.green,
                      onPressed: () =>
                          themeController.setAccentChoice(AccentChoice.green),
                    ),
                    _accentButton(
                      label: "Red",
                      accent: accent,
                      selected:
                          themeController.accentChoice == AccentChoice.red,
                      onPressed: () =>
                          themeController.setAccentChoice(AccentChoice.red),
                    ),
                    _accentButton(
                      label: "Yellow",
                      accent: accent,
                      selected:
                          themeController.accentChoice == AccentChoice.yellow,
                      onPressed: () =>
                          themeController.setAccentChoice(AccentChoice.yellow),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Text(
                  "If something doesn't change when you tap these, it means that part of the UI is still using a hard-coded color (like Colors.green) instead of themeController.accentColor.",
                  style: TextStyle(color: accent.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _accentButton({
    required String label,
    required Color accent,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? Colors.black : accent,
        backgroundColor: selected ? accent : Colors.transparent,
        side: BorderSide(color: accent, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
