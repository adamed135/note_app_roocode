import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:note_app_roocode/generated/app_localizations.dart';
import 'package:note_app_roocode/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box settingsBox;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settingsBox');
  }

  bool get notificationsEnabled => settingsBox.get('notificationsEnabled', defaultValue: true);

  set notificationsEnabled(bool value) {
    settingsBox.put('notificationsEnabled', value);
  }


  void _testNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification to check if permissions are working',
      platformChannelSpecifics,
    );
  }

  void _changeLanguage(String languageCode) {
    MyApp.setLocale(Locale(languageCode));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surfaceContainerLow,
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: settingsBox.listenable(keys: ['notificationsEnabled']),
          builder: (context, Box box, _) {
            bool enabled = box.get('notificationsEnabled', defaultValue: true);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.enableNotifications),
                  subtitle: Text(AppLocalizations.of(context)!.receiveNotifications),
                  value: enabled,
                  activeThumbColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                  onChanged: (bool value) {
                    settingsBox.put('notificationsEnabled', value);
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.testNotification),
                  subtitle: Text(AppLocalizations.of(context)!.sendTestNotification),
                  trailing: Icon(Icons.notifications),
                  onTap: _testNotification,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.public, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<String>(
                          value: Localizations.localeOf(context).languageCode,
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _changeLanguage(newValue);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: 'fr',
                              child: Text('Français'),
                            ),
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text('العربية'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}