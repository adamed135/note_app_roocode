import 'dart:io';
import 'package:flutter/material.dart';
import 'package:note_app_roocode/generated/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import 'add_edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Note>('notesBox');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notes),
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

            // Notes list
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<Note> box, _) {
                  final notes = box.values.where((note) {
                    return note.title.contains(searchText) ||
                        note.content.contains(searchText);
                  }).toList();

                  if (notes.isEmpty) {
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
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return Card(
                              margin: EdgeInsets.zero, // GridView handles spacing
                              child: ListTile(
                                leading: note.imagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(note.imagePath!),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                      Icons.image_not_supported,
                                                      size: 50),
                                        ),
                                      )
                                    : const Icon(Icons.image_not_supported,
                                        size: 50),
                                title: Text(
                                  note.title,
                                  style:
                                      Theme.of(context).textTheme.titleLarge,
                                ),
                                subtitle: Text(
                                  note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddEditNoteScreen(note: note),
                                    ),
                                  );
                                },
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => note.delete(),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        // Phone layout (ListView)
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: note.imagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(note.imagePath!),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                      Icons.image_not_supported,
                                                      size: 50),
                                        ),
                                      )
                                    : const Icon(Icons.image_not_supported,
                                        size: 50),
                                title: Text(
                                  note.title,
                                  style:
                                      Theme.of(context).textTheme.titleLarge,
                                ),
                                subtitle: Text(
                                  note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddEditNoteScreen(note: note),
                                    ),
                                  );
                                },
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => note.delete(),
                                ),
                              ),
                            );
                          },
                        );
                      }
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
