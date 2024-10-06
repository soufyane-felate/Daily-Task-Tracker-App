import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _remindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminder Settings"),
        backgroundColor: const Color(0xFF399EF6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Enable Reminders"),
              value: _remindersEnabled,
              onChanged: (bool value) {
                setState(() {
                  _remindersEnabled = value;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text("Set Reminder Time"),
              onTap: () {
                showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}