import 'package:tracking_board_app/loading/get_vec.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class Login extends StatefulWidget {
  final String email;
  final String password;
  const Login({super.key, required this.email, required this.password});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  @override
  void initState() {
    super.initState();
    _login();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SpinKitFadingCircle(color: Colors.blue,size: 50.0),
      ),
    );
  }

  Future<void> _login() async {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: widget.email,
          password: widget.password
      ).then((value) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  GetVec()));
      }).catchError((error) {
        _showErrorMessage(context, 'Failed to sign in: $error');
      });
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