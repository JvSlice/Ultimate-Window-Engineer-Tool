import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'splash_page.dart';
//commet to get code to rerun

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
          home: SplashPage(themeController: themeController),
        );
      },
    );
  }
}
