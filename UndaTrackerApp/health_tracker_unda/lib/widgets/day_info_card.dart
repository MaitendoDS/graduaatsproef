import 'package:flutter/material.dart';
import '../models/cycle_calculator.dart';
import '../widgets/section_container.dart';

class EnhancedDayInfoCard extends StatefulWidget {
  final DateTime selectedDay;
  final CycleCalculator cycleCalculator;
  final VoidCallback onMenstruationPressed;

  const EnhancedDayInfoCard({
    super.key,
    required this.selectedDay,
    required this.cycleCalculator,
    required this.onMenstruationPressed,
  });

  @override
  State<EnhancedDayInfoCard> createState() => _EnhancedDayInfoCardState();
}

class _EnhancedDayInfoCardState extends State<EnhancedDayInfoCard> {
  List<Map<String, dynamic>> _symptoms = [];
  Map<String, dynamic>? _menstruationData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDayData();
  }

  @override
  void didUpdateWidget(EnhancedDayInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDay != widget.selectedDay) {
      _loadDayData();
    }
  }

  Future<void> _loadDayData() async {
    setState(() => _isLoading = true);
    
    _symptoms = widget.cycleCalculator.getSymptomsForDay(widget.selectedDay);
    _menstruationData = widget.cycleCalculator.getMenstruationForDay(widget.selectedDay);
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
        ),
      );
    }

    return Column(
      children: [
        _buildCycleInfoSection(),
        const SizedBox(height: 16),
        if (_menstruationData != null) _buildMenstruationSection(),
        if (_symptoms.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSymptomsSection(),
        ],
        if (_menstruationData == null && _symptoms.isEmpty)
          _buildEmptyStateSection(),
      ],
    );
  }

  Widget _buildCycleInfoSection() {
    return SectionContainer(
      title: 'Cyclus Informatie',
      icon: Icons.info_outline,
      iconColor: Colors.blue,
      children: [
        _buildInfoRow('Datum', _formatDate(widget.selectedDay)),
        _buildInfoRow('Cyclus Dag', widget.cycleCalculator.getCycleDayLabel(widget.selectedDay)),
        _buildInfoRow('Fase', widget.cycleCalculator.getPhaseDescription(widget.selectedDay)),
        _buildInfoRow('Zwangerschapskans', widget.cycleCalculator.getPregnancyChance(widget.selectedDay)),
      ],
    );
  }

  Widget _buildMenstruationSection() {
    return SectionContainer(
      title: 'Menstruatie',
      icon: Icons.water_drop,
      iconColor: Colors.pink,
      children: [
        if (_menstruationData!['sexOptions'] != null)
          _buildInfoRow('Seks opties', _menstruationData!['sexOptions'].toString()),
        if (_menstruationData!['symptoms'] != null && _menstruationData!['symptoms'].isNotEmpty)
          _buildInfoRow('Symptomen', _menstruationData!['symptoms'].join(', ')),
        if (_menstruationData!['dischargeAmount'] != null)
          _buildInfoRow('Afscheiding hoeveelheid', _menstruationData!['dischargeAmount'].toString()),
        if (_menstruationData!['dischargeType'] != null)
          _buildInfoRow('Afscheiding type', _menstruationData!['dischargeType'].toString()),
        if (_menstruationData!['notities'] != null && _menstruationData!['notities'].isNotEmpty)
          _buildInfoRow('Notities', _menstruationData!['notities'].toString()),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: widget.onMenstruationPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Bewerk Menstruatie'),
        ),
      ],
    );
  }

  Widget _buildSymptomsSection() {
    return SectionContainer(
      title: 'Symptomen',
      icon: Icons.healing,
      iconColor: Colors.orange,
      children: [
        ..._symptoms.map((symptom) => _buildSymptomCard(symptom)),
      ],
    );
  }

  Widget _buildSymptomCard(Map<String, dynamic> symptom) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSymptomIcon(symptom['type']),
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                symptom['type'] ?? 'Onbekend symptoom',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              const Spacer(),
              if (symptom['tijd'] != null)
                Text(
                  symptom['tijd'].toString(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          if (symptom['locatie'] != null && symptom['locatie'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Locatie: ${symptom['locatie']}'),
          ],
          if (symptom['pijnschaal'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Pijnschaal: '),
                ...List.generate(5, (index) {
                  return Icon(
                    index < symptom['pijnschaal'] ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 16,
                  );
                }),
                Text(' (${symptom['pijnschaal']}/5)'),
              ],
            ),
          ],
          if (symptom['notities'] != null && symptom['notities'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Notities: ${symptom['notities']}'),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyStateSection() {
    return SectionContainer(
      title: 'Geen Data',
      icon: Icons.calendar_today,
      iconColor: Colors.grey,
      children: [
        const Text(
          'Er zijn geen gegevens geregistreerd voor deze dag.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const Text(
          'Wil je gegevens toevoegen?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: widget.onMenstruationPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Menstruatie Registreren'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSymptomIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'buikpijn':
        return Icons.accessibility_new;
      case 'hoofdpijn':
        return Icons.psychology;
      case 'vermoeid':
        return Icons.battery_2_bar;
      case 'kramp':
        return Icons.flash_on;
      default:
        return Icons.healing;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'januari', 'februari', 'maart', 'april', 'mei', 'juni',
      'juli', 'augustus', 'september', 'oktober', 'november', 'december'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  }