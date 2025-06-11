
import '../../services/tracking_service.dart';

class CycleDataManager {
  final FirestoreService _firestoreService = FirestoreService();

  int _cycleLength = 28;
  int _menstruationLength = 5;
  DateTime? _lastPeriodStart;

  // Cache for data
  Map<String, List<Map<String, dynamic>>> _symptomsCache = {};
  Map<String, List<Map<String, dynamic>>> _foodCache = {};
  Map<String, Map<String, dynamic>> _menstruationCache = {};

  // Getters
  int get cycleLength => _cycleLength;
  int get menstruationLength => _menstruationLength;
  DateTime? get lastPeriodStart => _lastPeriodStart;

  Future<void> initialize() async {
    final userData = await _firestoreService.getUserCycleData();
    if (userData != null) {
      _cycleLength = userData['cycleLength'] ?? 28;
      _menstruationLength = userData['menstruationLength'] ?? 5;
    }

    final menstruationDates = await _firestoreService.getAllMenstruationDates();
    if (menstruationDates.isNotEmpty) {
      _lastPeriodStart = menstruationDates.first;
    } else {
      _lastPeriodStart = DateTime.now().subtract(const Duration(days: 8));
    }
  }

  Future<void> loadDataForDateRange(DateTime startDate, DateTime endDate) async {
    final results = await Future.wait([
      _firestoreService.getSymptomsForDateRange(startDate, endDate),
      _firestoreService.getMenstruationForDateRange(startDate, endDate),
      _firestoreService.getFoodForDateRange(startDate, endDate),
    ]);

    _symptomsCache = results[0] as Map<String, List<Map<String, dynamic>>>;
    _menstruationCache = results[1] as Map<String, Map<String, dynamic>>;
    _foodCache = results[2] as Map<String, List<Map<String, dynamic>>>;
  }

  bool isMenstruationDay(DateTime day) {
    String dateKey = '${day.year}-${day.month}-${day.day}';
    return _menstruationCache.containsKey(dateKey);
  }

  bool hasSymptoms(DateTime day) {
    String dateKey = '${day.year}-${day.month}-${day.day}';
    return _symptomsCache.containsKey(dateKey) &&
        _symptomsCache[dateKey]!.isNotEmpty;
  }

  List<Map<String, dynamic>> getFoodForDay(DateTime day) {
    String dateKey = '${day.year}-${day.month}-${day.day}';
    return _foodCache[dateKey] ?? [];
  }

  List<Map<String, dynamic>> getSymptomsForDay(DateTime day) {
    String dateKey = '${day.year}-${day.month}-${day.day}';
    return _symptomsCache[dateKey] ?? [];
  }

  Map<String, dynamic>? getMenstruationForDay(DateTime day) {
    String dateKey = '${day.year}-${day.month}-${day.day}';
    return _menstruationCache[dateKey];
  }
}