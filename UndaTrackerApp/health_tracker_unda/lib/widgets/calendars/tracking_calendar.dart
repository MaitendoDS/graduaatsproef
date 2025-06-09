import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/cycle_calculator.dart';

class TrackerCalendarWidget extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CycleCalculator cycleCalculator;
  final Map<String, bool> calendarFilters;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const TrackerCalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.cycleCalculator,
    required this.calendarFilters,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  State<TrackerCalendarWidget> createState() => _TrackerCalendarWidgetState();
}

class _TrackerCalendarWidgetState extends State<TrackerCalendarWidget> {
  bool _isLoading = false;
  late DateTime _internalFocusedDay;

  @override
  void initState() {
    super.initState();
    _internalFocusedDay = widget.focusedDay;
    _loadCalendarData();
  }

  @override
  void didUpdateWidget(covariant TrackerCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(oldWidget.focusedDay, widget.focusedDay)) {
      _internalFocusedDay = widget.focusedDay;
      _loadCalendarData();
    }
  }

  Future<void> _loadCalendarData() async {
    setState(() => _isLoading = true);

    DateTime firstDay = DateTime(_internalFocusedDay.year, _internalFocusedDay.month, 1);
    DateTime lastDay = DateTime(_internalFocusedDay.year, _internalFocusedDay.month + 1, 0);

    await widget.cycleCalculator.loadDataForDateRange(firstDay, lastDay);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _onPageChanged(DateTime focusedDay) async {
    print('Nieuwe maand geselecteerd: $focusedDay');
    setState(() {
      _internalFocusedDay = focusedDay;
      _isLoading = true;
    });

    DateTime firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
    DateTime lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    await widget.cycleCalculator.loadDataForDateRange(firstDay, lastDay);
    if (!mounted) return;
    setState(() => _isLoading = false);

    widget.onPageChanged(focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          TableCalendar(
            locale: 'nl',
            focusedDay: _internalFocusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
            onDaySelected: widget.onDaySelected,
            onPageChanged: _onPageChanged,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Colors.pink.shade400,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Colors.pink.shade400,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue.shade400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return widget.cycleCalculator.buildCalendarDay(day, widget.calendarFilters);
              },
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
