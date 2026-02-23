import '../fabrication/thread_data.dart';
import '../drill_index_data.dart';

double _toInches(ThreadSpec t) {
  if (t.system == ThreadSystem.metric) {
    return t.major / 25.4;
  }
  return t.major;
}

double _pitchInches(ThreadSpec t) {
  if (t.system == ThreadSystem.metric) {
    return t.pitchOrTpi / 25.4; // mm pitch to in
  }
  return 1.0 / t.pitchOrTpi; // tpi
}

// engaugment 0.75 -75%
double tapDrillDecimalInches(ThreadSpec t, double engagement) {
  final majorIn = _toInches(t);
  final pitchIn = _pitchInches(t);
  return majorIn - (engagement * pitchIn);
}

DrillSize closestDrill(double targetDecimalInches) {
  DrillSize best = drillIndex.first;
  for (final d in drillIndex) {
    final a = (d.decimal - targetDecimalInches).abs();
    final b = (best.decimal - targetDecimalInches).abs();
    if (a < b) best = d;
  }
  return best;
}
