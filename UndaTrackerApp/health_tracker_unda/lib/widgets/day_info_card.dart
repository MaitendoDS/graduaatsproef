
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cycle_calculator.dart';

class DayInfoCard extends StatelessWidget {
  final DateTime selectedDay;
  final CycleCalculator cycleCalculator;
  final VoidCallback onMenstruationPressed;

  const DayInfoCard({
    super.key,
    required this.selectedDay,
    required this.cycleCalculator,
    required this.onMenstruationPressed,
  });

  @override
  Widget build(BuildContext context) {
    final selectedSymptoms = cycleCalculator.getSymptomsForDay(selectedDay);
    final daysUntilPeriod = cycleCalculator.getDaysUntilNextPeriod(selectedDay);

    return Container(
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
          _buildHeader(),
          const SizedBox(height: 16),
          _buildPhaseDescription(),
          const SizedBox(height: 16),
          _buildInfoGrid(selectedSymptoms),
          if (selectedSymptoms.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSymptomsChips(selectedSymptoms),
          ],
          const SizedBox(height: 20),
          if (cycleCalculator.isMenstruationDay(selectedDay) || daysUntilPeriod <= 2)
            _buildQuickActionButton(daysUntilPeriod),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
                DateFormat('EEEE d MMMM y', 'nl').format(selectedDay),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                cycleCalculator.getCycleDayLabel(selectedDay),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        cycleCalculator.getPhaseDescription(selectedDay),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildInfoGrid(List<String> selectedSymptoms) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.favorite,
            iconColor: cycleCalculator.getPregnancyChanceColor(selectedDay),
            title: 'Zwangerschapskans',
            value: cycleCalculator.getPregnancyChance(selectedDay),
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
                ? '${selectedSymptoms.length} ${selectedSymptoms.length == 1 ? 'symptoom' : 'symptomen'}'
                : 'Geen',
          ),
        ),
      ],
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

  Widget _buildSymptomsChips(List<String> selectedSymptoms) {
    return Wrap(
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
    );
  }

  Widget _buildQuickActionButton(int daysUntilPeriod) {
    return Center(
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
        onPressed: onMenstruationPressed,
        icon: const Icon(Icons.bloodtype),
        label: Text(
          cycleCalculator.isMenstruationDay(selectedDay) 
              ? 'Menstruatie bijwerken'
              : 'Begin menstruatie',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}