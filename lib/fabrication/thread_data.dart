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

const List<ThreadSpec> commonUNC = [];
const List<ThreadSpec> commonUNF = [];
const List<ThreadSpec> commonMetric = [];
