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
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  StreamSubscription<DatabaseEvent>? _correctSubscription;
  StreamSubscription<DatabaseEvent>? _percentageSubscription;
  StreamSubscription<DatabaseEvent>? _challengeSubscription;
  String currentChallenge = 'None'; // Default challenge
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

  @override
  void initState() {
    super.initState();
    _listenToRealtimeUpdates();
    _listenToChallengeUpdates();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void _listenToRealtimeUpdates() {
    _correctSubscription = _dbRef.child('correct').onValue.listen((event) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String correct = (event.snapshot.value as String?) ?? '0';
      await _updateFirestore('correct', correct);
    });

    _percentageSubscription = _dbRef.child('presntage').onValue.listen((event) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String percentage = (event.snapshot.value as String?) ?? '0';
      await _updateFirestore('presntage_challenge', percentage);
    });
  }

  void _listenToChallengeUpdates() {
    _challengeSubscription = _dbRef.child('challenge').onValue.listen((event) {
      setState(() {
        currentChallenge = (event.snapshot.value as String?) ?? 'None';
      });
    });
  }

  Future<void> _updateFirestore(String field, String value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.songId.isEmpty) return;

    final songRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('songs')
        .doc(widget.songId);

    // Update the specific challenge-based field in Firestore
    final fieldToUpdate = field == 'presntage_challenge' ? 'presntage_$currentChallenge' : field;
    await songRef.update({fieldToUpdate: value});
  }

  void _cancelSubscriptions() {
    _correctSubscription?.cancel();
    _percentageSubscription?.cancel();
    _challengeSubscription?.cancel();
    _correctSubscription = null;
    _percentageSubscription = null;
    _challengeSubscription = null;
  }

  void _switchToFreePlayMode() async {
    try {
      // Cancel any active listeners before making updates
      _cancelSubscriptions();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Update the Firestore and RTDB safely
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'currentMode': 'freePlay', 'challenge': 'None', 'currentSong': 'None'});

      await FirebaseDatabase.instance.reference().update({'name': 'None'});
      await FirebaseDatabase.instance.reference().update({'currentSong': 'None'});
      await FirebaseDatabase.instance.reference().update({'currentMode': 'freePlay'});
      await FirebaseDatabase.instance.reference().update({'challenge': 'None'});
    } catch (e) {
      print('Error updating to freePlay mode: $e');
    }

    // Navigate back after updates are complete
    Navigator.of(context).pop();
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

  void _updateCurrentMode(String mode, String challenge, String mappedNotes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Update Firestore currentMode, challenge, currentSong, and lastSong
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'currentMode': mode,
      'challenge': challenge,
      'currentSong': widget.songId, // Use the songId directly
      'lastSong': widget.songId,    // Update lastSong to the current songId
    });

    // Update Realtime Database currentSong and name
    await FirebaseDatabase.instance.reference().update({'currentSong': widget.songId});
    await FirebaseDatabase.instance.reference().update({'name': widget.songId});
    await FirebaseDatabase.instance.reference().update({'currentMode': mode});
    await FirebaseDatabase.instance.reference().update({'challenge': challenge});
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
              onPressed: () {
                _updateCurrentMode('learn', 'easy', notes);
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
              onPressed: () {
                _updateCurrentMode('learn', 'hard', notes);
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
            _switchToFreePlayMode(); // Switch to freePlay mode on back arrow press
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
                if (_showEasyHardButtons) // Show Easy and Hard buttons conditionally
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showEasyModePopup(context); // Show Easy mode popup
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
                          'Easy',
                          style: TextStyle(
                            color: Color(0xFFF1F4F8),
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _showHardModePopup(context); // Show Hard mode popup
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
                          'Hard',
                          style: TextStyle(
                            color: Color(0xFFF1F4F8),
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
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
