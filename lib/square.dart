import 'package:flutter/material.dart';

class MySquare extends StatelessWidget {
  final String childd;
  const MySquare({super.key, required this.childd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,

        color: Colors.purple,
        child: Center(
          child: Text(
            childd,
            style: TextStyle(fontSize: 16, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}
