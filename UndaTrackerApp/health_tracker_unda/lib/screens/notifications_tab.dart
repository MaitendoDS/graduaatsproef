import 'package:flutter/material.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  bool menstruationReminder = true;
  bool ovulationReminder = true;

  List<Map<String, dynamic>> medicationReminders = [];

  @override
  void initState() {
    super.initState();
    _addReminder(); // Voeg standaard één lege herinnering toe bij het opstarten
  }

  void _addReminder() {
    setState(() {
      medicationReminders.add({
        'name': '',
        'time': TimeOfDay.now(),
        'enabled': true,
        'key': UniqueKey(),
      });
    });
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: medicationReminders[index]['time'],
    );
    if (picked != null) {
      setState(() {
        medicationReminders[index]['time'] = picked;
      });
    }
  }

  Future<void> _confirmDeleteReminder(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Verwijderen?'),
            content: const Text(
              'Weet je zeker dat je deze herinnering wilt verwijderen?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuleren'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Verwijderen'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        medicationReminders.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Herinneringen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Cyclus herinneringen
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 238, 247, 231),
              border: Border.all(color: Colors.lightGreen.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cyclusmeldingen',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SwitchListTile(
                  title: const Text('Start menstruatie'),
                  value: menstruationReminder,
                  onChanged:
                      (val) => setState(() => menstruationReminder = val),
                ),
                SwitchListTile(
                  title: const Text('Ovulatie'),
                  value: ovulationReminder,
                  onChanged: (val) => setState(() => ovulationReminder = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Medicatie herinneringen
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 238, 247, 231),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.lightGreen.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medicatieherinneringen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...medicationReminders.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reminder = entry.value;

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Row(
                      key: reminder['key'],
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(
                              text: reminder['name'],
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Naam medicatie',
                            ),
                            onChanged: (value) {
                              reminder['name'] = value;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _pickTime(index),
                        ),
                        Text(reminder['time'].format(context)),
                        Switch(
                          value: reminder['enabled'],
                          onChanged: (value) {
                            setState(() {
                              reminder['enabled'] = value;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteReminder(index),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _addReminder,
                  icon: const Icon(Icons.add),
                  label: const Text('Herinnering toevoegen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[300],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
