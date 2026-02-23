enum ThreadSystem { unc, unf, metric }

class ThreadSpec {
  final ThreadSystem system;
  // for disaplay and dropdowns
  final String label;

  // in for unc/unf
  final double major;

  //TPI for unc/unf, pitch
  final double pitchOrTpi;

  const ThreadSpec({
    required this.system,
    required this.label,
    required this.major,
    required this.pitchOrTpi,
  });
}

const List<ThreadSpec> commonUNC = [
  ThreadSpec(
    system: ThreadSystem.unc,
    label: "#6-32",
    major: 0.1380,
    pitchOrTpi: 32,
  ),
];
const List<ThreadSpec> commonUNF = [
  ThreadSpec(
    system: ThreadSystem.unf,
    label: "#6-40",
    major: 0.138,
    pitchOrTpi: 40,
  ),
];

const List<ThreadSpec> commonMetric = [
  ThreadSpec(
    system: ThreadSystem.metric,
    label: "M3 x 0.0=5",
    major: 3.0,
    pitchOrTpi: 0.5,
  ),
];
