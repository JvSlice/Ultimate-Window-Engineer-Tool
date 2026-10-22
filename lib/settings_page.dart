import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'analytics/analytics_service.dart';
import 'release_notes/about_uwe_page.dart';
import 'terminal_scaffold.dart';

class SettingsPage extends StatefulWidget {
  final AppThemeController themeController;
  const SettingsPage({super.key, required this.themeController});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _analytics = AnalyticsService.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.themeController, _analytics]),
      builder: (context, _) {
        final accent = widget.themeController.accentColor;

        return TerminalScaffold(
          title: 'Settings',

          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "Appearance / Theme",
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
                  "Current: ${_choiceLabel(widget.themeController.accentChoice)}",
                  style: TextStyle(color: accent, fontWeight: FontWeight.w600),
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
                        widget.themeController.accentChoice ==
                        AccentChoice.green,
                    onPressed: () => widget.themeController.setAccentChoice(
                      AccentChoice.green,
                    ),
                  ),
                  _accentButton(
                    label: "Red",
                    accent: accent,
                    selected:
                        widget.themeController.accentChoice == AccentChoice.red,
                    onPressed: () => widget.themeController.setAccentChoice(
                      AccentChoice.red,
                    ),
                  ),
                  _accentButton(
                    label: "Yellow",
                    accent: accent,
                    selected:
                        widget.themeController.accentChoice ==
                        AccentChoice.yellow,
                    onPressed: () => widget.themeController.setAccentChoice(
                      AccentChoice.yellow,
                    ),
                  ),
                  _accentButton(
                    label: "Black & Copper",
                    accent: accent,
                    selected:
                        widget.themeController.accentChoice ==
                        AccentChoice.blackCopper,
                    onPressed: () => widget.themeController.setAccentChoice(
                      AccentChoice.blackCopper,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                "Privacy",
                style: TextStyle(
                  color: accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.06),
                  border: Border.all(color: accent, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Anonymous usage analytics'),
                      subtitle: Text(
                        _analytics.providerConfigured
                            ? 'Collects anonymous app usage only. Does not collect names, emails, project names, dimensions, calculations, or user-entered values.'
                            : 'Analytics is currently disabled because no provider key is configured for this build.',
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.74),
                          height: 1.35,
                        ),
                      ),
                      value: _analytics.analyticsEnabled,
                      activeThumbColor: accent,
                      onChanged: _analytics.initialized
                          ? (value) {
                              _analytics.setAnalyticsEnabled(value);
                            }
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Anonymous analytics helps prioritize improvements by showing which tools, reference pages, conversions, and search flows are used. Search text is not sent; only query length, token count, and result counts are recorded.',
                      style: TextStyle(
                        color: accent.withValues(alpha: 0.78),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                "About",
                style: TextStyle(
                  color: accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutUwePage()),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text("About UWE"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ],
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
        foregroundColor: selected
            ? widget.themeController.accentForegroundColor
            : accent,
        backgroundColor: selected
            ? widget.themeController.selectionColor
            : Colors.transparent,
        side: BorderSide(color: accent, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  String _choiceLabel(AccentChoice choice) => switch (choice) {
    AccentChoice.green => 'Green',
    AccentChoice.red => 'Red',
    AccentChoice.yellow => 'Yellow',
    AccentChoice.blackCopper => 'Black & Copper',
  };
}
