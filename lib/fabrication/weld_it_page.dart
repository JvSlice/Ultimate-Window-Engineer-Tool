import 'package:flutter/material.dart';
import 'package:ultimate_window_engineer_tool/terminal_scaffold.dart';

class WeldIt extends StatelessWidget {
  const WeldIt({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final accent = Theme.of(context).colorScheme.primary;
    return TerminalScaffold(title: "Weld It",
    child: Center(
      child: Text("Coming Soon", style: TextStyle(color: accent, fontSize: 20),
      ),
    ),
     );
  }
}
