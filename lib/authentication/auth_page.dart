import 'package:flutter/material.dart';
import 'package:to_do_list_app/screens/login_screen.dart';
import 'package:to_do_list_app/screens/signUp_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _showLoginScreen = true;

  // Method to toggle between Login and Sign Up screens
  void toggleScreen() {
    setState(() {
      _showLoginScreen = !_showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _showLoginScreen
          ? LoginScreen(toggleScreen)
          : SignUpScreen(toggleScreen),
    );
  }
}
