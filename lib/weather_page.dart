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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.city == 'Delhi')
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/icon/delhi.png', // Path to your Delhi image
                  height: 150,
                ),
              ),
            if (widget.city == 'Mumbai')
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/icon/mumbai.png', // Path to your Delhi image
                  height: 150,
                ),
              ),
            if (widget.city == 'Sikar')
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/icon/sikar.png', // Path to your Delhi image
                  height: 150,
                ),
              ),

            if (widget.city == 'Jaipur')
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/icon/jaipur.png', // Path to your Delhi image
                  height: 150,
                ),
              ),
            if (widget.city == 'Bengaluru')
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/icon/banglore.png', // Path to your Delhi image
                  height: 150,
                ),
              ),
            Text('City: ${widget.city}', style: TextStyle(fontSize: 24)),
            Divider(thickness: 1, color: Colors.grey[400]),
            Row(
              children: [
                Text(
                  'Temperature: ${weatherData!['main']['temp']}°C',
                  style: TextStyle(fontSize: 24),
                ),
                Image.asset(
                  width: 20,
                  height: 20,
                  'assets/icon/temperature.png',
                  colorBlendMode: BlendMode.multiply,
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey[400]),
            Row(
              children: [
                Text(
                  'Condition: ${weatherData!['weather'][0]['main']}',
                  style: TextStyle(fontSize: 24),
                ),
                Image.asset(
                  width: 20,
                  height: 20,
                  'assets/icon/conditions.png',
                  colorBlendMode: BlendMode.multiply,
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey[400]),
            Row(
              children: [
                Text(
                  'Wind Speed: ${weatherData!['wind']['speed']} m/s',
                  style: TextStyle(fontSize: 24),
                ),
                Image.asset(
                  width: 20,
                  height: 20,
                  'assets/icon/wind.png',
                  colorBlendMode: BlendMode.multiply,
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey[400]),
            Row(
              children: [
                Text(
                  'Humidity: ${weatherData!['main']['humidity']}%',
                  style: TextStyle(fontSize: 24),
                ),

                Image.asset(
                  width: 20,
                  height: 20,
                  'assets/icon/humidity.png',
                  colorBlendMode: BlendMode.multiply,
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey[400]),
            Row(
              children: [
                Text(
                  'Air Quality Index: ${weatherData!['airQuality']}',
                  style: TextStyle(fontSize: 24),
                ),

                Image.asset(
                  width: 20,
                  height: 20,
                  'assets/icon/air_quality.png',
                  colorBlendMode: BlendMode.multiply,
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey[400]),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
