import 'package:flutter/material.dart';
import 'animals_service.dart'; // Import the service

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});
  @override
  _AddAnimalScreenState createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _legsController = TextEditingController();
  final AnimalService _animalService = AnimalService(); // Initialize service

  Future<void> _createAnimal() async {
    try {
      final String name = _nameController.text.trim();
      final int legs = int.parse(_legsController.text.trim());

      await _animalService.createAnimalDoc(name: name, number_of_legs: legs);

      // Clear inputs
      _nameController.clear();
      _legsController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Animal added!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _legsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Animal')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Animal Name'),
            ),
            TextField(
              controller: _legsController,
              decoration: InputDecoration(labelText: 'Number of Legs'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _createAnimal,
              child: Text('Save Animal'),
            ),
          ],
        ),
      ),
    );
  }
}
