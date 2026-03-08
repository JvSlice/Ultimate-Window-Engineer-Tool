import 'package:flutter/material.dart';
import '../../terminal_scaffold.dart';
import '../../widgets/terminal_fields.dart';

enum PerformanceClass { r, lc, cw, aw }

enum WindowType {
  fixed,
  operable,
  terraceDoor,
}

class TestProcedureProfile {
  final String title;
  final String dpNotes;
  final String waterNotes;
  final String airNotes;
  final String lifeCycleNotes;
  final String thermalCycleNotes;
  final List<String> steps;
  final String disclaimer;

  const TestProcedureProfile({
    required this.title,
    required this.dpNotes,
    required this.waterNotes,
    required this.airNotes,
    required this.lifeCycleNotes,
    required this.thermalCycleNotes,
    required this.steps,
    required this.disclaimer,
  });
}

class TestSequenceReferencePage extends StatefulWidget {
  const TestSequenceReferencePage({super.key});

  @override
  State<TestSequenceReferencePage> createState() =>
      _TestSequenceReferencePageState();
}

class _TestSequenceReferencePageState extends State<TestSequenceReferencePage> {
  PerformanceClass selectedClass = PerformanceClass.cw;
  WindowType selectedType = WindowType.fixed;

  late final Map<String, TestProcedureProfile> profiles = {
    _key(PerformanceClass.r, WindowType.fixed): const TestProcedureProfile(
      title: "R • Fixed",
      dpNotes:
          "Use the governing standard for minimum DP / PG requirements. Fixed units generally skip operating-force style checks but still require structural, air, and water review.",
      waterNotes:
          "Water requirement depends on the governing class / PG basis and current standard reference.",
      airNotes:
          "Confirm applicable air infiltration limit for the product type and standard edition being used.",
      lifeCycleNotes:
          "Not typically the main concern for fixed products, but confirm whether your internal procedure or test lab matrix requires additional cycling-related checks.",
      thermalCycleNotes:
          "Apply only where required by the relevant program, product category, or internal qualification plan.",
      steps: [
        "Confirm specimen configuration, size, and glazing details.",
        "Verify gateway size / product-type basis being used for qualification.",
        "Run air infiltration test per required pressure basis.",
        "Run water penetration test at the required pressure basis.",
        "Run design pressure structural test.",
        "Measure deflection and compare to allowable criteria.",
        "Measure permanent set after recovery period.",
        "Run overload / proof load if required.",
        "Inspect for failure, distress, disengagement, breakage, or leakage.",
        "Document final pass/fail against governing requirements.",
      ],
      disclaimer:
          "Reference workflow only. Final qualification depends on governing standard, edition, size, and lab procedure.",
    ),

    _key(PerformanceClass.r, WindowType.operable): const TestProcedureProfile(
      title: "R • Casement / Awning / Hopper",
      dpNotes:
          "Use governing standard / PG basis for minimum DP. Operable products typically require both performance testing and operating-function checks.",
      waterNotes:
          "Use the required water basis for the product class and edition being followed.",
      airNotes:
          "Confirm applicable air infiltration requirement for operable windows under the governing standard.",
      lifeCycleNotes:
          "Life cycle / repeated operation is commonly relevant for operable products and should be included where required.",
      thermalCycleNotes:
          "Thermal cycle may apply depending on the qualification path or program.",
      steps: [
        "Confirm specimen configuration, hardware, and operating mode.",
        "Verify gateway size / class basis.",
        "Check operating function before environmental/performance sequence if required.",
        "Run air infiltration test.",
        "Run water penetration test.",
        "Run design pressure structural test.",
        "Measure deflection and permanent set.",
        "Run overload / proof load if required.",
        "Perform life cycle / operating cycle testing where required.",
        "Re-check operation, lockup, and hardware performance.",
        "Document pass/fail results and observations.",
      ],
      disclaimer:
          "Reference workflow only. Product-specific operating requirements vary by standard and product family.",
    ),

    _key(PerformanceClass.r, WindowType.terraceDoor): const TestProcedureProfile(
      title: "R • Terrace Door",
      dpNotes:
          "Use governing standard / PG basis for minimum DP and structural checks. Doors often have additional hardware and operation considerations.",
      waterNotes:
          "Confirm required water basis and threshold/sill evaluation details.",
      airNotes:
          "Use the applicable door air infiltration requirement under the standard being followed.",
      lifeCycleNotes:
          "Operation / cycle checks are commonly important for doors and should be included where required.",
      thermalCycleNotes:
          "Thermal cycle may apply depending on qualification program or product type.",
      steps: [
        "Confirm specimen size, threshold details, and hardware configuration.",
        "Verify class / size basis and required qualification path.",
        "Run air infiltration test.",
        "Run water penetration test.",
        "Run design pressure structural test.",
        "Measure deflection and permanent set.",
        "Run overload / proof load if required.",
        "Run operational / life cycle checks where required.",
        "Re-check lock, latch, rollers / hinges, and function.",
        "Document all pass/fail criteria and observations.",
      ],
      disclaimer:
          "Reference workflow only. Door qualification often includes additional functional checks.",
    ),

    _key(PerformanceClass.lc, WindowType.fixed): const TestProcedureProfile(
      title: "LC • Fixed",
      dpNotes:
          "LC class generally demands stronger performance than R, but final DP / PG requirements must come from the governing standard and gateway-size basis.",
      waterNotes:
          "Use required water basis for LC qualification under the applicable standard edition.",
      airNotes:
          "Confirm applicable air infiltration limit for fixed LC products.",
      lifeCycleNotes:
          "Usually limited for fixed products unless imposed by internal program requirements.",
      thermalCycleNotes:
          "Apply where required by qualification program.",
      steps: [
        "Confirm specimen and gateway-size basis.",
        "Run air infiltration test.",
        "Run water penetration test.",
        "Run design pressure structural test.",
        "Measure deflection.",
        "Measure permanent set after recovery.",
        "Run overload / proof load if required.",
        "Inspect for failure or distress.",
        "Document final results.",
      ],
      disclaimer:
          "Reference workflow only. Use actual LC qualification requirements from the governing standard.",
    ),

    _key(PerformanceClass.lc, WindowType.operable): const TestProcedureProfile(
      title: "LC • Casement / Awning / Hopper",
      dpNotes:
          "Use LC product requirements from the governing standard and gateway-size basis.",
      waterNotes:
          "Confirm required LC water basis and test setup.",
      airNotes:
          "Confirm operable air infiltration limits for the applicable product type.",
      lifeCycleNotes:
          "Life cycle / repetitive operation checks are commonly relevant.",
      thermalCycleNotes:
          "Include where required by program or product family.",
      steps: [
        "Confirm specimen, hardware, and operating configuration.",
        "Verify class and gateway-size basis.",
        "Check operating function.",
        "Run air infiltration test.",
        "Run water penetration test.",
        "Run design pressure structural test.",
        "Measure deflection and permanent set.",
        "Run overload / proof load if required.",
        "Run life cycle / operation testing if required.",
        "Re-check operation and hardware.",
        "Document pass/fail and observations.",
      ],
      disclaimer:
          "Reference workflow only. Final requirements depend on governing standard and product family.",
    ),

    _key(PerformanceClass.lc, WindowType.terraceDoor): const TestProcedureProfile(
      title: "LC • Terrace Door",
      dpNotes:
          "Use LC door requirements from the governing standard and product-size basis.",
      waterNotes:
          "Confirm threshold / sill considerations and required water basis.",
      airNotes:
          "Use the applicable air infiltration requirement for the door type.",
      lifeCycleNotes:
          "Operational cycling is often significant for door qualification.",
      thermalCycleNotes:
          "Apply where required by the program.",
      steps: [
        "Confirm door hardware, threshold, and specimen details.",
        "Verify class / size basis.",
        "Run air infiltration test.",
        "Run water penetration test.",
        "Run design pressure structural test.",
        "Measure deflection and permanent set.",
        "Run overload / proof load if required.",
        "Run operational cycle checks where required.",
        "Re-check operation, lock/latch, alignment, and hardware.",
        "Document results and observations.",
      ],
      disclaimer:
          "Reference workflow only. Door-specific qualification may require additional checks.",
    ),

    _key(PerformanceClass.cw, WindowType.fixed): const TestProcedureProfile(
      title: "CW • Fixed",
      dpNotes:
          "CW qualification typically involves higher-duty commercial expectations. Use governing standard and gateway-size basis for actual DP / PG thresholds.",
      waterNotes:
          "Use required CW water basis and any cap logic per your internal standard reference.",
      airNotes:
          "Confirm applicable fixed-unit air infiltration limit.",
      lifeCycleNotes:
          "Generally not central for fixed products unless required by internal matrix.",
      thermalCycleNotes:
          "Apply where required by program, spec, or internal qualification path.",
      steps: [
        "Confirm specimen configuration and gateway-size basis.",
        "Run air infiltration test.",
        "Run water penetration test.",
        "Run design pressure structural test.",
        "Measure deflection and compare to criteria.",
        "Measure permanent set after recovery.",
        "Run overload / proof load if required.",
        "Inspect for breakage, disengagement, leakage, or distress.",
        "Document pass/fail for all required categories.",
      ],
      disclaimer:
          "Reference workflow only. Do not assign CW from pressure alone.",
    ),

    _key(PerformanceClass.cw, WindowType.operable): const TestProcedureProfile(
      title: "CW • Casement / Awning / Hopper",
      dpNotes:
          "CW operable qualification generally combines stronger structural expectations with operability requirements.",
      waterNotes:
          "Confirm required water basis for the selected product type and edition.",
      airNotes:
          "Use applicable operable-window air infiltration limit.",
      lifeCycleNotes:
          "Life cycle / repeated operation is commonly important.",
      thermalCycleNotes:
          "Include where program or family requires it.",
      steps: [
        "Confirm specimen, hardware, and operation mode.",
        "Verify class / gateway-size basis.",
        "Check pre-test operation if required.",
        "Run air infiltration test.",
        "Run water penetration test.",
        "Run design pressure structural test.",
        "Measure deflection and permanent set.",
        "Run overload / proof load if required.",
        "Run life cycle / operation testing where required.",
        "Re-check operation, hardware retention, and lockup.",
        "Document final results.",
      ],
      disclaimer:
          "Reference workflow only. Final CW qualification is product- and standard-dependent.",
    ),

    _key(PerformanceClass.cw, WindowType.terraceDoor): const TestProcedureProfile(
      title: "CW • Terrace Door",
      dpNotes:
          "Use CW door requirements and the correct gateway-size basis from the governing standard.",
      waterNotes:
          "Confirm threshold/sill details and required water basis.",
      airNotes:
          "Use applicable air infiltration requirement for this door type.",
      lifeCycleNotes:
          "Life cycle and operation checks are often significant for doors.",
      thermalCycleNotes:
          "Apply where required by the qualification path.",
      steps: [
        "Confirm specimen, threshold, and hardware details.",
        "Verify class / size basis.",
        "Run air infiltration test.",
        "Run water penetration test.",
        "Run design pressure structural test.",
        "Measure deflection and permanent set.",
        "Run overload / proof load if required.",
        "Run operation / life cycle checks where required.",
        "Re-check function, lock/latch, rollers/hinges, and alignment.",
        "Document all results.",
      ],
      disclaimer:
          "Reference workflow only. Final door qualification often includes additional functional requirements.",
    ),

    _key(PerformanceClass.aw, WindowType.fixed): const TestProcedureProfile(
      title: "AW • Fixed",
      dpNotes:
          "AW fixed products are typically architectural-grade high-duty products. Use the governing standard and gateway-size basis for actual DP / PG requirements.",
      waterNotes:
          "Use required AW water basis and apply your internal cap/reference logic as needed.",
      airNotes:
          "Confirm the applicable fixed-product air infiltration requirement.",
      lifeCycleNotes:
          "Usually limited for fixed units unless internal program requires more.",
      thermalCycleNotes:
          "May be required depending on the program or qualification path.",
      steps: [
        "Confirm specimen, size basis, and glazing details.",
        "Verify class / gateway-size basis.",
        "Run air infiltration test.",
        "Run water penetration test.",
        "Run design pressure structural test.",
        "Measure deflection and compare to allowable criteria.",
        "Measure permanent set after recovery period.",
        "Run overload / proof load if required.",
        "Inspect for any failure, distress, disengagement, or leakage.",
        "Document all results for final qualification review.",
      ],
      disclaimer:
          "Reference workflow only. AW qualification should not be inferred from pressure alone.",
    ),

    _key(PerformanceClass.aw, WindowType.operable): const TestProcedureProfile(
      title: "AW • Casement / Awning / Hopper",
      dpNotes:
          "AW operable products often combine the highest duty expectations in this group with significant operation/hardware demands.",
      waterNotes:
          "Use required AW water basis for the selected product and standard edition.",
      airNotes:
          "Confirm air infiltration requirement for the applicable operable product family.",
      lifeCycleNotes:
          "Life cycle / repeated operation is often a major qualification element.",
      thermalCycleNotes:
          "Include thermal cycle where required by the qualification path.",
      steps: [
        "Confirm specimen, hardware, and operation mode.",
        "Verify AW class / gateway-size basis.",
        "Check initial operation and hardware function.",
        "Run air infiltration test.",
        "Run water penetration test.",
        "Run design pressure structural test.",
        "Measure deflection and permanent set.",
        "Run overload / proof load if required.",
        "Run life cycle / operation testing where required.",
        "Re-check operation, hardware retention, alignment, and lockup.",
        "Document pass/fail and observations.",
      ],
      disclaimer:
          "Reference workflow only. AW operable qualification depends on the governing standard and tested configuration.",
    ),

    _key(PerformanceClass.aw, WindowType.terraceDoor): const TestProcedureProfile(
      title: "AW • Terrace Door",
      dpNotes:
          "Use AW door requirements and the proper gateway-size basis from the governing standard.",
      waterNotes:
          "Confirm required water basis and threshold details for the selected door type.",
      airNotes:
          "Use the applicable air infiltration requirement for the tested door family.",
      lifeCycleNotes:
          "Life cycle / repeated operation is commonly important for AW-level door qualification.",
      thermalCycleNotes:
          "Include where required by your qualification path or internal program.",
      steps: [
        "Confirm specimen, threshold, and hardware configuration.",
        "Verify AW class / size basis.",
        "Check initial operation and function.",
        "Run air infiltration test.",
        "Run water penetration test.",
        "Run design pressure structural test.",
        "Measure deflection and permanent set.",
        "Run overload / proof load if required.",
        "Run operation / life cycle checks where required.",
        "Re-check operation, hardware, lockup, and alignment.",
        "Document all qualification results.",
      ],
      disclaimer:
          "Reference workflow only. Final door qualification depends on governing requirements and the tested system.",
    ),
  };

