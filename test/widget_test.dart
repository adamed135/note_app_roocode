import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:note_app_roocode/main.dart';
import 'package:note_app_roocode/models/note.dart';
import 'package:note_app_roocode/models/task.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(dir.path);
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Note>('notesBox');
    await Hive.openBox<Task>('tasksBox');
    await Hive.openBox('settingsBox');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App launches from splash to the notes home screen',
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // The splash screen is shown first.
    expect(find.text('Modern tech notes'), findsOneWidget);

    // Advance past the 3-second splash timer and finish the route transition.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));

    // The main screen appears with the bottom navigation and the add FAB.
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
