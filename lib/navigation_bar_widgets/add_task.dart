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
  late DatabaseReference durationRef;
  late Stream<DatabaseEvent> recordedStream;
  late Stream<DatabaseEvent> durationStream;

  String? recordedData;
  String? durationData;

  @override
  void initState() {
    super.initState();
    _updateCurrentModeToRecord();

    String userId = FirebaseAuth.instance.currentUser!.uid;

    recordedRef = FirebaseDatabase.instance.ref('/recorded');
    durationRef = FirebaseDatabase.instance.ref('/duration');

    recordedStream = recordedRef.onValue;
    durationStream = durationRef.onValue;

    _listenToRecordedChanges();
    _listenToDurationChanges();
  }

  @override
  void dispose() {
    _updateCurrentModeToFreePlay();
    _songNameController.dispose();
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
        setState(() {
          recordedData = event.snapshot.value.toString();
        });
        await _updateFirestoreWithSongData();
      }
    });
  }

  void _listenToDurationChanges() {
    durationStream.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        setState(() {
          durationData = event.snapshot.value.toString();
        });
        await _updateFirestoreWithSongData();
      }
    });
  }

  Future<void> _updateFirestoreWithSongData() async {
    String songName = _songNameController.text;

    if (songName.isNotEmpty) {
      Map<String, dynamic> songData = {};
      if (recordedData != null) songData['notes'] = recordedData;
      if (durationData != null) songData['duration'] = durationData;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('songs')
          .doc(songName)
          .set(songData, SetOptions(merge: true)); // Merge to update only specific fields
    } else {
      _showPopUpMessage('No song name', 'Please insert a name for your song before recording.');
    }
  }

  void _showPopUpMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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
                "Please enter a name then press the start button to start recording",
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