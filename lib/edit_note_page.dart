import 'package:flutter/material.dart';
import 'notes_model.dart';
import 'note_service.dart';

class EditNotePage extends StatefulWidget {
  final Note note;

  const EditNotePage({super.key, required this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late NoteCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedCategory = widget.note.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _categoryToString(NoteCategory category) {
    switch (category) {
      case NoteCategory.handwritten:
        return 'Handwritten';
      case NoteCategory.defaultNotebook:
        return 'Default Notebook';
      case NoteCategory.recentlyAdded:
        return 'Recently Added';
      case NoteCategory.important:
        return 'Important';
      default:
        return 'Default Notebook';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final updatedNote = widget.note.copyWith(
                title: _titleController.text,
                content: _contentController.text,
                category: _selectedCategory,
                lastModifiedDate: DateTime.now(),
              );
              await NotesService().updateNote(
                widget.note.id,
                updatedNote.toJson(),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            DropdownButton<NoteCategory>(
              value: _selectedCategory,
              items: NoteCategory.values.map((category) {
                return DropdownMenuItem<NoteCategory>(
                  value: category,
                  child: Text(_categoryToString(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
