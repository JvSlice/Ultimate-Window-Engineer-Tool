import '../fabrication/thread_data.dart';

double _majorInches(ThreadSpec t) {
  if (t.system == ThreadSystem.metric) return t.major / 25.4;
  return t.major;
}

double _pitchInches(ThreadSpec t) {
  if (t.system == ThreadSystem.metric) return t.pitchOrTpi / 25.4;
  return 1.0 / t.pitchOrTpi;
}

double tapDrillDecimalInches(ThreadSpec t, double engagement) {
  final majorIn = _majorInches(t);
  final pitchIn = _pitchInches(t);

  const fullThreadFactor = 1.299038;

  return majorIn - (engagement* fullThreadFactor * pitchIn);
}
