import 'package:cloud_firestore/cloud_firestore.dart';
import 'animals_model.dart';

class AnimalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new animal document (auto-generated ID)
  Future<void> createAnimalDoc({
    required String name,
    required int number_of_legs,
    DateTime? creation_date,
  }) async {
    final newDocRef = _firestore.collection('animals').doc();
    final animal = Animal(
      id: newDocRef.id,
      name: name,
      number_of_legs: number_of_legs,
      creation_date: creation_date ?? DateTime.now(),
    );
    await newDocRef.set(animal.toJson());
  }

  // Create a document with a specific ID (optional)
  Future<void> createAnimalDocWithId({
    required String id,
    required String name,
    required int number_of_legs,
    DateTime? creation_date,
  }) async {
    await _firestore.collection('animals').doc(id).set({
      'name': name,
      'number_of_legs': number_of_legs,
      'creation_date': creation_date ?? DateTime.now(),
    });
  }

  // Read: Get a stream of all animals
  Stream<List<Animal>> fetchAnimals() {
    return _firestore
        .collection('animals')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Animal.fromJson({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  // Update: Update an animal document
  Future<void> updateAnimalDoc({
    required String id,
    required String name,
    required int number_of_legs,
  }) async {
    await _firestore.collection('animals').doc(id).update({
      'name': name,
      'number_of_legs': number_of_legs,
    });
  }

  // Delete: Delete an animal document
  Future<void> deleteAnimalDoc(String id) async {
    await _firestore.collection('animals').doc(id).delete();
  }
}
