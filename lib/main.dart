import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/Tool_Four.dart';
import 'terminal_scaffold.dart';
import 'convert_it_page.dart';
import 'fabricate_it_page.dart';
import 'reference-it_page.dart';
import 'settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final accent = Colors.green;

    final horizontalPadding = size.width * 0.06;
    final verticalSpacing = size.height * 0.02;
    final gridSpacing = size.width * 0.02;

    Widget terminalButton(
      BuildContext context,
      String label,
      VoidCallback onPressed,
    ) {
      return SizedBox(
        width: double.infinity,
        height: size.height * 0.10,
        child: OutlinedButton(
          onPressed: onPressed,
          style:
              OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  accent.withValues(alpha: 0.08),
                ),
              ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.018,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: "Ultimate Window Engineer Tool",
      accent: accent,
      
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                  childAspectRatio: 1.6,
                  children: [
                    terminalButton(context, "Convert it", () {
                      openPage(context, const ConverItPage());
                    }),
                    terminalButton(context, "Fabricate it", () {
                      openPage(context, const FabricateItPage());
                    }),
                    terminalButton(context, "Reference it", () {
                      openPage(context, ReferenceitPage());
                    }),
                    terminalButton(context, "coming soon", () {
                      openPage(context, ToolFour());
                    }),
                    //terminalButton("coming soon 5"),
                    //terminalButton("coming soon 6"),
                  ],
                ),// grid view
              ),
              SizedBox(height: verticalSpacing),
              Align(
                alignment: Alignment.bottomRight,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  },
                  icon: Icon(Icons.settings, size: size.width * 0.02),
                  label: Text(
                    "settings",
                    style: TextStyle(fontSize: size.width * 0.016),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent,
                    side: BorderSide(color: accent, width: size.width * 0.002),
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing),
            ],
          ),
      // delete me
      // delete me
    ); // stack
  }
}

//scan line class was here
