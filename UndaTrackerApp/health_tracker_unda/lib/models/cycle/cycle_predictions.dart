class CyclePredictions {
  int _cycleLength = 28;
  int _menstruationLength = 5;
  DateTime? _lastPeriodStart;

  void updateCycleData(int cycleLength, int menstruationLength, DateTime? lastPeriodStart) {
    _cycleLength = cycleLength;
    _menstruationLength = menstruationLength;
    _lastPeriodStart = lastPeriodStart;
  }

  bool isPredictedMenstruationDay(DateTime day) {
    if (_lastPeriodStart == null) return false;

    int daysSinceLastPeriod = day.difference(_lastPeriodStart!).inDays;
    return daysSinceLastPeriod >= 0 &&
        daysSinceLastPeriod % _cycleLength < _menstruationLength;
  }

  bool isOvulationDay(DateTime day) {
    if (_lastPeriodStart == null) return false;

    int cycleDay = (day.difference(_lastPeriodStart!).inDays % _cycleLength) + 1;
    return cycleDay == 14;
  }

  bool isFertileDay(DateTime day) {
    if (_lastPeriodStart == null) return false;

    int cycleDay = (day.difference(_lastPeriodStart!).inDays % _cycleLength) + 1;
    return cycleDay >= 10 && cycleDay <= 15;
  }

  DateTime? getNextPeriodStart(DateTime selectedDay) {
    if (_lastPeriodStart == null) return null;

    DateTime next = _lastPeriodStart!;
    while (next.isBefore(selectedDay)) {
      next = next.add(Duration(days: _cycleLength));
    }
    return next;
  }

  int getDaysUntilNextPeriod(DateTime selectedDay) {
    final nextPeriod = getNextPeriodStart(selectedDay);
    if (nextPeriod == null) return 0;
    return nextPeriod.difference(selectedDay).inDays;
  }

  int getCycleDay(DateTime date) {
    if (_lastPeriodStart == null) return 1;
    return (date.difference(_lastPeriodStart!).inDays % _cycleLength) + 1;
  }

  // Getters voor cycle info (voor backward compatibility)
  int get cycleLength => _cycleLength;
  int get menstruationLength => _menstruationLength;
  DateTime? get lastPeriodStart => _lastPeriodStart;
}