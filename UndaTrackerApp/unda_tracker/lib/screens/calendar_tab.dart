import 'package:flutter/material.dart';

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '📅 Kalender Tab',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
