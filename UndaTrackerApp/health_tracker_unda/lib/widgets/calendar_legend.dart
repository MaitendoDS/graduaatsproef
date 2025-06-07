
import 'package:flutter/material.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  color: Colors.amber.shade400,
                  label: 'Vandaag',
                  icon: Icons.today,
                  textColor: Colors.black,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  color: Colors.blue.shade400,
                  label: 'Geselecteerde dag',
                  icon: Icons.today,
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
}
