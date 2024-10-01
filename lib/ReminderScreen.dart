import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _remindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reminder Settings"),
        backgroundColor: Color(0xFF399EF6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Enable Reminders"),
              value: _remindersEnabled,
              onChanged: (bool value) {
                setState(() {
                  _remindersEnabled = value;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text("Set Reminder Time"),
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
