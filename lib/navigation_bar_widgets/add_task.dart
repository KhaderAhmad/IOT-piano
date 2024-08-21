import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddSong extends StatefulWidget {
  final String userName;
  final Map<String, dynamic> songs;

  const AddSong({
    Key? key,
    required this.userName,
    required this.songs,
  }) : super(key: key);

  @override
  State<AddSong> createState() => _AddSongState();
}

class _AddSongState extends State<AddSong> {
  final TextEditingController _songNameController = TextEditingController();
  late DatabaseReference recordedRef;
  late DatabaseReference durationRef;
  StreamSubscription<DatabaseEvent>? recordedSubscription;
  StreamSubscription<DatabaseEvent>? durationSubscription;

  String? recordedData;
  String? durationData;

  @override
  void initState() {
    super.initState();
    _updateCurrentModeToRecord();

    recordedRef = FirebaseDatabase.instance.ref('/recorded');
    durationRef = FirebaseDatabase.instance.ref('/duration');

    _listenToRecordedChanges();
    _listenToDurationChanges();
  }

  @override
  void dispose() {
    _updateCurrentModeToFreePlay();
    _cancelSubscriptions();
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
    await FirebaseDatabase.instance.ref().update({'currentMode': 'record'});
  }

  void _updateCurrentModeToFreePlay() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Update in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'currentMode': 'freePlay'});

    // Update in Realtime Database
    await FirebaseDatabase.instance.ref().update({'currentMode': 'freePlay'});
  }

  void _listenToRecordedChanges() {
    recordedSubscription = recordedRef.onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        setState(() {
          recordedData = event.snapshot.value.toString();
        });
        await _updateFirestoreWithSongData();
      }
    });
  }

  void _listenToDurationChanges() {
    durationSubscription = durationRef.onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        setState(() {
          durationData = event.snapshot.value.toString();
        });
        await _updateFirestoreWithSongData();
      }
    });
  }

  void _cancelSubscriptions() {
    recordedSubscription?.cancel();
    durationSubscription?.cancel();
  }

  Future<void> _updateFirestoreWithSongData() async {
    String songName = _songNameController.text;

    if (songName.isNotEmpty) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final songRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('songs')
          .doc(songName);

      final songSnapshot = await songRef.get();

      Map<String, dynamic> songData = {};
      if (recordedData != null) songData['notes'] = recordedData;
      if (durationData != null) songData['duration'] = durationData;

      if (songSnapshot.exists) {
        // If the song already exists, update the existing document
        await songRef.set(songData, SetOptions(merge: true)); // Merge to update only specific fields
        if (mounted) { // Check if the widget is still mounted
          _showPopUpMessage('Song Updated', 'The song "$songName" was updated successfully.');
        }
      } else {
        // If the song does not exist, create a new document
        await songRef.set(songData);
        if (mounted) { // Check if the widget is still mounted
          _showPopUpMessage('Song Added', 'The song "$songName" was added successfully.');
        }
      }
      // Clear the song name field for the next input
      //_songNameController.clear();
    } else {
      if (mounted) { // Check if the widget is still mounted
        _showPopUpMessage('WARNING', 'Please insert a name for your song before recording.');
      }
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
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        backgroundColor: const Color(0xFF4B39EF),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: const BorderSide(color: Color.fromARGB(255, 244, 244, 244), width: 2.0), // Orange border
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _songNameController,
                    decoration: InputDecoration(
                      labelText: 'Song Name',
                      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Please enter a name then press the start button to start recording",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(239, 236, 60, 11),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
