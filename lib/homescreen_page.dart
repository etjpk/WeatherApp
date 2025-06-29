import 'package:application_journey/profile_page.dart';
import 'package:application_journey/screens/create_post_screen.dart';
import 'package:application_journey/screens/following_screen.dart';
import 'package:application_journey/screens/explore_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomescreenPage extends StatefulWidget {
  @override
  State<HomescreenPage> createState() => _HomescreenPageState();
}

class _HomescreenPageState extends State<HomescreenPage> {
  int _selectedIndex = 0; // Tracks the current tab index

  // Returns the list of pages for each navigation item
  List<Widget> get _pages {
    // Get current user ID for profile screen
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return <Widget>[
      ExploreScreen(), // Explore tab content
      FollowingScreen(), // Following tab content
      SizedBox.shrink(), // Placeholder for Create tab (handled separately)
      ProfileScreen(userId: currentUserId), // Profile tab with user ID
    ];
  }

  // Handles navigation item taps
  void _onItemTapped(int index) {
    if (index == 2) {
      // Create tab tapped - open CreatePostScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreatePostScreen()),
      );
      // Don't update state to keep current tab selected
    } else {
      // Update state for other tabs
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // AppBar with styled 'Enjoy' title
      appBar: AppBar(
        title: Text(
          'Enjoy',
          style: TextStyle(
            fontSize: 34,
            color: Colors.pink,
            fontWeight: FontWeight.w900,
            fontFamily: 'Montserrat',
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                blurRadius: 8.0,
                color: Colors.black26,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications functionality
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // Displays the current page based on selected index
      body: _pages[_selectedIndex],

      // Bottom navigation bar
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, thickness: 1, color: Colors.grey[300]),
          BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: const Color.fromARGB(255, 49, 228, 232),
            unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.public),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Following',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
