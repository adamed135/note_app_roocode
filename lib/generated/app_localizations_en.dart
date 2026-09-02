// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get notesApp => 'Notes App';

  @override
  String get notes => 'Notes';

  @override
  String get editNote => 'Edit Note';

  @override
  String get addNote => 'Add Note';

  @override
  String get title => 'Title';

  @override
  String get content => 'Content';

  @override
  String get pickImage => 'Pick Image';

  @override
  String get search => 'Search...';

  @override
  String get noNotes => 'No notes';

  @override
  String get tasksToDo => 'Tasks to Do';

  @override
  String get all => 'All';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get dueDate => 'Due Date';

  @override
  String get selectDate => 'Select Date';

  @override
  String get dueTime => 'Due Time';

  @override
  String get selectTime => 'Select Time';

  @override
  String get taskReminder => 'Task Reminder';

  @override
  String get settings => 'Settings';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get receiveNotifications => 'Receive notifications for task reminders';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get sendTestNotification =>
      'Send a test notification to check permissions';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get confirmDelete => 'Are you sure you want to delete this task?';

  @override
  String get titleAndDescriptionRequired =>
      'Title and description are required';

  @override
  String taskDeleted(Object title) {
    return '$title deleted';
  }

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'العربية';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';
}
