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

class _TrackingTabState extends State<TrackingTab> with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _cycleLength = 28;
  int _menstruationLength = 5;
  DateTime _lastPeriodStart = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
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

  // Cycle detection functions
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

  bool isPreMenstrualDay(DateTime day) {
    int cycleDay = (day.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    return cycleDay >= 25 && cycleDay <= 28;
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
    } else if (cycleDay >= 10 && cycleDay <= 15) {
      return 'Vruchtbare periode - Dag $cycleDay';
    } else if (cycleDay == 14) {
      return 'Eisprong - Dag $cycleDay';
    } else if (cycleDay >= 25) {
      return 'Pre-menstrueel - Dag $cycleDay';
    } else {
      return 'Follikulaire fase - Dag $cycleDay';
    }
  }

  String getPhaseDescription(DateTime date) {
    int cycleDay = (date.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    
    if (cycleDay <= _menstruationLength) {
      return 'Je menstruatie is bezig. Zorg goed voor jezelf!';
    } else if (cycleDay >= 10 && cycleDay <= 15) {
      return 'Dit is je vruchtbare periode. Verhoogde kans op zwangerschap.';
    } else if (cycleDay == 14) {
      return 'Eisprong vindt vandaag plaats. Hoogste vruchtbaarheid.';
    } else if (cycleDay >= 25) {
      return 'Pre-menstruele fase. Je menstruatie komt eraan.';
    } else {
      return 'Follikulaire fase. Je lichaam bereidt zich voor op de eisprong.';
    }
  }

  String getPregnancyChance(DateTime date) {
    int cycleDay = (date.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    if (cycleDay == 14) return 'Zeer hoog (±80%)';
    if (cycleDay >= 12 && cycleDay <= 16) return 'Hoog (±60%)';
    if (cycleDay >= 10 && cycleDay <= 18) return 'Gemiddeld (±30%)';
    return 'Laag (<5%)';
  }

  Color getPregnancyChanceColor(DateTime date) {
    int cycleDay = (date.difference(_lastPeriodStart).inDays % _cycleLength) + 1;
    if (cycleDay == 14) return Colors.red.shade600;
    if (cycleDay >= 12 && cycleDay <= 16) return Colors.orange.shade600;
    if (cycleDay >= 10 && cycleDay <= 18) return Colors.yellow.shade700;
    return Colors.green.shade600;
  }

  DateTime getNextPeriodStart() {
    DateTime next = _lastPeriodStart;
    while (next.isBefore(_selectedDay)) {
      next = next.add(Duration(days: _cycleLength));
    }
    return next;
  }

  int getDaysUntilNextPeriod() {
    return getNextPeriodStart().difference(_selectedDay).inDays;
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legenda',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  color: Colors.pinkAccent,
                  label: 'Menstruatie',
                  icon: Icons.water_drop,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  color: Colors.green,
                  label: 'Eisprong',
                  icon: Icons.favorite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  color: Colors.green.shade100,
                  label: 'Vruchtbaar',
                  icon: Icons.eco,
                  textColor: Colors.black,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  color: Colors.purple.shade100,
                  label: 'Pre-menstrueel',
                  icon: Icons.schedule,
                  textColor: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
    Color textColor = Colors.white,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 12,
            color: textColor,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSymptoms = getSymptomsForDay(_selectedDay);
    final daysUntilPeriod = getDaysUntilNextPeriod();
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              Container(
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
              ),
              
              const SizedBox(height: 20),
              
              // Legend
              _buildLegend(),
              
              // Calendar
              Container(
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
                      color: Colors.amber.shade400,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
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
                      Widget? dayWidget;
                      
                      if (isMenstruationDay(day)) {
                        dayWidget = Container(
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.water_drop,
                                size: 12,
                                color: Colors.white,
                              ),
                              Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (isOvulationDay(day)) {
                        dayWidget = Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.favorite,
                                size: 12,
                                color: Colors.white,
                              ),
                              Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (isFertileDay(day)) {
                        dayWidget = Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green.shade300,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.eco,
                                size: 10,
                                color: Colors.green.shade700,
                              ),
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (isPreMenstrualDay(day)) {
                        dayWidget = Container(
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.purple.shade300,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 10,
                                color: Colors.purple.shade700,
                              ),
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return dayWidget;
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SymptomsTab(selectedDay: _selectedDay),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.healing),
                      label: const Text(
                        'Symptomen',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MenstruationTab(selectedDay: _selectedDay),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade100,
                        foregroundColor: Colors.pink.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.bloodtype),
                      label: const Text(
                        'Menstruatie',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Selected Day Info
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: Colors.pink.shade400,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEEE d MMMM y', 'nl').format(_selectedDay),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  getCycleDayLabel(_selectedDay),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          getPhaseDescription(_selectedDay),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Info Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.favorite,
                              iconColor: getPregnancyChanceColor(_selectedDay),
                              title: 'Zwangerschapskans',
                              value: getPregnancyChance(_selectedDay),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.healing,
                              iconColor: selectedSymptoms.isNotEmpty 
                                  ? Colors.orange.shade600 
                                  : Colors.green.shade600,
                              title: 'Symptomen',
                              value: selectedSymptoms.isNotEmpty 
                                  ? '${selectedSymptoms.length} symptom${selectedSymptoms.length > 1 ? 'en' : ''}'
                                  : 'Geen',
                            ),
                          ),
                        ],
                      ),
                      
                      if (selectedSymptoms.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedSymptoms.map((symptom) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              symptom,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      
                      // Quick Action Button
                      if (isMenstruationDay(_selectedDay) || daysUntilPeriod <= 2)
                        Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MenstruationTab(selectedDay: _selectedDay),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bloodtype),
                            label: Text(
                              isMenstruationDay(_selectedDay) 
                                  ? 'Menstruatie bijwerken'
                                  : 'Begin menstruatie',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}