import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tracking_board_app/loading/get_vec.dart';
import 'package:tracking_board_app/reusable_widgets/reusable_widgets.dart';
import 'package:tracking_board_app/screens/signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Optionally update currentMode to "signIn" or similar if needed when entering the screen
  }

  @override
  void dispose() {
    super.dispose();
    _updateCurrentModeToFreePlay();
  }

  void _updateCurrentModeToFreePlay() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'currntMode': 'freePlay'});
    
    await FirebaseDatabase.instance
        .reference()
        .update({'currentMode': 'freePlay'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget> [
                const SizedBox(
                    height: 100
                ),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color.fromARGB(255, 20, 44, 203),
                    fontSize: 36.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      0.0, 12.0, 0.0, 24.0),
                  child: Text(
                    'Let\'s get started by filling out the form below.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color.fromARGB(255, 200, 10, 165),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                reusableTextField("User Email", Icons.person_outline, false, _emailTextController, false),

                reusableTextField("Password", Icons.lock_outline, true, _passwordTextController, false),

                signInSignUpButton(context, true, () async {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text
                  ).then((value) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GetVec()));
                  }).catchError((error) {
                    String errorMessage = "An error occurred. Please try again.";
                    if (error is FirebaseAuthException) {
                      print(error.code);
                      if (error.code == 'invalid-credential') {
                        errorMessage = "The Email or password you entered does not match, or email does not exist.";

                      }
                      if (error.code == 'too-many-requests') {
                        errorMessage = "Too many attempts to have been done to login, please try again later.";
                      }
                    }
                    _showErrorMessage(context, errorMessage);
                  });
                }),
                signUpOption(),
              ],
            ),
          )
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ",
            style: TextStyle(color: Color(0xFF57636C),fontFamily: 'Plus Jakarta Sans')),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Color.fromARGB(255, 200, 10, 165), fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
