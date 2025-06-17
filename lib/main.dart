import 'package:application_journey/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
// import 'auth_page.dart'; // Your login/signup page
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:application_journey/auth_service1.dart';

// import 'read_note_page.dart'; // Your notes list page
// import 'read_todo_page.dart'; // Your to-do list page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If user is signed in, show home with navigation
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          // If not signed in, show auth page
          return const AuthPage();
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';
// // import 'auth_page.dart'; // or your auth widget
// import 'animals_read.dart'; // your animal list page
// import 'package:application_journey/auth_service1.dart';

// //import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:google_sign_in/google_sign_in.dart';
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     if (Firebase.apps.isEmpty) {
//       await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform,
//       );
//     }
//   } catch (e) {
//     print('Firebase initialization error: $e');
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }
//           if (snapshot.hasData) {
//             return const AnimalsPage(); // User is signed in
//           }
//           return AuthPage(); // User is not signed in
//         },
//       ),
//     );
//   }
// }

// // //import 'package:application_journey/controller.dart';
// // import 'package:application_journey/auth_service1.dart';
// // //import 'package:application_journey/login_page.dart';
// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'firebase_options.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:google_sign_in/google_sign_in.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   try {
// //     if (Firebase.apps.isEmpty) {
// //       await Firebase.initializeApp(
// //         options: DefaultFirebaseOptions.currentPlatform,
// //       );
// //     }
// //   } catch (e) {
// //     print('Firebase initialization error: $e');
// //   }
// //   runApp(const MyApp());
// // }

// // // void main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //   if (Firebase.apps.isEmpty) {
// // //     await Firebase.initializeApp(
// // //       options: DefaultFirebaseOptions.currentPlatform,
// // //     );
// // //   }
// // //   runApp(const MyApp());
// // // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(debugShowCheckedModeBanner: false, home: AuthPage());
// //   }
// // }
