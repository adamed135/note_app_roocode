import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_app_roocode/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'models/note.dart';
import 'models/task.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Note>('notesBox');
  await Hive.openBox<Task>('tasksBox');
  await Hive.openBox('settingsBox');

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create notification channels for Android
  const AndroidNotificationChannel taskChannel = AndroidNotificationChannel(
    'task_channel',
    'Task Notifications',
    description: 'Notifications for task reminders',
    importance: Importance.max,
    playSound: true,
  );
  const AndroidNotificationChannel overdueChannel = AndroidNotificationChannel(
    'overdue_channel',
    'Overdue Tasks',
    description: 'Notifications for overdue tasks',
    importance: Importance.high,
    playSound: true,
  );
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(taskChannel);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(overdueChannel);

  // Request permissions
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  runApp(MyApp(key: mainAppKey));
}

final GlobalKey<MyAppState> mainAppKey = GlobalKey<MyAppState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  static void setLocale(Locale newLocale) {
    mainAppKey.currentState?.setLocale(newLocale);
  }

  static String getLocalizedTaskReminder() {
    final locale = mainAppKey.currentState?._locale ?? const Locale('en');
    final localizations = lookupAppLocalizations(locale);
    return localizations.taskReminder;
  }
}

class MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar');

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),

        // Define the custom color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3), // Light blue for primary elements
          brightness: Brightness.light,
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFF4CAF50), // Green for accents
          surface: const Color(0xFFFFFFFF), // White surface color
        ),

        // Update ElevatedButton theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50), // Use green accent color
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Update Card theme
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Update FloatingActionButton theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF4CAF50), // Use green accent color
          foregroundColor: Colors.white,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
        Locale('fr'), // French
      ],
      locale: _locale,
      home: const SplashScreen(),
    );
  }
}
