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
  final TextEditingController _songNameController = TextEditingController();
  late DatabaseReference recordedRef;
  late Stream<DatabaseEvent> recordedStream;

  @override
  void initState() {
    super.initState();
    _updateCurrentModeToRecord();

    String userId = FirebaseAuth.instance.currentUser!.uid;
    recordedRef = FirebaseDatabase.instance.ref('/recorded');
    recordedStream = recordedRef.onValue;
    _listenToRecordedChanges();
  }

  @override
  void dispose() {
    _updateCurrentModeToFreePlay();
    super.dispose();
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

  void _updateCurrentModeToFreePlay() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Update in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'currentMode': 'freePlay'});

    // Update in Realtime Database
    await FirebaseDatabase.instance
        .reference()
        .update({'currentMode': 'freePlay'});
  }

  void _listenToRecordedChanges() {
    recordedStream.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        String songName = _songNameController.text;
        String recordedData = event.snapshot.value.toString();

        if (songName.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('songs')
              .doc(songName)
              .set({'notes': recordedData});
        } else {
          _showErrorMessage('Please insert a name for your song - before exiting recoreding mode via hardware.');
        }
      }
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
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
          child: Column(
            children: [
              TextField(
                controller: _songNameController,
                decoration: InputDecoration(
                  labelText: 'Song Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Please press the start button to start recording",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
