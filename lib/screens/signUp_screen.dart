import 'package:flutter/material.dart';
import 'package:to_do_list_app/data/auth_data.dart';
import 'package:to_do_list_app/helper/global.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback show;
  const SignUpScreen(this.show, {super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final email = TextEditingController();
  final password = TextEditingController();
  final passwordConfirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() {
      setState(() {});
    });
    _focusNode2.addListener(() {
      setState(() {});
    });
    _focusNode3.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    super.dispose();
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
                  textFieldInput(email, _focusNode1, 'Email', Icons.email, false, () {}),
                  SizedBox(height: mq.height * 0.02),
                  textFieldInput(password, _focusNode2, 'Password', Icons.lock, _isPasswordVisible, () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  }),
                  SizedBox(height: mq.height * 0.02),
                  textFieldInput(passwordConfirm, _focusNode3, 'Confirm Password', Icons.lock, _isConfirmPasswordVisible, () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  }),
                  SizedBox(height: mq.height * 0.08),
                  account(),
                  SizedBox(height: mq.height * 0.02),
                  signUpButton(),
                  SizedBox(height: mq.height * 0.02),
                  TextButton(
                    onPressed: () {
                      // Handle "Forgot Password" action
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
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
            "Already have an account?",
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          SizedBox(width: mq.width * 0.01),
          GestureDetector(
            onTap: () => widget.show(),
            child: Text(
              'Log In',
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

  Widget textFieldInput(
      TextEditingController controller,
      FocusNode focusNode,
      String hintText,
      IconData icon,
      bool isPasswordVisible,
      VoidCallback onVisibilityToggle) {
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
        obscureText: (hintText == 'Password' || hintText == 'Confirm Password') && !isPasswordVisible,
        style: const TextStyle(fontSize: 18, color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: focusNode.hasFocus ? custom_green : const Color(0xffc5c5c5),
          ),
          suffixIcon: (hintText == 'Password' || hintText == 'Confirm Password')
              ? IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: focusNode.hasFocus ? custom_green : const Color(0xffc5c5c5),
            ),
            onPressed: onVisibilityToggle,
          )
              : null,
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


  Widget signUpButton() {
    return ElevatedButton(
      onPressed: () {
        AuthenticationRemote().register(email.text, password.text, passwordConfirm.text);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.1, vertical: mq.height * 0.02),
        backgroundColor: custom_green.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        "Sign Up",
        style: TextStyle(
          fontSize: 20,
          color: Color(0xFF53DBD9),
        ),
      ),
    );
  }
}
