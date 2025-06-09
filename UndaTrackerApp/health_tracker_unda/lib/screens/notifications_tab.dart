import 'package:flutter/material.dart';
import 'package:health_tracker_unda/widgets/headers/app_header.dart';
import 'package:health_tracker_unda/widgets/section_container.dart';
import 'package:health_tracker_unda/widgets/switch_field.dart';

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
    _addReminder(); //standaard 1 lege toevoegen
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink.shade300,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(width: 8),
                const Text('Verwijderen?'),
              ],
            ),
            content: const Text(
              'Weet je zeker dat je deze herinnering wilt verwijderen?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Annuleren',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                ),
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header
            AppHeader(
              title: 'Herinneringen',
              subtitle: 'Beheer je persoonlijke herinneringen',
              icon: Icons.notifications_active,
            ),

            const SizedBox(height: 24),

            // Cyclus herinneringen
            SectionContainer(
              title: 'Cyclusmeldingen',
              icon: Icons.favorite,
              iconColor: Colors.pink.shade400,
              children: [
                const SizedBox(height: 16),

                SwitchField(
                  title: 'Start menstruatie',
                  subtitle: 'Krijg een melding als je cyclus begint',
                  icon: Icons.circle,
                  value: menstruationReminder,
                  onChanged:
                      (val) => setState(() => menstruationReminder = val),
                  activeColor: Colors.pink.shade400,
                ),

                const Divider(height: 24),
                SwitchField(
                  title: 'Ovulatie',
                  subtitle: 'Krijg een melding tijdens je vruchtbare periode',
                  icon: Icons.circle,
                  value: menstruationReminder,
                  onChanged: (val) => setState(() => ovulationReminder = val),
                  activeColor: Colors.pink.shade400,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Medicatie herinneringen
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.medication,
                          color: Colors.green.shade400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Medicatieherinneringen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (medicationReminders.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Geen medicatieherinneringen',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Voeg een herinnering toe om te beginnen',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  else
                    ...medicationReminders.asMap().entries.map((entry) {
                      final index = entry.key;
                      final reminder = entry.value;

                      return Container(
                        key: reminder['key'],
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              reminder['enabled']
                                  ? Colors.green.shade50
                                  : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                reminder['enabled']
                                    ? Colors.green.shade200
                                    : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: reminder['name'],
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Naam medicatie',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                    ),
                                    onChanged: (value) {
                                      reminder['name'] = value;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Switch(
                                  value: reminder['enabled'],
                                  onChanged: (value) {
                                    setState(() {
                                      reminder['enabled'] = value;
                                    });
                                  },
                                  activeColor: Colors.green.shade400,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _pickTime(index),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.green.shade400,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            reminder['time'].format(context),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red.shade400,
                                  ),
                                  onPressed:
                                      () => _confirmDeleteReminder(index),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.shade50,
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addReminder,
                      icon: const Icon(Icons.add),
                      label: const Text('Herinnering toevoegen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  }

