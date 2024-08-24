import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_board_app/loading/login.dart';
import 'package:tracking_board_app/reusable_widgets/reusable_widgets.dart';
import 'package:tracking_board_app/screens/signin_screen.dart';
import '../walkthrough_screen.dart'; // Import the WalkthroughScreen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  String zeros = "0" * 366;
  bool wrongPass = false;
  bool wrongEmail = false;
  bool shortName = false;
  bool invalidName = false;
  bool invalidEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),
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
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_add,
                    size: 50,
                    color: Color(0xFF4B39EF),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Create an account',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.white,
                    fontSize: 36.0,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
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
                reusableTextField(
                  "User Name",
                  Icons.person_outline,
                  false,
                  _usernameTextController,
                  shortName || invalidName,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Email ID",
                  Icons.email_outlined,
                  false,
                  _emailTextController,
                  wrongEmail || invalidEmail,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                  wrongPass,
                ),
                const SizedBox(height: 40),
                signInSignUpButton(context, false, () async {
                  try {
                    // Regular expression for checking if username contains at least one letter and is not just numbers
                    final namePattern = RegExp(r'^(?=.*[a-zA-Z])(?=.*[^0-9])');

                    if (_usernameTextController.value.text.length < 3 ||
                        _usernameTextController.value.text.length > 8) {
                      throw PlatformException(
                        code: 'short-name',
                        message: 'Username must be 3 to 8 characters long.',
                      );
                    } else if (!namePattern.hasMatch(_usernameTextController.value.text)) {
                      throw PlatformException(
                        code: 'invalid-name',
                        message:
                            'Username must contain at least one letter and cannot be only numbers.',
                      );
                    } else {
                      throw PlatformException(
                        code: 'all-good',
                      );
                    }
                  } catch (e) {
                    if (e is PlatformException && e.code == 'short-name') {
                      _showErrorMessage(context, e.message!);
                      setState(() {
                        shortName = true;
                        invalidName = false;
                        wrongEmail = false;
                        invalidEmail = false;
                        wrongPass = false;
                      });
                    } else if (e is PlatformException && e.code == 'invalid-name') {
                      _showErrorMessage(context, e.message!);
                      setState(() {
                        shortName = false;
                        invalidName = true;
                        wrongEmail = false;
                        invalidEmail = false;
                        wrongPass = false;
                      });
                    } else if (e is PlatformException && e.code == 'all-good') {
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text)
                          .then((value) {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(value.user!.uid)
                            .set({
                          'name': _usernameTextController.text,
                          'email': _emailTextController.text,
                          'vec': zeros,
                          'tasks': {},
                          'songs': {},
                          'currentSong': 'NONE',
                          'currentMode': 'freeplay',
                          'lastSong': 'NONE'
                        }).then((_) {
                          _addDefaultSongs(value.user!.uid);
                        });
                        
                        // Navigate to WalkthroughScreen after successful sign-up
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WalkthroughScreen()));
                      }).catchError((error) {
                        print("Failed to sign up: $error");

                        String errorMessage =
                            "An error occurred. Please try again.";

                        if (error is FirebaseAuthException) {
                          if (error.code == 'email-already-in-use') {
                            errorMessage =
                                "The email address is already in use by another account.";
                            setState(() {
                              wrongEmail = true;
                              invalidEmail = false;
                              wrongPass = false;
                              shortName = false;
                              invalidName = false;
                            });
                          }
                          if (error.code == 'invalid-email') {
                            errorMessage =
                                "The email address specified is not an actual email address.";
                            setState(() {
                              wrongEmail = true;
                              invalidEmail = false;
                              wrongPass = false;
                              shortName = false;
                              invalidName = false;
                            });
                          }
                          if (error.code == 'weak-password') {
                            errorMessage =
                                "The password chosen is not strong enough, password must be at least of length 6.";
                            setState(() {
                              wrongPass = true;
                              wrongEmail = false;
                              invalidEmail = false;
                              shortName = false;
                              invalidName = false;
                            });
                          }
                        }
                        _showErrorMessage(context, errorMessage);
                      });
                    }
                  }
                }),
                const SizedBox(height: 30),
                signInOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addDefaultSongs(String userId) {
    final songsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('songs');

    // Happy Birthday (simplified to fit one octave)
    songsCollection.doc('HappyBirthday').set({
      'correct': "0",
      'duration': "500,500,500,500,1000,1000",
      'notes': "E,E,F,E,A,G",
      'presntage_easy': "0",
    });

    // Jingle Bells (part of the melody, simplified to fit one octave)
    songsCollection.doc('JingleBells').set({
      'correct': "0",
      'duration': "400,400,400,400,800,400,400,400,400,800",
      'notes': "E,E,E,E,E,E,G,C,D,E",
      'presntage_easy': "0",
    });

    // Twinkle little star (part of the melody, simplified to fit one octave)
    songsCollection.doc('Twinkle little star').set({
      'correct': "0",
      'duration': "500,500,500,500,500,500,1000",
      'notes': "A,A,E,E,F,F,E",
      'presntage_easy': "0",
    });
  }

  Row signInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          },
          child: const Text(
            "Log In",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      ],
    );
  }
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
