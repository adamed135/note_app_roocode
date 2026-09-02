import 'dart:async';
import 'package:flutter/material.dart';
import 'package:note_app_roocode/generated/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';
import 'add_edit_task_screen.dart';


class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String searchText = '';
  String filter = 'all'; // all, pending, completed
  final Set<int> _previouslyOverdue = {};

  @override
  void initState() {
    super.initState();
    // Check for overdue tasks and notify
    _checkOverdueTasks();
  }

  void _checkOverdueTasks() async {
    final box = Hive.box<Task>('tasksBox');
    final overdueTasks = box.values.where((task) => task.isOverdue).toList();
    if (overdueTasks.isNotEmpty) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'overdue_channel',
        'Overdue Tasks',
        channelDescription: 'Notifications for overdue tasks',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: false,
        icon: '@drawable/ic_notification',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        999, // Unique ID for overdue notification
        'Overdue Tasks',
        'You have ${overdueTasks.length} overdue task(s). Please check your tasks.',
        platformChannelSpecifics,
      );
    }
  }

  void _showOverdueNotification(Task task) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'overdue_channel',
      'Overdue Tasks',
      channelDescription: 'Notifications for overdue tasks',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      icon: '@drawable/ic_notification',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      task.key, // Use task key as ID
      'Task Overdue',
      '${task.title} is now overdue!',
      platformChannelSpecifics,
    );
  }



  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>('tasksBox');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tasksToDo),
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
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() => searchText = value);
                },
              ),
            ),

            // Filter buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilterChip(
                    label: Text(AppLocalizations.of(context)!.all),
                    selected: filter == 'all',
                    onSelected: (selected) {
                      setState(() {
                        filter = selected ? 'all' : filter;
                      });
                    },
                  ),
                  FilterChip(
                    label: Text(AppLocalizations.of(context)!.pending),
                    selected: filter == 'pending',
                    onSelected: (selected) {
                      setState(() {
                        filter = selected ? 'pending' : filter;
                      });
                    },
                  ),
                  FilterChip(
                    label: Text(AppLocalizations.of(context)!.completed),
                    selected: filter == 'completed',
                    onSelected: (selected) {
                      setState(() {
                        filter = selected ? 'completed' : filter;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Tasks list
            Expanded(
              child: StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (context, Box<Task> box, _) {
                      Iterable<Task> tasks = box.values;

                      // Apply filter
                      if (filter == 'pending') {
                        tasks = tasks.where((task) => !task.isCompleted);
                      } else if (filter == 'completed') {
                        tasks = tasks.where((task) => task.isCompleted);
                      }

                      // Apply search
                      tasks = tasks.where((task) {
                        return task.title.contains(searchText) ||
                            task.description.contains(searchText);
                      });

                      final tasksList = tasks.toList();

                      // Check for newly overdue tasks and notify
                      for (final task in tasksList) {
                        if (task.isOverdue && !_previouslyOverdue.contains(task.key)) {
                          _showOverdueNotification(task);
                          _previouslyOverdue.add(task.key);
                        } else if (!task.isOverdue && _previouslyOverdue.contains(task.key)) {
                          _previouslyOverdue.remove(task.key);
                        }
                      }

                      if (tasksList.isEmpty) {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.noNotes,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            // Tablet layout (GridView)
                            return GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Two columns for tablets
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 3, // Adjust as needed
                              ),
                              itemCount: tasksList.length,
                              itemBuilder: (context, index) {
                                final task = tasksList[index];
                                return Card(
                                  margin: EdgeInsets.zero, // GridView handles spacing
                                  child: ListTile(
                                    leading: task.isCompleted
                                        ? const Icon(Icons.check_circle, color: Colors.green)
                                        : task.isOverdue
                                            ? const Icon(Icons.error, color: Colors.red)
                                            : const Icon(Icons.circle_outlined),
                                    title: Text(
                                      task.title,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (task.dueDate != null)
                                          Text(
                                            'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}'
                                                '${task.isOverdue ? " (Overdue!)" : ""}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: task.isOverdue ? Colors.red : null,
                                            ),
                                          ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AddEditTaskScreen(task: task),
                                        ),
                                      );
                                    },
                                    trailing: IconButton(
                                      icon: task.isCompleted
                                          ? const Icon(Icons.undo, color: Colors.blue)
                                          : const Icon(Icons.check, color: Colors.green),
                                      onPressed: () {
                                        task.isCompleted = !task.isCompleted;
                                        task.save();
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            // Phone layout (ListView)
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: tasksList.length,
                              itemBuilder: (context, index) {
                                final task = tasksList[index];

                                return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                    leading: task.isCompleted
                                        ? const Icon(Icons.check_circle, color: Colors.green)
                                        : task.isOverdue
                                            ? const Icon(Icons.error, color: Colors.red)
                                            : const Icon(Icons.circle_outlined),
                                    title: Text(
                                      task.title,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (task.dueDate != null)
                                          Text(
                                            'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}'
                                                '${task.isOverdue ? " (Overdue!)" : ""}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: task.isOverdue ? Colors.red : null,
                                            ),
                                          ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AddEditTaskScreen(task: task),
                                        ),
                                      );
                                    },
                                    trailing: IconButton(
                                      icon: task.isCompleted
                                          ? const Icon(Icons.undo, color: Colors.blue)
                                          : const Icon(Icons.check, color: Colors.green),
                                      onPressed: () {
                                        task.isCompleted = !task.isCompleted;
                                        task.save();
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
