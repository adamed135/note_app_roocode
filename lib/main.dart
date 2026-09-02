import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_app_roocode/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'models/note.dart';
import 'models/task.dart';

import 'screens/splash_screen.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Draw the app edge-to-edge: fill the entire screen and paint behind the
  // Android status bar and navigation bar (no more black system-bar areas).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    // MIUI ignores transparent nav bars (renders black), so use the app's
    // bottom bar color instead for a seamless full-screen look.
    systemNavigationBarColor: Colors.white,
    // Dark icons for the app's light screens (AppBars).
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light, // iOS equivalent
    systemNavigationBarContrastEnforced: false, // no MIUI dark scrim
  ));

  // Release builds have no red error screen, so log every uncaught error to
  // the platform log (logcat) instead of silently showing a blank screen.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}\n${details.stack}');
  };
  binding.platformDispatcher.onError = (Object error, StackTrace stack) {
    debugPrint('Unhandled async error: $error\n$stack');
    return true;
  };

  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Note>('notesBox');
  await Hive.openBox<Task>('tasksBox');
  await Hive.openBox('settingsBox');

  // Initialize timezone
  tz.initializeTimeZones();

  runApp(MyApp(key: mainAppKey));

  // NOTE: Notifications are NOT initialized here. Doing that before runApp
  // awaited the Android permission dialog on the very first launch of a
  // release build, which could hang the app on a blank screen (the UI was
  // never built). It now runs after the first frame instead — see
  // MyAppState.initState.
}

final GlobalKey<MyAppState> mainAppKey = GlobalKey<MyAppState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  static void setLocale(Locale newLocale) {
    mainAppKey.currentState?.setLocale(newLocale);
  }

  static void setThemeMode(ThemeMode mode) {
    mainAppKey.currentState?.setThemeMode(mode);
  }

  static ThemeMode getThemeMode() {
    return mainAppKey.currentState?._themeMode ?? ThemeMode.light;
  }

  static String getLocalizedTaskReminder() {
    final locale = mainAppKey.currentState?._locale ?? const Locale('en');
    final localizations = lookupAppLocalizations(locale);
    return localizations.taskReminder;
  }
}

class MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    // Restore the saved theme (defaults to light).
    final savedTheme =
        Hive.box('settingsBox').get('themeMode', defaultValue: 'light');
    _themeMode = _themeModeFromName(savedTheme);

    // Initialize notifications AFTER the first frame renders so the Android
    // permission dialog can never delay or blank the UI on first launch.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeNotifications();
    });
  }

  static ThemeMode _themeModeFromName(String name) {
    switch (name) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    Hive.box('settingsBox').put('themeMode', mode.name);

    // Keep the Android system bars in sync with the active theme.
    final Brightness brightness = switch (mode) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    SystemChrome.setSystemUIOverlayStyle(_systemOverlayFor(brightness));
  }

  SystemUiOverlayStyle _systemOverlayFor(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor:
          isDark ? const Color(0xFF1E1E1E) : Colors.white,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarContrastEnforced: false,
    );
  }

  Future<void> initializeNotifications() async {
    try {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_notification');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      // Timeout guards: on the first launch some platform calls can hang
      // (e.g. the permission dialog on slow cold starts), and we never want
      // that to leave the app stuck behind a blank screen.
      await flutterLocalNotificationsPlugin
          .initialize(
            initializationSettings,
            onDidReceiveNotificationResponse:
                (NotificationResponse response) async {
              debugPrint('Notification tapped: ${response.payload}');
            },
          )
          .timeout(const Duration(seconds: 10));

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

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.createNotificationChannel(taskChannel);
      await androidImplementation?.createNotificationChannel(overdueChannel);

      // Request permissions (now shown over the fully rendered UI).
      await androidImplementation
          ?.requestNotificationsPermission()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      // Don't let notification init failure crash the app
      debugPrint('Notification init error: $e');
    }
  }

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
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeMode,
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

  ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),

      // Define the custom color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3), // Light blue for primary elements
        brightness: brightness,
        primary: const Color(0xFF2196F3),
        secondary: const Color(0xFF4CAF50), // Green for accents
        surface: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
      ),

      // Update AppBar theme: keep status-bar icons readable on the AppBar
      // while drawing edge-to-edge behind the system bars. The navigation-bar
      // color is set explicitly here so it always matches the active theme
      // (white/dark) and can never be left over from the green splash.
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor:
              isDark ? const Color(0xFF1E1E1E) : Colors.white,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
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
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
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
    );
  }
}
