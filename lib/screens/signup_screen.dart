import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracking_board_app/loading/login.dart';
import 'package:tracking_board_app/reusable_widgets/reusable_widgets.dart';
import 'package:tracking_board_app/screens/signin_screen.dart';

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
                signInSignUpButton(context, false, () {
                  try {
                    // Regular expression for checking English characters and digits
                    final englishPattern = RegExp(r'^[a-zA-Z0-9]+$');

                    if (_usernameTextController.value.text.length < 3 ||
                        _usernameTextController.value.text.length > 8) {
                      throw PlatformException(
                        code: 'short-name',
                        message: 'Username must be 3 to 8 characters long.',
                      );
                    } else if (!englishPattern
                        .hasMatch(_usernameTextController.value.text)) {
                      throw PlatformException(
                        code: 'invalid-name',
                        message:
                            'Username must contain only English letters and digits.',
                      );
                    } else if (!englishPattern
                        .hasMatch(_emailTextController.value.text.split('@')[0])) {
                      throw PlatformException(
                        code: 'invalid-email',
                        message: 'Email must contain only English letters and digits.',
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
                    } else if (e is PlatformException && e.code == 'invalid-email') {
                      _showErrorMessage(context, e.message!);
                      setState(() {
                        shortName = false;
                        invalidName = false;
                        wrongEmail = false;
                        invalidEmail = true;
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
                          'currentMode': 'freeplay'
                        });
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Login(
                                    email: _emailTextController.text,
                                    password: _passwordTextController.text)));
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
