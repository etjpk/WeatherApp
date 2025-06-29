import 'package:application_journey/screens/explore_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart'; // Add this import

class AuthService {
  // Add BuildContext parameter to handle navigation
  final BuildContext context;

  AuthService(this.context); // Constructor to receive context

  //Google sign in
  Future<UserCredential?> signInwithGoogle() async {
    try {
      // begin interactive sign in practice
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // Return null if user cancels the sign-in
      if (gUser == null) return null;

      // obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // create a new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Actually sign in to Firebase with the credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user document exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Create new Firestore document for first-time Google users
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'id': user.uid,
                'name': user.displayName ?? 'User',
                'username':
                    user.email?.split('@')[0] ??
                    'user${user.uid.substring(0, 6)}',
                'email': user.email ?? '',
                'profileImageUrl': user.photoURL ?? '',
                'bio': '',
                'followers': [],
                'following': [],
                'lastUpdated': FieldValue.serverTimestamp(),
              });

          print('✅ Created new Firestore user document for: ${user.email}');
        } else {
          // Update existing document with latest Google profile data
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
                'name': user.displayName ?? userDoc.data()?['name'] ?? 'User',
                'profileImageUrl':
                    user.photoURL ?? userDoc.data()?['profileImageUrl'] ?? '',
                'lastUpdated': FieldValue.serverTimestamp(),
              });

          print(
            '✅ Updated existing Firestore user document for: ${user.email}',
          );
        }

        // NAVIGATION AFTER SUCCESSFUL SIGN-IN
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ExploreScreen()),
          (route) => false,
        );
      }

      return userCredential;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
      return null;
    }
  }
}
