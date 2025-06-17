import 'package:cloud_firestore/cloud_firestore.dart';
import 'notes_model.dart';

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // update

  // Create a new note
  Future<void> createNote(Note note) async {
    final docRef = _firestore.collection('notes').doc();
    await docRef.set(note.copyWith(id: docRef.id).toJson());
  }

  // Get real-time stream of all notes
  Stream<List<Note>> getNotesStream() {
    return _firestore
        .collection('notes')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Note.fromJson(doc.data())).toList(),
        );
  }

  // Update an existing note
  Future<void> updateNote(String noteId, Map<String, dynamic> updates) async {
    await _firestore.collection('notes').doc(noteId).update(updates);
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }
}
