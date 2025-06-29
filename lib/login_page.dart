import 'package:application_journey/Services/auth_service.dart';
import 'package:application_journey/my_button.dart';
import 'package:application_journey/my_textfile.dart';
import 'package:application_journey/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:application_journey/home_page.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // show loading circle

  // sign user in
  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //wrong email
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
    // pop the circle
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
  // void dispose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   super.dispose();
  // }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Icon(Icons.lock, size: 80),
                SizedBox(height: 25),
                // logo
                Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                SizedBox(height: 25),
                //welcome back you've been missed
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
                MyButton(text: 'Sign In', onTap: signUserIn),
                // sign in option
                SizedBox(height: 20),
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
                    SquareTile(
                      onTap: () => AuthService(context).signInwithGoogle(),
                      imagePath: 'assets/icon/google.png',
                    ),
                    SizedBox(height: 10),
                    // SquareTile(
                    //   onTap: () {},
                    //   imagePath: 'assets/icon/apple.png',
                    // ),
                  ],
                ),
                //google + apple sign in buttons
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a Member?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Registration Now',
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
