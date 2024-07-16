import 'package:flutter/services.dart';
import 'package:tracking_board_app/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracking_board_app/reusable_widgets/reusable_widgets.dart';
import 'package:tracking_board_app/loading/login.dart';

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
              fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                const Text(
                  'Create an account',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF101213),
                    fontSize: 36.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 24.0),
                  child: Text(
                    'Let\'s get started by filling out the form below.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFF57636C),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                reusableTextField("User Name", Icons.person_outline, false,
                    _usernameTextController, shortName),
                reusableTextField("Email ID", Icons.email_outlined, false,
                    _emailTextController, wrongEmail),
                reusableTextField("Password", Icons.lock_outline, true,
                    _passwordTextController, wrongPass),
                signInSignUpButton(context, false, () {
                  try {
                    if (_usernameTextController.value.text.length < 3 || _usernameTextController.value.text.length > 8) {
                      throw PlatformException(
                        code: 'short-name',
                        message: 'Username must be 3 to 8 characters long.',
                      );
                    }
                    else {
                      throw PlatformException(
                        code: 'all-good',
                      );
                    }
                  } catch (e) {
                    if (e is PlatformException && e.code == 'short-name') {
                      _showErrorMessage(context, e.message!);
                      setState(() {
                        shortName = true;
                        wrongEmail = false;
                        wrongPass = false;
                      });
                    }
                    if(e is PlatformException && e.code == 'all-good'){
                      FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                          .then((value) {
                        // Add user data to Firestore
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(value.user!.uid)
                            .set({
                          'name': _usernameTextController.text,
                          'email': _emailTextController.text,
                          'vec': zeros,
                          'tasks': {}
                        });
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Login(
                                    email: _emailTextController.text,
                                    password: _passwordTextController.text)));
                      }
                      ).catchError((error) {
                        print("Failed to sign up: $error");

                        String errorMessage =
                            "An error occurred. Please try again.";

                        if (error is FirebaseAuthException) {
                          if (error.code == 'email-already-in-use') {
                            errorMessage =
                            "The email address is already in use by another account.";
                            setState(() {
                              wrongEmail = true;
                              wrongPass = false;
                              shortName = false;
                            });
                          }
                          if (error.code == 'invalid-email') {
                            errorMessage =
                            "The email address specified is not an actual email address.";
                            setState(() {
                              wrongEmail = true;
                              wrongPass = false;
                              shortName = false;
                            });
                          }
                          if (error.code == 'weak-password') {
                            errorMessage =
                            "The password chosen is not strong enough, password must be at least of length 6.";
                            setState(() {
                              wrongPass = true;
                              wrongEmail = false;
                              shortName = false;
                            });
                          }
                        }
                        // Show error message
                        _showErrorMessage(context, errorMessage);
                      });
                    }
                  }

                }),
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
        const Text("Already have account? ",
            style: TextStyle(
                color: Color(0xFF57636C), fontFamily: 'Plus Jakarta Sans')),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const SignInScreen()));
          },
          child: const Text(
            "Log In",
            style: TextStyle(
                color: Color(0xFF4B39EF), fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}

void _showErrorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ),
  );
}
