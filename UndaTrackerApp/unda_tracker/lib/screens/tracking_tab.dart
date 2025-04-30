import 'package:flutter/material.dart';

class TrackingTab extends StatelessWidget {
  const TrackingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '📊 Tracking Tab',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
