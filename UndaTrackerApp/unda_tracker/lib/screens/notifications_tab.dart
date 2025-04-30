import 'package:flutter/material.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '🔔 Meldingen Tab',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
