import 'package:flutter/material.dart';
import 'package:health_tracker_unda/screens/food_tab.dart';
import '../models/cycle_calculator.dart';
import '../widgets/buttons/action_buttons.dart';
import '../widgets/calendars/calendar_legend.dart';
import '../widgets/calendars/tracking_calendar.dart';
import '../widgets/day_info_card.dart';
import '../widgets/headers/cycle_header.dart';
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
  bool _isInitializing = true;

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
    _initializeCalculator();
    _setupAnimations();
  }

  Future<void> _initializeCalculator() async {
    _cycleCalculator = CycleCalculator();
    await _cycleCalculator.initialize();
    
    setState(() {
      _isInitializing = false;
    });
    
    _animationController.forward();
  }

  void _setupAnimations() {
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFilter(String filterKey) {
    setState(() {
      _calendarFilters[filterKey] = !_calendarFilters[filterKey]!;
    });
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
              ),
              SizedBox(height: 16),
              Text(
                'Cyclus gegevens laden...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.pink,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CycleHeaderWidget(
                  selectedDay: _selectedDay,
                  cycleCalculator: _cycleCalculator,
                ),
                const SizedBox(height: 20),
                CalendarLegend(
                  filters: _calendarFilters,
                  onFilterToggle: _toggleFilter,
                ),
                const SizedBox(height: 20),
                TrackerCalendarWidget(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  cycleCalculator: _cycleCalculator,
                  calendarFilters: _calendarFilters,
                  onDaySelected: _onDaySelected,
                  onPageChanged: _onPageChanged,
                ),
                const SizedBox(height: 20),
                ActionButtons(
                  selectedDay: _selectedDay,
                  onSymptomsPressed: _navigateToSymptoms,
                  onMenstruationPressed: _navigateToMenstruation,
                  onFoodPressed: _navigateToFood,
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: EnhancedDayInfoCard(
                    selectedDay: _selectedDay,
                    cycleCalculator: _cycleCalculator,
                    onMenstruationPressed: _navigateToMenstruation,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _initializeCalculator();
    
    // Reload calendar data voor maand
    DateTime firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    DateTime lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    await _cycleCalculator.loadDataForDateRange(firstDay, lastDay);
    
    setState(() {});
  }

  void _navigateToSymptoms() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SymptomsTab(selectedDay: _selectedDay),
      ),
    );
    
    // Refresh data als iets verandert
    if (result == true) {
      await _refreshData();
    }
  }

  void _navigateToMenstruation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenstruationTab(selectedDay: _selectedDay),
      ),
    );
    
    // Refresh data als iets verandert
    if (result == true) {
      await _refreshData();
    }
  }

  
  void _navigateToFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodTab(selectedDay: _selectedDay),
      ),
    );
    
    // Refresh data als iets verandert
    if (result == true) {
      await _refreshData();
    }
  }
}