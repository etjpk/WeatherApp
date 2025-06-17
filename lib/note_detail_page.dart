import 'package:flutter/material.dart';
import 'notes_model.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  String getNoteTypeLabel(NoteCategory category) {
    switch (category) {
      case NoteCategory.handwritten:
        return 'Handwritten';
      case NoteCategory.important:
        return 'Important';
      case NoteCategory.recentlyAdded:
        return 'Recently Added';
      case NoteCategory.defaultNotebook:
      default:
        return 'Default Notebook';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${note.creationDate.toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${getNoteTypeLabel(note.category)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Divider(height: 32),
            Text(note.content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
