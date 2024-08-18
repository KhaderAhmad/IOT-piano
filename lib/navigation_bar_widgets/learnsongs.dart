import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LearnPage extends StatefulWidget {
  final String songId;

  LearnPage({Key? key, required this.songId}) : super(key: key);

  @override
  _LearnPageState createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final Map<String, String> letterToNote = {
    'A': 'Do',
    'B': 'Re',
    'C': 'Me',
    'D': 'Fa',
    'E': 'Sol',
    'F': 'La',
    'G': 'Si',
    'H': 'Do2',
    'I': 'Re2',
    'J': 'Me2'
  };

  bool _showEasyHardButtons = true;
  String? _challenge;

  late DatabaseReference correctRef;
  late DatabaseReference percentageRef;
  late DatabaseReference challengeRef;
  StreamSubscription<DatabaseEvent>? correctSubscription;
  StreamSubscription<DatabaseEvent>? percentageSubscription;
  StreamSubscription<DatabaseEvent>? challengeSubscription;

  String? correctData;
  String? percentageData;
  String? challengeData;

  @override
  void initState() {
    super.initState();

    correctRef = FirebaseDatabase.instance.ref('/correct');
    percentageRef = FirebaseDatabase.instance.ref('/presntage');
    challengeRef = FirebaseDatabase.instance.ref('/challenge');

    _listenToCorrectChanges();
    _listenToPercentageChanges();
    _listenToChallengeChanges();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void _listenToCorrectChanges() {
    correctSubscription = correctRef.onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        setState(() {
          correctData = event.snapshot.value.toString();
        });
        await _updateFirestoreWithLearningData();
      }
    });
  }

  void _listenToPercentageChanges() {
    percentageSubscription = percentageRef.onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        setState(() {
          percentageData = event.snapshot.value.toString();
        });
        await _updateFirestoreWithLearningData();
      }
    });
  }

  void _listenToChallengeChanges() {
    challengeSubscription = challengeRef.onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        setState(() {
          challengeData = event.snapshot.value.toString();
        });
        await _updateFirestoreWithLearningData();
      }
    });
  }

  void _cancelSubscriptions() {
    correctSubscription?.cancel();
    percentageSubscription?.cancel();
    challengeSubscription?.cancel();
  }

  Future<void> _updateFirestoreWithLearningData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final songRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('songs')
        .doc(widget.songId);

    final songSnapshot = await songRef.get();

    Map<String, dynamic> learningData = {};
    if (correctData != null) learningData['correct'] = correctData;
    if (percentageData != null) {
      if (challengeData == 'easy') {
        learningData['presntage_easy'] = percentageData;
      } else if (challengeData == 'hard') {
        learningData['presntage_hard'] = percentageData;
      }
    }

    if (songSnapshot.exists) {
      await songRef.set(learningData, SetOptions(merge: true)); // Merge to update specific fields
    }
  }

  Future<void> _updateLastSong() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'lastSong': widget.songId});
  }

  Future<Map<String, dynamic>?> _fetchSongDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('songs')
        .doc(widget.songId)
        .get();

    return doc.data();
  }

  void _switchToFreePlayMode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'currentMode': 'freePlay', 'challenge': 'None', 'currentSong': 'None'});

    await FirebaseDatabase.instance.ref().update({'currentSong': 'None'});
    await FirebaseDatabase.instance.ref().update({'currentMode': 'freePlay'});
    await FirebaseDatabase.instance.ref().update({'challenge': 'None'});

    Navigator.of(context).pop();
  }

  void _updateCurrentMode(String mode, String challenge, String mappedNotes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _challenge = challenge;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'currentMode': mode,
      'challenge': challenge,
      'currentSong': mappedNotes,
    });

    await FirebaseDatabase.instance.ref().update({'currentSong': mappedNotes});
    await FirebaseDatabase.instance.ref().update({'currentMode': mode});
    await FirebaseDatabase.instance.ref().update({'challenge': challenge});
  }

  void _showEasyModePopup(BuildContext context) async {
    final songData = await _fetchSongDetails();
    if (songData == null) return;

    final notes = songData['notes'] as String;
    final mappedNotes = notes.split(',').map((note) => letterToNote[note]).join(', ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Easy Mode',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: Text(
            'YOU ARE NOW IN EASY MODE, LET\'S LEARN AND HAVE FUN',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                _updateCurrentMode('learn', 'easy', notes);
                await _updateLastSong();
                setState(() {
                  _showEasyHardButtons = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showHardModePopup(BuildContext context) async {
    final songData = await _fetchSongDetails();
    if (songData == null) return;

    final notes = songData['notes'] as String;
    final mappedNotes = notes.split(',').map((note) => letterToNote[note]).join(', ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Hard Mode',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(
            'YOU ARE NOW IN HARD MODE, LET\'S CHALLENGE OURSELVES!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                _updateCurrentMode('learn', 'hard', notes);
                await _updateLastSong();
                setState(() {
                  _showEasyHardButtons = false;
                });
                Navigator.of(context).pop();
              },
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
          'Learning ${widget.songId}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _switchToFreePlayMode();
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchSongDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No song details available'));
          }

          final songData = snapshot.data!;
          final notes = songData['notes'] as String;
          final mappedNotes =
              notes.split(',').map((note) => letterToNote[note]).join(', ');

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Learning: ${widget.songId}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Notes: $mappedNotes',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (_showEasyHardButtons)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showEasyModePopup(context);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.black26;
                            }
                            return const Color(0xFF4B39EF);
                          }),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Easy Mode',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _showHardModePopup(context);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.black26;
                            }
                            return const Color(0xFFFF6F61);
                          }),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Hard Mode',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
