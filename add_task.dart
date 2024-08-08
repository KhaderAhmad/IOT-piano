import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddSong extends StatefulWidget {
  final String userName;
  final Map<String, dynamic> songs;

  const AddSong({
    super.key,
    required this.userName,
    required this.songs,
  });

  @override
  State<AddSong> createState() => _AddSongState();
}

class _AddSongState extends State<AddSong> {
  @override
  void initState() {
    super.initState();
    _updateCurrentModeToRecord();
  }

  void _updateCurrentModeToRecord() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Update in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'currentMode': 'record'});

    // Update in Realtime Database
    await FirebaseDatabase.instance
        .reference()
        .update({'currentMode': 'record'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add a new song for ${widget.userName}',
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "please press the start button to start recording",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
