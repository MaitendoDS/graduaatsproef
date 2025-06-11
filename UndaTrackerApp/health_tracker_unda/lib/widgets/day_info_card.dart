import 'package:flutter/material.dart';
import '../models/cycle_calculator.dart';
import '../models/food_data.dart';
import '../models/symptom_data.dart';
import '../services/food_service.dart';
import '../services/symptom_service.dart';
import '../services/menstruation_service.dart';
import '../screens/food_tab.dart';
import '../screens/symptoms_tab.dart';
import '../screens/menstruation_tab.dart';
import '../widgets/section_container.dart';

class EnhancedDayInfoCard extends StatefulWidget {
  final DateTime selectedDay;
  final CycleCalculator cycleCalculator;
  final VoidCallback onMenstruationPressed;
  final VoidCallback? onDataChanged; // Callback voor refresh

  const EnhancedDayInfoCard({
    super.key,
    required this.selectedDay,
    required this.cycleCalculator,
    required this.onMenstruationPressed,
    this.onDataChanged,
  });

  @override
  State<EnhancedDayInfoCard> createState() => _EnhancedDayInfoCardState();
}

class _EnhancedDayInfoCardState extends State<EnhancedDayInfoCard> {
  List<Map<String, dynamic>> _symptoms = [];
  Map<String, dynamic>? _menstruationData;
  List<Map<String, dynamic>> _foodItems = [];
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
  _foodItems = widget.cycleCalculator.getFoodForDay(widget.selectedDay);
  
  setState(() => _isLoading = false);
}

  // ===== DELETE METHODS =====
  Future<void> _deleteFood(String foodId, String foodName) async {
  final confirm = await _showDeleteDialog('voedingsitem', foodName);
  if (confirm != true) return;

  try {
    await FoodService.deleteFoodEntry(foodId);
    if (mounted) {
      _showSuccessMessage('Voedingsitem verwijderd');
      await _refreshData();
    }
  } catch (e) {
    if (mounted) {
      _showErrorMessage('Fout bij verwijderen: $e');
    }
  }
}

Future<void> _deleteSymptom(String symptomId, String symptomType) async {
  final confirm = await _showDeleteDialog('symptoom', symptomType);
  if (confirm != true) return;

  try {
    await SymptomService.deleteSymptom(symptomId);
    if (mounted) {
      _showSuccessMessage('Symptoom verwijderd');
      await _refreshData();
    }
  } catch (e) {
    if (mounted) {
      _showErrorMessage('Fout bij verwijderen: $e');
    }
  }
}

Future<void> _deleteMenstruation(String menstruationId) async {
  final confirm = await _showDeleteDialog('menstruatie data', '');
  if (confirm != true) return;

  try {
    await MenstruationService.deleteMenstruation(menstruationId);
    if (mounted) {
      _showSuccessMessage('Menstruatie data verwijderd');
      await _refreshData();
    }
  } catch (e) {
    if (mounted) {
      _showErrorMessage('Fout bij verwijderen: $e');
    }
  }
}

  // ===== EDIT METHODS =====
  Future<void> _editFood(Map<String, dynamic> foodData) async {
  try {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodTab(
          selectedDay: widget.selectedDay,
          initialData: FoodData.fromFirestore(foodData, context),
          isEditing: true,
          documentId: foodData['id'],
        ),
      ),
    );
    
    if (result == true) {
      await _refreshData();
    }
  } catch (e) {
    if (mounted) {
      _showErrorMessage('Fout bij bewerken: $e');
    }
  }
}

Future<void> _editSymptom(Map<String, dynamic> symptomData) async {
  try {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SymptomsTab(
          selectedDay: widget.selectedDay,
          initialData: SymptomData.fromFirestore(symptomData),
          isEditing: true,
          documentId: symptomData['id'],
        ),
      ),
    );
    
    if (result == true) {
      await _refreshData();
    }
  } catch (e) {
    if (mounted) {
      _showErrorMessage('Fout bij bewerken: $e');
    }
  }
}

