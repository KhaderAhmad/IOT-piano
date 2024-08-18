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
  // Mapping letters back to musical notes
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

  bool _showEasyHardButtons = true; // Control visibility of Easy and Hard buttons

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

    // Update Firebase challenge to "None"
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'currentMode': 'freePlay', 'challenge': 'None', 'currentSong': 'None'});

    // Update Realtime Database
    await FirebaseDatabase.instance
        .reference()
        .update({'currentSong': 'None'});

    await FirebaseDatabase.instance
        .reference()
        .update({'currentMode': 'freePlay'});
    await FirebaseDatabase.instance
        .reference()
        .update({'challenge': 'None'});
        

    // Navigate back
    Navigator.of(context).pop();
  }

  void _updateCurrentMode(String mode, String challenge, String mappedNotes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Update Firestore currentMode, challenge, and currentSong
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'currentMode': mode,
      'challenge': challenge,
      'currentSong': mappedNotes, // Update currentSong to the mappedNotes
    });

    // Update Realtime Database currentSong
    await FirebaseDatabase.instance
        .reference()
        .update({'currentSong': mappedNotes});

    await FirebaseDatabase.instance
        .reference()
        .update({'currentMode': mode});

    await FirebaseDatabase.instance
        .reference()
        .update({'challenge': challenge});
        
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
                _updateCurrentMode('learn', 'easy', notes); // Set currentMode to 'learn', challenge to 'easy', and update currentSong with mappedNotes
                setState(() {
                  _showEasyHardButtons = false; // Hide Easy and Hard buttons
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
                _updateCurrentMode('learn', 'hard', notes); // Set currentMode to 'learn', challenge to 'hard', and update currentSong with mappedNotes
                setState(() {
                  _showEasyHardButtons = false; // Hide Easy and Hard buttons
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