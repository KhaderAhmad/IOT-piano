import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracking_board_app/screens/signin_screen.dart';
import 'package:connectivity/connectivity.dart';

class LogOut extends StatefulWidget {
  final String name1;
  const LogOut({super.key,required String this.name1});

  @override
  State<LogOut> createState() => _LogOutState();
}


class _LogOutState extends State<LogOut> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.1, 20, 0),
              child: Column(
                children: <Widget> [

                   Text(
                    'Good Bye ${widget.name1}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFF101213),
                      fontSize: 36.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        0.0, 8.0, 0.0, 24.0),
                    child: Text(
                      'Hope to see you soon.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF57636C),
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 200
                  ),
                  ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut().then((value) => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()))
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.black26;
                        }
                        return Color(0xFF4B39EF);
                      }),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)))),
                  child: const Text(
                    'LogOut',
                    style: TextStyle(
                        color: Color(0xFFF1F4F8),
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  ),
                  const SizedBox(
                      height: 20
                  ),
                  signUpOption(),
                ],
              ),
            )
        ),
      ),
    );

  }

  Row signUpOption() {
    Connectivity _connectivity = Connectivity();
    bool _isConnected = true;
    Future<void> _checkConnectivity() async {
      final result = await _connectivity.checkConnectivity();
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    }
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Delete your account? ",
            style: TextStyle(color: Color(0xFF57636C),fontFamily: 'Plus Jakarta Sans')),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Delete Account"),
                  content: Text("Are you sure you want to delete the account?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Delete the account
                        if(_isConnected){
                        FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).delete().catchError((error) {print("Failed to delete user data: $error");});
                        FirebaseAuth.instance.currentUser!.delete().catchError((error) {print("Failed to delete user account: $error");});
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen(),),);
                        }
                        else{
                          Navigator.of(context).pop();
                          _showConnectionMessage();
                        }
                      },
                      child: Text("Yes"),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text(
            "Delete here",
            style: TextStyle(color: Color(0xFF4B39EF), fontWeight: FontWeight.bold),
          ),
        )
      ],
    );

  }
  void _showConnectionMessage() {
    // Show a Snackbar when connection is lost
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text('No internet connection, try again later.'),
        duration: Duration(seconds: 5),
      ),
    );
  }
}



