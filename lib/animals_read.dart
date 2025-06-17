import 'package:application_journey/add_animal_screen.dart';
import 'package:flutter/material.dart';
import 'animals_service.dart'; // Import the service
import 'animals_model.dart'; // Import the model

class AnimalsPage extends StatefulWidget {
  const AnimalsPage({super.key});

  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage> {
  final AnimalService _animalService = AnimalService(); // Service instance

  Widget animalTile(Animal animal) => ListTile(
    title: Text(animal.name),
    subtitle: Text('Legs: ${animal.number_of_legs}'),
    trailing: IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () async {
        try {
          await _animalService.deleteAnimalDoc(animal.id);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Animal deleted!')));
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animals List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAnimalScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Animal>>(
        stream: _animalService.fetchAnimals(), // Use service method
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No animals found'));
          }

          final animals = snapshot.data!;
          return ListView.builder(
            itemCount: animals.length,
            itemBuilder: (context, index) {
              return animalTile(animals[index]);
            },
          );
        },
      ),
    );
  }
}