Future<void> _editMenstruation(Map<String, dynamic> menstruationData) async {
  try {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenstruationTab(
          selectedDay: widget.selectedDay,
          initialData: menstruationData,
          isEditing: true,
          documentId: menstruationData['id'],
        ),
      ),
    );
    
    if (result == true) {
      await _refreshData();
    }
  } catch (e) {
    if (mounted) {
      _showErrorMessage('Fout bij bewerken: $e');
    }
  }
}
  // ===== UTILITY METHODS =====
  
  Future<bool?> _showDeleteDialog(String itemType, String itemName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade400),
            const SizedBox(width: 8),
            const Text('Verwijderen?'),
          ],
        ),
        content: Text(
          itemName.isNotEmpty 
            ? 'Weet je zeker dat je "$itemName" wilt verwijderen?'
            : 'Weet je zeker dat je deze $itemType wilt verwijderen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuleren', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _loadDayData();
    widget.onDataChanged?.call(); // Callback naar parent voor refresh
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
        if (_foodItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildFoodSection(),
        ],
        if (_menstruationData == null && _symptoms.isEmpty && _foodItems.isEmpty)
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
        _buildInfoRow(
          'Cyclus Dag',
          widget.cycleCalculator.getCycleDayLabel(widget.selectedDay),
        ),
        _buildInfoRow(
          'Fase',
          widget.cycleCalculator.getPhaseDescription(widget.selectedDay),
        ),
        _buildInfoRow(
          'Zwangerschapskans',
          widget.cycleCalculator.getPregnancyChance(widget.selectedDay),
        ),
      ],
    );
  }

  Widget _buildMenstruationSection() {
    return SectionContainer(
      title: 'Menstruatie',
      icon: Icons.water_drop,
      iconColor: Colors.pink,
      
      children: [
        // Menstruation data display
        if (_menstruationData!['sexOptions'] != null)
          _buildInfoRow('Seks', _menstruationData!['sexOptions'].toString()),
        if (_menstruationData!['symptoms'] != null && _menstruationData!['symptoms'].isNotEmpty)
          _buildInfoRow('Symptomen', _menstruationData!['symptoms'].join(', ')),
        if (_menstruationData!['dischargeAmount'] != null)
          _buildInfoRow('Afscheiding hoeveelheid', _menstruationData!['dischargeAmount'].toString()),
        if (_menstruationData!['dischargeType'] != null)
          _buildInfoRow('Afscheiding type', _menstruationData!['dischargeType'].toString()),
        if (_menstruationData!['notities'] != null && _menstruationData!['notities'].isNotEmpty)
          _buildInfoRow('Notities', _menstruationData!['notities'].toString()),
        
        const SizedBox(height: 16),
        
        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _editMenstruation(_menstruationData!),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Bewerken'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _deleteMenstruation(_menstruationData!['id']),
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Verwijderen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSymptomsSection() {
    return SectionContainer(
      title: 'Symptomen (${_symptoms.length})',
      icon: Icons.healing,
      iconColor: Colors.orange,
      children: _symptoms.map((symptom) => _buildSymptomCard(symptom)).toList(),
    );
  }

  Widget _buildFoodSection() {
    return SectionContainer(
      title: 'Voeding (${_foodItems.length})',
      icon: Icons.restaurant_menu,
      iconColor: Colors.green,
      children: _foodItems.map((food) => _buildFoodCard(food)).toList(),
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
              Icon(Icons.healing, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  symptom['type'] ?? 'Onbekend symptoom',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
              if (symptom['tijd'] != null)
                Text(
                  symptom['tijd'].toString(),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
            ],
          ),
          
          // Symptom details
          if (symptom['locatie'] != null && symptom['locatie'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Locatie: ${symptom['locatie']}'),
          ],
          if (symptom['pijnschaal'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Pijnschaal: '),
                ...List.generate(symptom['pijnschaal'], (index) {
                  return Icon(Icons.bolt, color: Colors.orange, size: 16);
                }),
                Text(' (${symptom['pijnschaal']}/10)'),
              ],
            ),
          ],
          if (symptom['notities'] != null && symptom['notities'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Notities: ${symptom['notities']}'),
          ],
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _editSymptom(symptom),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Bewerken'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _deleteSymptom(symptom['id'], symptom['type'] ?? 'symptoom'),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Verwijderen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
Widget _buildFoodCard(Map<String, dynamic> food) {
  final foodId = food['id'];
  final foodName = food['wat'] ?? 'Onbekend gerecht';
  
  
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.green.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant, color: Colors.green.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                foodName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            if (food['tijd'] != null)
              Text(
                food['tijd'].toString(),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
        ),
        
        // Food details
        if (food['ingredienten'] != null && food['ingredienten'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Ingrediënten: ${food['ingredienten']}'),
          ),
        if (food['allergenen'] != null && food['allergenen'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Allergenen: ${food['allergenen'].join(", ")}'),
          ),
        if (food['notities'] != null && food['notities'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Notities: ${food['notities']}'),
          ),
        
        const SizedBox(height: 12),
        
        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _editFood(food);
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Bewerken'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _deleteFood(foodId, foodName);
                },
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Verwijderen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'januari', 'februari', 'maart', 'april', 'mei', 'juni',
      'juli', 'augustus', 'september', 'oktober', 'november', 'december',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}