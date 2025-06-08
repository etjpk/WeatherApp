import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherPage extends StatefulWidget {
  // const WeatherPage({super.key});
  final String city;
  WeatherPage({required this.city});
  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    final apiKey = 'd92c25e0ce94c874caacddfd7d489a66';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=${widget.city}&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'City not found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to fetch weather';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));
    return Scaffold(
      appBar: AppBar(title: Text('${widget.city} Weather')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('City: ${widget.city}', style: TextStyle(fontSize: 24)),
            Text(
              'Temperature: ${weatherData!['main']['temp']}°C',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Condition: ${weatherData!['weather'][0]['main']}',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Wind Speed: ${weatherData!['wind']['speed']} m/s',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Condition: ${weatherData!['weather'][0]['main']}',
              style: TextStyle(fontSize: 24),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
