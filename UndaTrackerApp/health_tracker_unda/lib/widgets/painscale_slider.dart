import 'package:flutter/material.dart';

class PainScaleSlider extends StatelessWidget {
  final int painScale;
  final Function(int) onChanged;
  final Map<int, String> painDescriptions;

  const PainScaleSlider({
    super.key,
    required this.painScale,
    required this.onChanged,
    required this.painDescriptions,
  });

  MaterialColor _getColorForPain(int scale) {
    if (scale <= 3) return Colors.green;
    if (scale <= 7) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForPain(painScale);

    return Column(
      children: [
        const Row(
          children: [
            Text("😊", style: TextStyle(fontSize: 24)),
            Expanded(child: SizedBox()),
            Text("😣", style: TextStyle(fontSize: 24)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color.shade400,
            thumbColor: color.shade400,
            inactiveTrackColor: Colors.grey.shade300,
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: painScale.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: painScale.toString(),
            onChanged: (value) => onChanged(value.round()),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.shade200),
          ),
          child: Column(
            children: [
              Text(
                "Score: $painScale",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color.shade700,
                ),
              ),
              if (painDescriptions.containsKey(painScale)) ...[
                const SizedBox(height: 8),
                Text(
                  painDescriptions[painScale]!,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}