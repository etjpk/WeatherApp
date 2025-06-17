import 'package:application_journey/home_page.dart';
import 'package:application_journey/home_screen.dart';
//import 'package:application_journey/login_page.dart';
import 'package:application_journey/registerorlogin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is loged in
          if (snapshot.hasData) {
            return HomeScreen();
          }
          // user is not loged in
          else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
