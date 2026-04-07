import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';
import 'material_models.dart';
import 'material_units.dart';

class MaterialDetailPage extends StatelessWidget {
  final MaterialSpec material;
  const MaterialDetailPage({super.key, required this.material});

  String _weldRatingText(WeldabilityRating r) {
    switch (r) {
      case WeldabilityRating.excellent:
        return "Excellent";
      case WeldabilityRating.good:
        return "Good";
      case WeldabilityRating.fair:
        return "Fair";
      case WeldabilityRating.poor:
        return "Poor";
      case WeldabilityRating.notRecommended:
        return "Not recommended";
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    final kgm3 = material.densityKgM3;
    final lbIn3 = kgm3ToLbIn3(kgm3);
    final lbFt3 = kgm3ToLbFt3(kgm3);

    final lines = <String>[
      "Category: ${material.category.name.toUpperCase()}",
      if (material.commonUse != null) "Common use: ${material.commonUse}",
      "",
      "Density:",
      "• ${fmt6(lbIn3)} lb/in³",
      "• ${fmt3(lbFt3)} lb/ft³",
      "• ${fmt3(kgm3)} kg/m³",
    ];

    // Strength
    if (material.strength != null) {
      final s = material.strength!;
      lines.add("");
      lines.add("Strength:");
      if (s.yieldPsi != null) {
        lines.add("• Yield: ${s.yieldPsi!.toStringAsFixed(0)} psi");
      }
      if (s.tensilePsi != null) {
        lines.add("• Tensile: ${s.tensilePsi!.toStringAsFixed(0)} psi");
      }
      if (s.yieldMpa != null) {
        lines.add("• Yield: ${s.yieldMpa!.toStringAsFixed(0)} MPa");
      }
      if (s.tensileMpa != null) {
        lines.add("• Tensile: ${s.tensileMpa!.toStringAsFixed(0)} MPa");
      }
    }

    // Hardness
    if (material.hardness != null) {
      final h = material.hardness!;
      lines.add("");
      lines.add("Hardness:");
      final scale = h.scale ?? "";
      if (h.min != null && h.max != null) {
        lines.add(
          "• ${h.min!.toStringAsFixed(0)}–${h.max!.toStringAsFixed(0)} $scale",
        );
      } else {
        lines.add("• —");
      }
    }

    // Machining
    if (material.machining != null) {
      final m = material.machining!;
      lines.add("");
      lines.add("Machining:");
      if (m.machinabilityPercent != null) {
        lines.add("• Machinability: ${m.machinabilityPercent}%");
      }
      if (m.sfmNotes != null) lines.add("• SFM: ${m.sfmNotes}");
      if (m.notes != null) lines.add("• Notes: ${m.notes}");
    }

    // Welding
    if (material.weldability != null) {
      lines.add("");
      lines.add("Welding:");
      lines.add("• Rating: ${_weldRatingText(material.weldability!)}");
      if (material.weldNotes != null) {
        lines.add("• Notes: ${material.weldNotes}");
      }
    }

    //Melting Temp
    
    if (material.melting != null) {
      lines.add("");
      lines.add("Melting:");
      lines.add("• ${_fmtTemp(material.melting!)}");
    }

    // Forge / Heat treat
    if (material.forge != null) {
      lines.add("");
      lines.add("Forge:");
      final f = material.forge!;
      if (f.forge != null) {
        lines.add("• Forge temp: ${_fmtTemp(f.forge!)}");
      }
      if (f.weldingHeat != null) {
        lines.add("• Forge weld: ${_fmtTemp(f.weldingHeat!)}");
      }
      if (f.notes != null) lines.add("• Notes: ${f.notes}");
    }

    if (material.heatTreat != null) {
      lines.add("");
      lines.add("Heat Treat:");
      final ht = material.heatTreat!;
      if (ht.normalize != null) {
        lines.add("• Normalize: ${_fmtTemp(ht.normalize!)}");
      }
      if (ht.austenitize != null) {
        lines.add("• Austenitize: ${_fmtTemp(ht.austenitize!)}");
      }
      if (ht.quench != null) lines.add("• Quench: (see notes)");
      if (ht.temper != null) lines.add("• Temper: ${_fmtTemp(ht.temper!)}");
      if (ht.notes != null) lines.add("• Notes: ${ht.notes}");
    }

    if (material.notes != null) {
      lines.add("");
      lines.add("Notes:");
      lines.add(material.notes!);
    }

    return TerminalScaffold(
      title: material.name,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [terminalResultCard(accent: accent, lines: lines)],
        ),
      ),
    );
  }

  String _fmtTemp(TempRange t) {
    final hasF = t.minF != null || t.maxF != null;
    final hasC = t.minC != null || t.maxC != null;

    String f = "";
    if (hasF) {
      final a = t.minF?.toString() ?? "—";
      final b = t.maxF?.toString() ?? "—";
      f = "$a–$b °F";
    }

    String c = "";
    if (hasC) {
      final a = t.minC?.toString() ?? "—";
      final b = t.maxC?.toString() ?? "—";
      c = "$a–$b °C";
    }

    if (hasF && hasC) return "$f ($c)";
    if (hasF) return f;
    if (hasC) return c;
    return "—";
  }
}