  static String _key(PerformanceClass c, WindowType t) => '${c.name}_${t.name}';

  TestProcedureProfile get currentProfile =>
      profiles[_key(selectedClass, selectedType)]!;

  Widget _selectorButton<T>({
    required Color accent,
    required String label,
    required T current,
    required T value,
    required VoidCallback onPressed,
  }) {
    final selected = current == value;

    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent, width: 2),
          backgroundColor:
              selected ? accent.withValues(alpha: 0.80) : Colors.transparent,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required Color accent,
    required String title,
    required List<String> lines,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line,
                style: TextStyle(
                  color: accent.withValues(alpha: 0.82),
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _classLabel(PerformanceClass c) {
    switch (c) {
      case PerformanceClass.r:
        return "R";
      case PerformanceClass.lc:
        return "LC";
      case PerformanceClass.cw:
        return "CW";
      case PerformanceClass.aw:
        return "AW";
    }
  }

  String _typeLabel(WindowType t) {
    switch (t) {
      case WindowType.fixed:
        return "Fixed";
      case WindowType.operable:
        return "Casement / Awning / Hopper";
      case WindowType.terraceDoor:
        return "Terrace Door";
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final p = currentProfile;

    return TerminalScaffold(
      title: "Test Procedure Reference",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            terminalResultCard(
              accent: accent,
              lines: [
                "Select class and product type to load a reference procedure path.",
                "Current selection: ${_classLabel(selectedClass)} • ${_typeLabel(selectedType)}",
              ],
            ),

            const SizedBox(height: 16),

            Text(
              "Performance Class",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _selectorButton(
                  accent: accent,
                  label: "R",
                  current: selectedClass,
                  value: PerformanceClass.r,
                  onPressed: () {
                    setState(() {
                      selectedClass = PerformanceClass.r;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _selectorButton(
                  accent: accent,
                  label: "LC",
                  current: selectedClass,
                  value: PerformanceClass.lc,
                  onPressed: () {
                    setState(() {
                      selectedClass = PerformanceClass.lc;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _selectorButton(
                  accent: accent,
                  label: "CW",
                  current: selectedClass,
                  value: PerformanceClass.cw,
                  onPressed: () {
                    setState(() {
                      selectedClass = PerformanceClass.cw;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _selectorButton(
                  accent: accent,
                  label: "AW",
                  current: selectedClass,
                  value: PerformanceClass.aw,
                  onPressed: () {
                    setState(() {
                      selectedClass = PerformanceClass.aw;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              "Product Type",
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _selectorButton(
                  accent: accent,
                  label: "FIXED",
                  current: selectedType,
                  value: WindowType.fixed,
                  onPressed: () {
                    setState(() {
                      selectedType = WindowType.fixed;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _selectorButton(
                  accent: accent,
                  label: "CASE / AWN / HOP",
                  current: selectedType,
                  value: WindowType.operable,
                  onPressed: () {
                    setState(() {
                      selectedType = WindowType.operable;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _selectorButton(
                  accent: accent,
                  label: "TERRACE DOOR",
                  current: selectedType,
                  value: WindowType.terraceDoor,
                  onPressed: () {
                    setState(() {
                      selectedType = WindowType.terraceDoor;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            terminalResultCard(
              accent: accent,
              lines: [
                "Loaded profile: ${p.title}",
                p.disclaimer,
              ],
            ),

            const SizedBox(height: 14),

            _sectionCard(
              accent: accent,
              title: "Reference Requirements",
              lines: [
                "Design Pressure / PG: ${p.dpNotes}",
                "Water: ${p.waterNotes}",
                "Air: ${p.airNotes}",
                "Life Cycle: ${p.lifeCycleNotes}",
                "Thermal Cycle: ${p.thermalCycleNotes}",
              ],
            ),

            _sectionCard(
              accent: accent,
              title: "Reference Test Path",
              lines: p.steps.map((s) => "• $s").toList(),
            ),
          ],
        ),
      ),
    );
  }
}
