
import 'package:flutter/material.dart';

class CalendarLegend extends StatelessWidget {
  final Map<String, bool> filters;
  final Function(String) onFilterToggle;

  const CalendarLegend({
    super.key,
    required this.filters,
    required this.onFilterToggle,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              const Text(
                'Legenda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // Instructie tekst
              Text(
                'Tik om aan/uit te zetten',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  filterKey: 'menstruation',
                  color: Colors.pinkAccent,
                  label: 'Menstruatie',
                  icon: Icons.water_drop,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  filterKey: 'ovulation',
                  color: Colors.green,
                  label: 'Eisprong',
                  icon: Icons.favorite,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  filterKey: 'fertile',
                  color: Colors.green.shade100,
                  label: 'Vruchtbaar',
                  icon: Icons.eco,
                  textColor: Colors.black,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  filterKey: 'symptoms',
                  color: Colors.orange.shade300,
                  label: 'Symptomen',
                  icon: Icons.healing,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required String filterKey,
    required Color color,
    required String label,
    required IconData icon,
    Color textColor = Colors.white,
  }) {
    bool isActive = filters[filterKey] ?? true;
    
    return GestureDetector(
      onTap: () => onFilterToggle(filterKey),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isActive ? 1.0 : 0.3,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? color : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: !isActive 
                    ? Border.all(color: Colors.grey.shade400, width: 1)
                    : null,
              ),
              child: Icon(
                icon,
                size: 12,
                color: isActive ? textColor : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.black54 : Colors.grey.shade400,
                  decoration: !isActive ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            //  streepje om aan te geven of het actief is
            const SizedBox(width: 4),
            Icon(
              isActive ? Icons.visibility : Icons.visibility_off,
              size: 14,
              color: isActive ? Colors.green.shade600 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}