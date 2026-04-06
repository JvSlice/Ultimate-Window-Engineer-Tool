import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import 'ohms_law_page.dart';
import 'power_law_page.dart';
import 'electrical_reference_page.dart';

class ElectricalToolsPage extends StatelessWidget {
  const ElectricalToolsPage({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget terminalButton(
      BuildContext context,
      String label,
      VoidCallback onPressed,
    ) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
        child: SizedBox(
          width: double.infinity,
          height: size.height * 0.09,
          child: OutlinedButton(
            onPressed: onPressed,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return TerminalScaffold(
      title: 'Electrical Tools',
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              terminalButton(
                context,
                'Ohm’s Law Calculator',
                () => openPage(context, const OhmsLawPage()),
              ),
              terminalButton(
                context,
                'Power Law Calculator',
                () => openPage(context, const PowerLawPage()),
              ),
              terminalButton(
                context,
                'Electrical Reference',
                () => openPage(context, const ElectricalReferencePage()),
              ),
              const Spacer(),
              Text(
                'Quick electrical math and basic reference values for field and design work.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
