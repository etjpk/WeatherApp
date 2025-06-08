import 'package:flutter/material.dart';
import 'second_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My App"),
        titleTextStyle: TextStyle(fontStyle: FontStyle.italic),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 50,
            color: Colors.brown,
            padding: EdgeInsets.all(20),
            child: Text("How are we"),
          ),
          Container(
            width: 50,
            color: Colors.lightGreen,
            padding: EdgeInsets.all(20),
            child: Text("live but also learn"),
          ),
          Expanded(child: Image.asset('assets/icon/plant.png')),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecondPage()),
              );
            },
            child: Coffee(),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class Coffee extends StatefulWidget {
  const Coffee({super.key});

  @override
  State<Coffee> createState() => _CoffeeState();
}

class _CoffeeState extends State<Coffee> {
  int strength = 1;
  int sugar = 1;
  void heyyy() {
    print('increase value by 1');
    setState(() {
      strength = strength < 5 ? strength + 1 : strength = 0;
    });
  }

  void heyy() {
    print('increase value by 1');
    setState(() {
      sugar = sugar < 4 ? sugar + 1 : sugar = 0; // to apply limit
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("Strength"),
            Text(' '),
            for (int i = 0; i < strength; i++)
              Image.asset(
                width: 20,
                height: 20,
                'assets/icon/beans.png',
                color: Colors.brown,
                colorBlendMode: BlendMode.multiply,
              ),
            Expanded(child: SizedBox()),
            // to get the text far away fron the above text
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.amber,
              ),
              onPressed: heyyy,
              child: Text("+"),
            ),
          ],
        ),
        Row(
          children: [
            Text("Sugar"),
            Text(' '),
            if (sugar == 0) Text('No Sugar..'),

            for (int i = 0; i < sugar; i++)
              Image.asset(
                'assets/icon/sugar.png',
                width: 25,
                height: 25,
                color: Colors.white,
                colorBlendMode: BlendMode.multiply,
              ),
            Expanded(child: SizedBox()),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.blueAccent,
              ),
              onPressed: heyy,
              child: Text("+"),
            ),
          ],
        ),
      ],
    );
  }
}
