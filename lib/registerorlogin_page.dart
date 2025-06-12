import 'package:application_journey/login_page.dart';
import 'package:application_journey/register_page.dart';
import 'package:flutter/material.dart';
//import 'package:get/get.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegisterPage> {
  // initially show login page
  bool showLoginPage = true;

  // togle between login and register page
  void togglePage() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePage);
    } else {
      return RegisterPage(onTap: togglePage);
    }
  }
}
