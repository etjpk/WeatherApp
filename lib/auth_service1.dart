import 'package:application_journey/registerorlogin_page.dart';
import 'package:application_journey/screens/explore_screen.dart';
import 'package:application_journey/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  // Method to ensure user profile exists in Firestore
  Future<void> _ensureUserProfile(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Create user profile if it doesn't exist
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'id': user.uid,
          'name': user.displayName ?? 'User',
          'username':
              user.email?.split('@')[0] ?? 'user${user.uid.substring(0, 6)}',
          'email': user.email ?? '',
          'profileImageUrl': user.photoURL ?? '',
          'bio': '',
          'followers': [],
          'following': [],
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error ensuring user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          // User is logged in
          if (snapshot.hasData && snapshot.data != null) {
            // Add a small delay to ensure context is valid
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ExploreScreen()),
                (route) => false,
              );
            });
            return Center(child: CircularProgressIndicator());
          }
          // User is not logged in
          return LoginOrRegisterPage();
        },
      ),
    );
  }
}
