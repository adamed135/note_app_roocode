import 'package:flutter/material.dart';
import 'package:note_app_roocode/generated/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';


class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? dueDate;
  TimeOfDay? dueTime;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleController.text = widget.task!.title;
      descriptionController.text = widget.task!.description;
      dueDate = widget.task!.dueDate;
      // Restore dueTime from the stored dueDate so the time picker shows the correct value
      if (dueDate != null) {
        dueTime = TimeOfDay.fromDateTime(dueDate!);
      }
    }
  }

  void saveTask() async {
    if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.titleAndDescriptionRequired)),
      );
      return;
    }

    final box = Hive.box<Task>('tasksBox');
    Task savedTask;

    if (widget.task == null) {
      savedTask = Task(
        title: titleController.text,
        description: descriptionController.text,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );
      box.add(savedTask);
    } else {
      savedTask = widget.task!
        ..title = titleController.text
        ..description = descriptionController.text
        ..dueDate = dueDate
        ..save();
    }

    // Schedule notification if due date is set and notifications are enabled
    bool notificationsEnabled = Hive.box('settingsBox').get('notificationsEnabled', defaultValue: true);
    if (dueDate != null && notificationsEnabled) {
      // Combine date and time: if user picked only a date, default to a sensible time
      DateTime notificationDateTime = dueDate!;
      if (dueTime != null) {
        notificationDateTime = DateTime(
          dueDate!.year,
          dueDate!.month,
          dueDate!.day,
          dueTime!.hour,
          dueTime!.minute,
        );
      } else if (notificationDateTime.hour == 0 && notificationDateTime.minute == 0) {
        // Date was picked from date picker (defaults to midnight) — set to 9 AM
        notificationDateTime = DateTime(
          dueDate!.year,
          dueDate!.month,
          dueDate!.day,
          9,
          0,
        );
      }

      if (notificationDateTime.isAfter(DateTime.now())) {
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'task_channel',
          'Task Notifications',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
          icon: '@drawable/ic_notification',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        );
        const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

        try {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            savedTask.key, // Use key as ID
            'Task Reminder',
            savedTask.title,
            tz.TZDateTime.from(notificationDateTime, tz.local),
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        } catch (e) {
          // Silently fail in release — notification will not fire
        }
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final locale = Localizations.localeOf(context);
    String? cancelText;
    if (locale.languageCode == 'ar') {
      cancelText = 'إلغاء';
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      cancelText: cancelText,
    );
    if (picked != null) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final locale = Localizations.localeOf(context);
    String? cancelText;
    if (locale.languageCode == 'ar') {
      cancelText = 'إلغاء';
    }
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: dueTime ?? TimeOfDay.now(),
      cancelText: cancelText,
    );
    if (picked != null) {
      setState(() {
        dueTime = picked;
        // Update dueDate with selected time
        if (dueDate != null) {
          dueDate = DateTime(
            dueDate!.year,
            dueDate!.month,
            dueDate!.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit
            ? AppLocalizations.of(context)!.editNote
            : AppLocalizations.of(context)!.addNote),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.deleteTask),
                      content: Text(AppLocalizations.of(context)!.confirmDelete),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(AppLocalizations.of(context)!.delete),
                        ),
                      ],
                    );
                  },
                );
                if (confirm == true) {
                  widget.task!.delete();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveTask,
          )
        ],
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.content,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                title: Text(AppLocalizations.of(context)!.dueDate),
                subtitle: Text(
                  dueDate != null
                      ? '${dueDate!.toLocal().toString().split(' ')[0]}'
                          '${dueTime != null ? ' ${dueTime!.format(context)}' : ''}'
                      : AppLocalizations.of(context)!.selectDate,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(AppLocalizations.of(context)!.dueTime),
                subtitle: Text(
                  dueTime != null
                      ? dueTime!.format(context)
                      : AppLocalizations.of(context)!.selectTime,
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
