import 'package:application_journey/homescreen_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:application_journey/auth_service1.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // Initialize Flutter bindings and Firebase
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase only if no apps are initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // Start the application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Set up localization for internationalization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        quill
            .FlutterQuillLocalizations
            .delegate, // For Quill editor localization
      ],

      // Supported languages
      supportedLocales: const [
        Locale('en', 'US'), // English (United States)
      ],

      // Determine initial screen based on auth state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // User is authenticated - show main application screen
          if (snapshot.hasData) {
            return HomescreenPage();
          }

          // User not authenticated - show authentication screen
          return const AuthPage();
        },
      ),
    );
  }
}
