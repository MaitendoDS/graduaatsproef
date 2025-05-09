import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  final int cycleLength = 28;
  final int menstruationLength = 5;
  DateTime get lastPeriodStart => DateTime(2024, 12, 20); // voor simulatie

  Color? getDayColor(DateTime date) {
    final today = DateTime.now();
    final dayDiff = date.difference(lastPeriodStart).inDays;
    final cycleDay = (dayDiff % cycleLength) + 1;

    if (isSameDate(date, today)) return Colors.blueAccent;
    if (cycleDay <= menstruationLength) return Colors.pink.shade200;
    if (cycleDay == 14) return Colors.green;
    if (cycleDay >= 12 && cycleDay <= 16) return Colors.green.shade200;

    return null;
  }

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Widget> buildMonth(DateTime monthStart) {
    final daysInMonth = DateUtils.getDaysInMonth(
      monthStart.year,
      monthStart.month,
    );
    final firstWeekday = DateTime(monthStart.year, monthStart.month, 1).weekday;
    final List<Widget> rows = [];

    final days = <DateTime>[];

    // Voeg lege dagen toe voor de start van de maand (zodat het op maandag begint)
    for (int i = 1; i < firstWeekday; i++) {
      days.add(DateTime(2000)); // lege cel
    }

    // Voeg de echte dagen toe
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(monthStart.year, monthStart.month, i));
    }

    // Vul aan met lege dagen tot zondag (zodat elke week 7 dagen heeft)
    while (days.length % 7 != 0) {
      days.add(DateTime(2000)); // lege cel
    }

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Text('Ma'),
          Text('Di'),
          Text('Wo'),
          Text('Do'),
          Text('Vr'),
          Text('Za'),
          Text('Zo'),
        ],
      ),
    );
    for (int i = 0; i < days.length; i += 7) {
      final weekDays = days.skip(i).take(7).toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                weekDays.map((date) {
                  if (date.year == 2000) {
                    return const SizedBox(width: 30); // lege cel
                  }
                  return Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: getDayColor(date),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  );
                }).toList(),
          ),
        ),
      );
    }

    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          DateFormat('MMMM yyyy', 'nl').format(monthStart),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      ...rows,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startMonth = DateTime(now.year, now.month - 1); // maand vóór huidige
    final months = List.generate(12, (i) {
      final date = DateTime(startMonth.year, startMonth.month + i);
      return Column(children: buildMonth(date));
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: months),
    );
  }
}
