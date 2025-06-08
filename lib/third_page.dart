import 'package:flutter/material.dart';
import 'fourth_page.dart';

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Newspaper ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('newspaper', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Image.asset('assets/icon/icon.png', height: 150),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForthPage()),
                );
              },
              child: Text('Go to Forth Page'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Goes back to first page
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
