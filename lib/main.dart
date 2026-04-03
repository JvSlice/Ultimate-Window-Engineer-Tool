import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/window_testing_tools_page.dart';
import 'terminal_scaffold.dart';
import 'convert_it_page.dart';
import 'fabricate_it_page.dart';
import 'reference/reference_home_page.dart';
import 'settings_page.dart';
import 'app_theme.dart';
import 'fun_links_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = AppThemeController();
  await themeController.load();
  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final AppThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeController.buildTerminalTheme(
            themeController.accentColor,
          ),
          home: MainMenuPage(themeController: themeController),
        );
      },
    );
  }
}

class MainMenuPage extends StatelessWidget {
  final AppThemeController themeController;
  const MainMenuPage({super.key, required this.themeController});

  void openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final accent = themeController.accentColor;

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
          style: OutlinedButton.styleFrom(
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

    Widget bottomCornerButton({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
    }) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: size.width * 0.02),
        label: Text(
          label,
          style: TextStyle(fontSize: size.width * 0.016),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: size.width * 0.002),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.02,
            vertical: size.height * 0.012,
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: "Ultimate Window Engineer Tool",
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
                  openPage(context, ReferenceHomePage());
                }),
                terminalButton(context, "Window Testing Tools", () {
                  openPage(context, WindowTestingToolsPage());
                }),
              ],
            ),
          ),

          SizedBox(height: verticalSpacing),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              bottomCornerButton(
                icon: Icons.videogame_asset_outlined,
                label: "FUN?",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FunLinksPage(),
                    ),
                  );
                },
              ),
              bottomCornerButton(
                icon: Icons.settings,
                label: "settings",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SettingsPage(themeController: themeController),
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: verticalSpacing),
        ],
      ),
    );
  }
}
