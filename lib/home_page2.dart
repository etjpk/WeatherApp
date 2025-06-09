import 'package:flutter/material.dart';
import 'weather_page.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  final _cityController = TextEditingController();
  String? _selectedCity;
  final List<String> _cities = [
    'Delhi',
    'Mumbai',
    'Bengaluru',
    'Sikar',
    'Jaipur',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'Enter city name'),
            ),
            DropdownButton<String>(
              hint: Text('Select a city'),
              value: _selectedCity,
              items: _cities.map((city) {
                return DropdownMenuItem(value: city, child: Text(city));
              }).toList(),
              onChanged: (city) {
                setState(() {
                  _selectedCity = city;
                  _cityController.text = city!;
                });
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _cities.map((city) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _cityController.text = city;
                      _selectedCity = city;
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 24, 255, 32),
                    foregroundColor: const Color.fromARGB(255, 10, 6, 45),
                  ),
                  child: Text(city),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                final city = _cityController.text.trim();
                if (city.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => WeatherPage(city: city)),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: const Color.fromARGB(255, 10, 6, 45),
              ),
              child: Text('Fetch Weather'),
            ),
            // Optional: Add location button here
          ],
        ),
      ),
    );
  }
}

class City extends StatefulWidget {
  const City({super.key});

  @override
  State<City> createState() => _CityState();
}

class _CityState extends State<City> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
