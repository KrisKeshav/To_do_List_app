import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:to_do_list_app/helper/global.dart';
import 'package:to_do_list_app/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Add a delay to allow the splash screen animation to play
    await Future.delayed(const Duration(seconds: 7));

    // Check if the user is already signed in
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // If the user is signed in, navigate to the HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // If the user is not signed in, navigate to the AuthPage
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize MediaQuery size
    initMediaQuery(context);

    return Scaffold(
      backgroundColor: bgColors,
      body: Stack(
        children: [
          Center(
            child: Lottie.asset('assets/animations/splashScreenAnimation.json'),
          ),
          Positioned(
            bottom: mq.height * 0.05,  // Adjusted to slightly above the bottom
            left: mq.width * 0.05,
            right: mq.width * 0.05,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '“Stay organized, stay motivated, and watch your goals become accomplishments. 😇”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
