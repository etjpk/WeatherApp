import 'package:application_journey/my_button.dart';
import 'package:application_journey/my_textfile.dart';
import 'package:application_journey/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:application_journey/home_page.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:application_journey/Services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:application_journey/screens/explore_screen.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isGoogleLoading = false;
  final emailController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();

  // show loading circle
  void _clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmpasswordController.clear();
    nameController.clear();
    usernameController.clear();
  }

  // sign user in
  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Validate inputs
      if (nameController.text.trim().isEmpty) {
        Navigator.pop(context);
        showErrorMessage('Please enter your name');
        return;
      }

      if (usernameController.text.trim().isEmpty) {
        Navigator.pop(context);
        showErrorMessage('Please enter a username');
        return;
      }

      // Check if password is confirmed
      if (passwordController.text == confirmpasswordController.text) {
        // Create Firebase Auth user
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );

        // Create Firestore user document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'id': userCredential.user!.uid,
              'name': nameController.text.trim(),
              'username': usernameController.text.trim(),
              'email': emailController.text.trim(),
              'profileImageUrl': '',
              'bio': '',
              'followers': [],
              'following': [],
              'lastUpdated': FieldValue.serverTimestamp(),
            });

        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );
        // Add navigation here:
        await Future.delayed(const Duration(milliseconds: 300));
        _clearFields(); // Clear all input fields
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ExploreScreen()),
          );
        }
      } else {
        Navigator.pop(context);
        showErrorMessage('Passwords don\'t match');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      // Better error handling
      String errorMessage = 'An error occurred';
      if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email is already registered';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      }

      showErrorMessage(errorMessage);
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage('Failed to create account: $e');
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.purpleAccent,
          title: Center(
            child: Text(message, style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Icon(Icons.lock, size: 50),
                SizedBox(height: 20),
                // logo
                Text(
                  'Let\'s Create an account for you',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                SizedBox(height: 20),
                //welcome back you've been missed
                // Add these BEFORE the email field
                MyTextField(
                  controller: nameController,
                  hintText: 'Full Name',
                  obscureText: false,
                ),
                SizedBox(height: 10),

                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                SizedBox(height: 10),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                //username text field
                SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                //password textfield
                SizedBox(height: 10),
                // confirm password
                MyTextField(
                  controller: confirmpasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                //forgot password
                SizedBox(height: 20),
                MyButton(text: 'Sign Up', onTap: signUserUp),
                // sign in option
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'On Continue',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                //or continue with
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SquareTile(
                    //   onTap: () => AuthService().signInwithGoogle(),
                    //   imagePath: 'assets/icon/apple.png',
                    // ),
                    SizedBox(height: 10),
                    SquareTile(
                      onTap: _isGoogleLoading
                          ? null // Disable when loading
                          : () async {
                              setState(() => _isGoogleLoading = true);
                              await AuthService(context).signInwithGoogle();
                              setState(() => _isGoogleLoading = false);
                              // Add navigation for consistency
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExploreScreen(),
                                  ),
                                );
                              }
                            },

                      imagePath: 'assets/icon/google.png',
                      // child: _isGoogleLoading
                      // ? CircularProgressIndicator(color: Colors.white) // Show spinner
                      // : null,
                    ),
                  ],
                ),
                //google + apple sign in buttons
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Login Now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // not a memeber give a option to register now
              ],
            ),
          ),
        ),
      ),
    );
  }
}
