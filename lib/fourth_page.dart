import 'package:application_journey/first_page.dart';
import 'package:application_journey/second_page.dart';
import 'package:application_journey/third_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';
// import 'third_page.dart';
// import 'first_page.dart';
// import 'second_page.dart';

class ForthPage extends StatefulWidget {
  const ForthPage({Key? key}) : super(key: key);
  @override
  State<ForthPage> createState() => _ForthPageState();
}

class _ForthPageState extends State<ForthPage> {
  int myIndex = 0;
  final CounterController control = Get.put(CounterController());

  List<Widget> widgetList = [
    // Text('Home', style: TextStyle(fontSize: 40)),
    // Text('Music', style: TextStyle(fontSize: 40)),
    // Text('NewsPaper', style: TextStyle(fontSize: 40)),
    FirstPage(),
    SecondPage(),
    ThirdPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          control.increaseValue();
        },
        child: Text("Add"),
      ),
      appBar: AppBar(title: Text('My App')),
      //  body: IndexedStack(index: myIndex, children: widgetList),
      bottomNavigationBar: BottomNavigationBar(
        // by shiftinh this from fixed color of bottom bar will change on tapping different icons
        type: BottomNavigationBarType.fixed,
        // showUnselectedLabels: false,
        backgroundColor: Colors.yellow,
        currentIndex: myIndex,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.yellow,
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Music',
            backgroundColor: Colors.pinkAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Newspaper',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is Page 4', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Image.asset('assets/icon/icon.png', height: 150),
            SizedBox(height: 20),
            // Obx(
            //   () => Text(
            //     control.count.value.toString(),
            //     style: TextStyle(fontStyle: FontStyle.italic),
            //   ),
            // ),
            // GetBuilder<CounterController>(
            //   builder: (controller) => Text(
            //     controller.count.toString(), // ✅ No .value needed
            //     style: TextStyle(fontStyle: FontStyle.italic),
            //   ),
            // ),
            // Expanded(
            //   child: IndexedStack(index: myIndex, children: widgetList),
            // ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Takes user back to previous page
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
