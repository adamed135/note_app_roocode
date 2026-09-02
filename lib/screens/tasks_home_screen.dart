import 'package:flutter/material.dart';
import 'package:note_app_roocode/generated/app_localizations.dart';
import 'package:note_app_roocode/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'tasks_screen.dart';
import 'notes_screen.dart';
import 'add_edit_task_screen.dart';
import 'add_edit_note_screen.dart';

class TasksHomeScreen extends StatefulWidget {
  const TasksHomeScreen({super.key});

  @override
  State<TasksHomeScreen> createState() => _TasksHomeScreenState();
}

class _TasksHomeScreenState extends State<TasksHomeScreen> {
  int _selectedIndex = 0;

  String _getCurrentLanguageName() {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸 ${AppLocalizations.of(context)!.english}';
      case 'fr':
        return '🇫🇷 ${AppLocalizations.of(context)!.french}';
      case 'ar':
        return '🇸🇦 ${AppLocalizations.of(context)!.arabic}';
      default:
        return '🇺🇸 ${AppLocalizations.of(context)!.english}';
    }
  }

  String _getCurrentThemeName() {
    switch (MyApp.getThemeMode()) {
      case ThemeMode.dark:
        return AppLocalizations.of(context)!.dark;
      case ThemeMode.system:
        return AppLocalizations.of(context)!.system;
      default:
        return AppLocalizations.of(context)!.light;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notesApp),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const NotesScreen(),
          const TasksScreen(),
          Container(
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ValueListenableBuilder(
                    valueListenable: Hive.box('settingsBox').listenable(keys: ['notificationsEnabled']),
                    builder: (context, Box box, _) {
                      bool enabled = box.get('notificationsEnabled', defaultValue: true);
                      return SwitchListTile(
                        secondary: Icon(Icons.notifications),
                        title: Text(AppLocalizations.of(context)!.enableNotifications),
                        subtitle: Text(AppLocalizations.of(context)!.receiveNotifications),
                        value: enabled,
                        onChanged: (bool value) {
                          box.put('notificationsEnabled', value);
                        },
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.public),
                    title: Text(AppLocalizations.of(context)!.language),
                    subtitle: Text(_getCurrentLanguageName()),
                    trailing: DropdownButton<String>(
                      value: Localizations.localeOf(context).languageCode,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          MyApp.setLocale(Locale(newValue));
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('🇺🇸 English'),
                        ),
                        DropdownMenuItem(
                          value: 'fr',
                          child: Text('🇫🇷 Français'),
                        ),
                        DropdownMenuItem(
                          value: 'ar',
                          child: Text('🇸🇦 العربية'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.dark_mode_outlined),
                    title: Text(AppLocalizations.of(context)!.theme),
                    subtitle: Text(_getCurrentThemeName()),
                    trailing: DropdownButton<ThemeMode>(
                      value: MyApp.getThemeMode(),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      underline: const SizedBox(),
                      onChanged: (ThemeMode? newValue) {
                        if (newValue != null) {
                          MyApp.setThemeMode(newValue);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(
                              '🌗 ${AppLocalizations.of(context)!.system}'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(
                              '☀️ ${AppLocalizations.of(context)!.light}'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(
                              '🌙 ${AppLocalizations.of(context)!.dark}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
                );
              },
            )
          : _selectedIndex == 1
              ? FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
                    );
                  },
                )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
