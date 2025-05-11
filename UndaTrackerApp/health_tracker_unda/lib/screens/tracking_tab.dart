import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'symptoms_tab.dart';
import 'menstruation_tab.dart';

class TrackingTab extends StatefulWidget {
  const TrackingTab({super.key});

  @override
  State<TrackingTab> createState() => _TrackingTabState();
}

class _TrackingTabState extends State<TrackingTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  int _cycleLength = 28;
  int _menstruationLength = 5;
  DateTime _lastPeriodStart = DateTime.now().subtract(const Duration(days: 1));

  // Functies om dagen te detecteren
  bool isMenstruationDay(DateTime day) {
    int daysSinceLastPeriod = day.difference(_lastPeriodStart).inDays;
    return daysSinceLastPeriod >= 0 &&
        daysSinceLastPeriod % _cycleLength < _menstruationLength;
  }

  bool isOvulationDay(DateTime day) {
    int cycleDay = (day.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    return cycleDay == 14;
  }

  bool isFertileDay(DateTime day) {
    int cycleDay = (day.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    return cycleDay >= 10 && cycleDay <= 15;
  }

  List<String> getSymptomsForDay(DateTime day) {
    if (day.day % 5 == 0) return ['Buikpijn', 'Vermoeid'];
    if (day.day % 3 == 0) return ['Hoofdpijn'];
    return [];
  }

  String getCycleDayLabel(DateTime date) {
    int dayDiff = date.difference(_lastPeriodStart).inDays;
    int cycleDay = (dayDiff % _cycleLength) + 1;
    if (cycleDay <= _menstruationLength) {
      return 'Menstruatiedag $cycleDay';
    } else {
      return 'Cyclusdag $cycleDay';
    }
  }

  String getPregnancyChance(DateTime date) {
    int cycleDay =
        (date.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    if (cycleDay >= 9 && cycleDay <= 14) return '🔴 Hoog (±60%)';
    if (cycleDay >= 10 && cycleDay <= 16) return '🟠 Gemiddeld (±30%)';
    return '🟢 Laag (<1%)';
  }

  DateTime getNextPeriodStart() {
    DateTime next = _lastPeriodStart;
    while (next.isBefore(_selectedDay)) {
      next = next.add(Duration(days: _cycleLength));
    }
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final selectedSymptoms = getSymptomsForDay(_selectedDay);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TableCalendar(
            locale: 'nl',
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(255, 229, 227, 114),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color.fromARGB(255, 127, 221, 250),
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (isMenstruationDay(day)) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else if (isOvulationDay(day)) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else if (isFertileDay(day)) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SymptomsTab(selectedDay: _selectedDay),
                    ),
                  );
                },
                icon: const Icon(Icons.healing),
                label: const Text('Symptomen'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => MenstruationTab(selectedDay: _selectedDay),
                    ),
                  );
                },
                icon: const Icon(Icons.bloodtype),
                label: const Text('Log periode'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📅 ${DateFormat('EEEE d MMMM y', 'nl').format(_selectedDay)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(getCycleDayLabel(_selectedDay)),
                const SizedBox(height: 8),
                Text(
                  'Symptomen: ${selectedSymptoms.isNotEmpty ? selectedSymptoms.join(', ') : 'Geen'}',
                ),
                const SizedBox(height: 8),
                Text(
                  '🤰 Kans op zwangerschap: ${getPregnancyChance(_selectedDay)}',
                ),
                const SizedBox(height: 8),
                Text(
                  '📍 Volgende menstruatie: ${DateFormat('d MMMM', 'nl').format(getNextPeriodStart())}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
