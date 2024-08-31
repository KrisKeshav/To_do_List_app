import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:to_do_list_app/api/apis.dart';
import 'package:to_do_list_app/helper/dialogs.dart';
import 'package:to_do_list_app/helper/global.dart';
import 'package:to_do_list_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback show;
  const LoginScreen(this.show, {super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() {
      setState(() {});
    });
    _focusNode2.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  void _handleGoogleBtnClick() {
    setState(() {
      _isLoading = true;
    });
    // Show progress bar
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      // Hide progress bar
      Navigator.pop(context);
      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        if (await APIs.userExists()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          await APIs.createUser(name: '').then((value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          });
        }
      } else {
        // Handle sign-in failure
        log('Sign-in failed');
        // Optionally, show a dialog or a snackbar
      }
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
      log('Error: $e');
      Dialogs.showSnackBar(context, 'Something went wrong (Check Internet)!');
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null; // If the sign-in process was aborted
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('Error signing in with Google: $e');
      Dialogs.showSnackBar(context, 'Something went wrong (Check Internet)!');
      return null;
    }
  }

  Future<void> _loginWithEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      log('Login failed: $e');
      Dialogs.showSnackBar(context, 'Login failed: ${e.message}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize MediaQuery size
    initMediaQuery(context);

    return Scaffold(
      backgroundColor: bgColors,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(mq.width * 0.05),
              child: Column(
                children: [
                  SizedBox(height: mq.height * 0.05),
                  image(),
                  SizedBox(height: mq.height * 0.05),
                  textFieldInput(email, _focusNode1, 'Email', Icons.email),
                  SizedBox(height: mq.height * 0.02),
                  textFieldInput(password, _focusNode2, 'Password', Icons.lock),
                  SizedBox(height: mq.height * 0.08),
                  account(),
                  SizedBox(height: mq.height * 0.02),
                  loginButton(),
                  SizedBox(height: mq.height * 0.005),
                  TextButton(
                    onPressed: () {
                      // Handle "Forgot Password" action
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: mq.height * 0.015),
                  // Add Google Sign-In button
                  googleSignInButton(),
                  // Add more widgets here for further functionality
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget account() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          SizedBox(width: mq.width * 0.01,),
          InkWell(
            onTap: () {
              log('Sign UP button tapped');
              widget.show();
            },
            child: Text(
              'Sign UP',
              style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget image() {
    return Container(
      width: mq.width * 0.8,
      height: mq.height * 0.3,
      decoration: BoxDecoration(
        color: bgColors,
        image: const DecorationImage(
          image: AssetImage('assets/images/7.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget textFieldInput(TextEditingController controller, FocusNode focusNode, String hintText, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: hintText == 'Password' && !_isPasswordVisible,
        style: const TextStyle(fontSize: 18, color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: focusNode.hasFocus ? custom_green : const Color(0xffc5c5c5),
          ),
          suffixIcon: hintText == 'Password' ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: focusNode.hasFocus ? custom_green : const Color(0xffc5c5c5),
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ) : null,
          contentPadding: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: mq.height * 0.02),
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xffc5c5c5),
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: custom_green,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget loginButton() {
    return ElevatedButton(
      onPressed: () {
        if (email.text.isEmpty || password.text.isEmpty) {
          Dialogs.showSnackBar(context, 'Please enter both email and password');
        } else {
          _loginWithEmail();
        }
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.1, vertical: mq.height * 0.02),
        backgroundColor: custom_green.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        "Login",
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget googleSignInButton() {
    return ElevatedButton.icon(
      onPressed: _handleGoogleBtnClick,
      icon: Image.asset(
        'assets/images/google.png',
        height: 24.0,
      ),
      label: const Text("Sign in with Google"),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.1, vertical: mq.height * 0.02),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
