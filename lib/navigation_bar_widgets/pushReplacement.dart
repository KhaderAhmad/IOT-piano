import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LearnPage extends StatelessWidget {
  final String songId;

  LearnPage({super.key, required this.songId});

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
  };

  Future<Map<String, dynamic>?> _fetchSongDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('songs')
        .doc(songId)
        .get();

    return doc.data();
  }

  void _switchToFreePlayMode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'currentMode': 'freePlay'});
  }

  void _updateChallengeMode(BuildContext context, String challengeMode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'challenge': challengeMode});

    // Navigate to the same page without Easy and Hard buttons
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LearnPage(songId: songId)),
    );
  }

  void _showEasyModePopup(BuildContext context) {
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
                _updateChallengeMode(context, 'easy'); // Update challenge mode to 'easy'
              },
            ),
          ],
        );
      },
    );
  }

  void _showHardModePopup(BuildContext context) {
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
                _updateChallengeMode(context, 'hard'); // Update challenge mode to 'hard'
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
          'Learning $songId',
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
            Navigator.of(context).pop();
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
                  'Learning: $songId',
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
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _showEasyModePopup(context); // Show Easy mode popup
            },
            tooltip: 'Easy',
            child: Icon(Icons.child_care),
            backgroundColor: Colors.blue,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              _showHardModePopup(context); // Show Hard mode popup
            },
            tooltip: 'Hard',
            child: Icon(Icons.whatshot),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
