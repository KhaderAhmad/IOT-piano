import 'package:tracking_board_app/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class GetVec extends StatefulWidget {
  const GetVec({super.key});

  @override
  State<GetVec> createState() => _GetVecState();
}

class _GetVecState extends State<GetVec> {
  String _vec = '';
  String _name = '';
  Map<String, dynamic> _tasks = {};

  @override
  void initState() {
    super.initState();
    _fetchVec();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SpinKitFadingCircle(color: Colors.blue,size: 50.0),
      ),
    );
  }


  Future<void> _fetchVec() async {
    // Get the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the document reference for the user
    DocumentReference userDocRef = firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    // Get the document snapshot
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    // Extract user name from document snapshot
    if (userDocSnapshot.exists) {
      _vec =
          (userDocSnapshot.data() as Map<String, dynamic>?)?['vec'] ?? '';
      _tasks =
          (userDocSnapshot.data() as Map<String, dynamic>?)?['tasks'] ?? {};
      _name = (userDocSnapshot.data() as Map<String, dynamic>?)?['name'] ?? '';
    } else {
      _vec = '';
      _tasks = {};
      _name = '';
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  HomeScreen(vec1: _vec, tasks1: _tasks, name1: _name)));
  }

}
