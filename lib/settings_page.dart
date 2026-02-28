import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'terminal_scaffold.dart';

class SettingsPage extends StatelessWidget {
  final AppThemeController themeController;
  const SettingsPage({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AnimatedBuilder(animation: themeController, builder: context _){
  
    final accent = themeController.accentColor;

    return  TerminalScaffold(
      title: 'Settings',
      accent: accent,
      child: Padding(padding: const Edgeinset.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Accent COlor",
          style: TextStyle(color: accent, fontSize: 20 fontWeight: FontWeight(w700),
          ),
          const SizedBox(height: 12),
          Container (
            height: 44,
            decoration: BoxDecoration(
              color accent.withValues(alpha: 0.15),
              border: Border.all(color: accent, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              "Current ${themeController.accentChoice.name}",
              style: TextStyle(color: accent,fontWeight: FontWeight(w600),
              ),
            ),

          const SizedBox(height: 16),
          wrap(
            spacing: 12,
            runSpacing: 12,
            children:[
              _accentButton(
                label:"Green",
                accent: accent,
                selected: themeController.accentChoice == AccentChoice.green,
                onPressed:() => themeController.setAccentChoice(AccentChoice.green),
              ),
              _accentButton(
                label: "red",
                accent: accent,
                selected: themeController.accentChoice == AccentChoice.red,
                onPressed: () => themeController.setAccentChoice(AccentChoice.red),
              ),
              _accentButton (
                label: "Yellow",
                accent: accent,
                selected: themeController.accentChoice == AccentChoice.yellow,
                onPressed: () => themeController.setAccentChoice(AccentChoice.yellow),
              ),
            ],
          ),
          const SizedBox( height: 24),
          Text("If nothing happens"),
          style: TextStyle(color: accent.withValues(alpha: 0.85)),

          ),
        ],
          ),
      ),
    );
    },
    );
  }


