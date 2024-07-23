import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // Notification Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Enable Notifications (WIP)',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ],
          ),

          const Spacer(),
          
          // About Us section
          const Center(
            child: Column(
              children: [
                const Text(
                  'About Us',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Savings Squad is an application dedicated to providing the best budgeting tools to help you manage your finances effectively.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
