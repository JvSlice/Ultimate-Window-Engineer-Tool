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
  ThreadSpec(system: ThreadSystem.unc, label: "#8-32",  major: 0.1640, pitchOrTpi: 32),
  ThreadSpec(system: ThreadSystem.unc, label: "#10-24", major: 0.1900, pitchOrTpi: 24),
  ThreadSpec(system: ThreadSystem.unc, label: "#10-32", major: 0.1900, pitchOrTpi: 32),
  ThreadSpec(system: ThreadSystem.unc, label: "1/4-20", major: 0.2500, pitchOrTpi: 20),
  ThreadSpec(system: ThreadSystem.unc, label: "5/16-18",major: 0.3125, pitchOrTpi: 18),
  ThreadSpec(system: ThreadSystem.unc, label: "3/8-16", major: 0.3750, pitchOrTpi: 16),
  ThreadSpec(system: ThreadSystem.unc, label: "1/2-13", major: 0.5000, pitchOrTpi: 13),
];
const List<ThreadSpec> commonUNF = [
  ThreadSpec(
    system: ThreadSystem.unf,
    label: "#6-40",
    major: 0.138,
    pitchOrTpi: 40,
  ),
   ThreadSpec(system: ThreadSystem.unf, label: "#8-36",   major: 0.1640, pitchOrTpi: 36),
  ThreadSpec(system: ThreadSystem.unf, label: "#10-32",  major: 0.1900, pitchOrTpi: 32),
  ThreadSpec(system: ThreadSystem.unf, label: "1/4-28",  major: 0.2500, pitchOrTpi: 28),
  ThreadSpec(system: ThreadSystem.unf, label: "5/16-24", major: 0.3125, pitchOrTpi: 24),
  ThreadSpec(system: ThreadSystem.unf, label: "3/8-24",  major: 0.3750, pitchOrTpi: 24),
  ThreadSpec(system: ThreadSystem.unf, label: "1/2-20",  major: 0.5000, pitchOrTpi: 20),
  
  
];

const List<ThreadSpec> commonMetric = [
  ThreadSpec(
    system: ThreadSystem.metric,
    label: "M3 x 0.0=5",
    major: 3.0,
    pitchOrTpi: 0.5,
  ),
    ThreadSpec(system: ThreadSystem.metric, label: "M3 x 0.5",   major: 3.0,  pitchOrTpi: 0.5),
  ThreadSpec(system: ThreadSystem.metric, label: "M4 x 0.7",   major: 4.0,  pitchOrTpi: 0.7),
  ThreadSpec(system: ThreadSystem.metric, label: "M5 x 0.8",   major: 5.0,  pitchOrTpi: 0.8),
  ThreadSpec(system: ThreadSystem.metric, label: "M6 x 1.0",   major: 6.0,  pitchOrTpi: 1.0),
  ThreadSpec(system: ThreadSystem.metric, label: "M8 x 1.25",  major: 8.0,  pitchOrTpi: 1.25),
  ThreadSpec(system: ThreadSystem.metric, label: "M10 x 1.5",  major: 10.0, pitchOrTpi: 1.5),
  ThreadSpec(system: ThreadSystem.metric, label: "M12 x 1.75", major: 12.0, pitchOrTpi: 1.75),
];
