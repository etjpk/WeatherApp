import 'package:application_journey/edit_note_page.dart';
import 'package:flutter/material.dart';
import 'package:application_journey/note_detail_page.dart';
import 'notes_model.dart';
import 'note_service.dart';
import 'create_note_page.dart';

class NotesReadPage extends StatelessWidget {
  const NotesReadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotesService _notesService = NotesService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Expanded(child: Divider(thickness: 0.5, color: Colors.grey)),
            const Text(
              'Notes',
              style: TextStyle(
                color: Color.fromARGB(255, 241, 200, 214),
                fontStyle: FontStyle.normal,
                fontSize: 30,
              ),
            ),
            Expanded(child: Divider(thickness: 0.5, color: Colors.white)),
          ],
        ),
      ),
      body: StreamBuilder<List<Note>>(
        stream: _notesService.getNotesStream(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Error state
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notes'));
          }
          // No data or empty list
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notes yet'));
          }
          // Success: Display notes
          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: 0.2,
                      color: const Color.fromARGB(255, 102, 114, 113),
                    ),
                    Text(
                      note.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontStyle: FontStyle.normal,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Created: ${note.creationDate.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Divider(
                      thickness: 0.2,
                      color: const Color.fromARGB(255, 102, 114, 113),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailPage(note: note),
                    ),
                  );
                },
                trailing: PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditNotePage(note: note),
                        ),
                      );
                    } else if (value == 'delete') {
                      await _notesService.deleteNote(note.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNotePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
