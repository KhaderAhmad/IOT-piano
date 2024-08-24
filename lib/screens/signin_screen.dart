import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_board_app/loading/get_vec.dart';
import 'package:tracking_board_app/reusable_widgets/reusable_widgets.dart';
import 'package:tracking_board_app/screens/signup_screen.dart';
import '../walkthrough_screen.dart'; // Import your WalkthroughScreen

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
  }

  @override
  void dispose() {
    _passwordTextController.dispose();
    _emailTextController.dispose();
    super.dispose();
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
      floatingActionButton: floatingQuestionMark(context),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4B39EF), Color(0xFF57636C)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 100),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.white,
                    fontSize: 36.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 24.0),
                  child: Text(
                    'Let\'s get started by filling out the form below.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.white70,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                reusableTextField("User Email", Icons.person_outline, false, _emailTextController, false),
                const SizedBox(height: 20),
                reusableTextField("Password", Icons.lock_outline, true, _passwordTextController, false),
                const SizedBox(height: 40),
                signInSignUpButton(context, true, () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text
                    ).then((value) async {
                      // Check if the walkthrough has been seen
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      bool seenWalkthrough = prefs.getBool('seenWalkthrough') ?? false;

                      if (!seenWalkthrough) {
                        // If not seen, navigate to the walkthrough screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => WalkthroughScreen()),
                        );
                      } else {
                        // If seen, navigate to the main part of your app
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const GetVec()),
                        );
                      }
                    });
                  } catch (error) {
                    String errorMessage = "An error occurred. Please try again.";
                    if (error is FirebaseAuthException) {
                      if (error.code == 'invalid-credential') {
                        errorMessage = "The Email or password you entered does not match, or email does not exist.";
                      }
                      if (error.code == 'too-many-requests') {
                        errorMessage = "Too many attempts have been made to login, please try again later.";
                      }
                    }
                    _showErrorMessage(context, errorMessage);
                  }
                }),
                const SizedBox(height: 20),
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
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
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
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
