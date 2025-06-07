import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/cycle_calculator.dart';
import '../widgets/action_buttons.dart';
import '../widgets/calendar_legend.dart';
import '../widgets/day_info_card.dart';
import 'symptoms_tab.dart';
import 'menstruation_tab.dart';

class TrackingTab extends StatefulWidget {
  const TrackingTab({super.key});

  @override
  State<TrackingTab> createState() => _TrackingTabState();
}

class _TrackingTabState extends State<TrackingTab> with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late CycleCalculator _cycleCalculator;

  // Filters voor wat er getoond wordt in de kalender
  Map<String, bool> _calendarFilters = {
    'menstruation': true,
    'ovulation': true,
    'fertile': true,
    'symptoms': true, 
  };

  @override
  void initState() {
    super.initState();
    _cycleCalculator = CycleCalculator();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  //functie om filters aan/uit te zetten
  void _toggleFilter(String filterKey) {
    setState(() {
      _calendarFilters[filterKey] = !_calendarFilters[filterKey]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              CalendarLegend(
                filters: _calendarFilters,
                onFilterToggle: _toggleFilter,
              ),
              const SizedBox(height: 20),
              _buildCalendar(),
              const SizedBox(height: 20),
              ActionButtons(
                selectedDay: _selectedDay,
                onSymptomsPressed: () => _navigateToSymptoms(),
                onMenstruationPressed: () => _navigateToMenstruation(),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnimation,
                child: DayInfoCard(
                  selectedDay: _selectedDay,
                  cycleCalculator: _cycleCalculator,
                  onMenstruationPressed: () => _navigateToMenstruation(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final daysUntilPeriod = _cycleCalculator.getDaysUntilNextPeriod(_selectedDay);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade100, Colors.purple.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 32,
            color: Colors.pink,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cyclus Tracker',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  daysUntilPeriod > 0 
                      ? '$daysUntilPeriod dagen tot volgende menstruatie'
                      : 'Menstruatie kan elk moment beginnen',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
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
      child: TableCalendar(
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
          _animationController.reset();
          _animationController.forward();
        },
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
            // Geef filters door aan buildCalendarDay
            return _cycleCalculator.buildCalendarDay(day, _calendarFilters);
          },
        ),
      ),
    );
  }

  void _navigateToSymptoms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SymptomsTab(selectedDay: _selectedDay),
      ),
    );
  }

  void _navigateToMenstruation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenstruationTab(selectedDay: _selectedDay),
      ),
    );
  }
}
