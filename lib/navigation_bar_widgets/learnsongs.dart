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
    'J': 'Me2',
    // Double letter combinations
    'AB': 'DoRe',
    'AC': 'DoMe',
    'AD': 'DoFa',
    'AE': 'DoSol',
    'AF': 'DoLa',
    'AG': 'DoSi',
    'AH': 'DoDo2',
    'AI': 'DoRe2',
    'AJ': 'DoMe2',
    'BA': 'ReDo',
    'BC': 'ReMe',
    'BD': 'ReFa',
    'BE': 'ReSol',
    'BF': 'ReLa',
    'BG': 'ReSi',
    'BH': 'ReDo2',
    'BI': 'ReRe2',
    'BJ': 'ReMe2',
    'CA': 'MeDo',
    'CB': 'MeRe',
    'CD': 'MeFa',
    'CE': 'MeSol',
    'CF': 'MeLa',
    'CG': 'MeSi',
    'CH': 'MeDo2',
    'CI': 'MeRe2',
    'CJ': 'MeMe2',
    'DA': 'FaDo',
    'DB': 'FaRe',
    'DC': 'FaMe',
    'DE': 'FaSol',
    'DF': 'FaLa',
    'DG': 'FaSi',
    'DH': 'FaDo2',
    'DI': 'FaRe2',
    'DJ': 'FaMe2',
    'EA': 'SolDo',
    'EB': 'SolRe',
    'EC': 'SolMe',
    'ED': 'SolFa',
    'EF': 'SolLa',
    'EG': 'SolSi',
    'EH': 'SolDo2',
    'EI': 'SolRe2',
    'EJ': 'SolMe2',
    'FA': 'LaDo',
    'FB': 'LaRe',
    'FC': 'LaMe',
    'FD': 'LaFa',
    'FE': 'LaSol',
    'FG': 'LaSi',
    'FH': 'LaDo2',
    'FI': 'LaRe2',
    'FJ': 'LaMe2',
    'GA': 'SiDo',
    'GB': 'SiRe',
    'GC': 'SiMe',
    'GD': 'SiFa',
    'GE': 'SiSol',
    'GF': 'SiLa',
    'GH': 'SiDo2',
    'GI': 'SiRe2',
    'GJ': 'SiMe2',
    'HA': 'Do2Do',
    'HB': 'Do2Re',
    'HC': 'Do2Me',
    'HD': 'Do2Fa',
    'HE': 'Do2Sol',
    'HF': 'Do2La',
    'HG': 'Do2Si',
    'HI': 'Do2Re2',
    'HJ': 'Do2Me2',
    'IA': 'Re2Do',
    'IB': 'Re2Re',
    'IC': 'Re2Me',
    'ID': 'Re2Fa',
    'IE': 'Re2Sol',
    'IF': 'Re2La',
    'IG': 'Re2Si',
    'IH': 'Re2Do2',
    'IJ': 'Re2Me2',
    'JA': 'Me2Do',
    'JB': 'Me2Re',
    'JC': 'Me2Me',
    'JD': 'Me2Fa',
    'JE': 'Me2Sol',
    'JF': 'Me2La',
    'JG': 'Me2Si',
    'JH': 'Me2Do2',
    'JI': 'Me2Re2',
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

  String? initialCorrectData;
  String? initialPercentageData;

  @override
  void initState() {
    super.initState();

    correctRef = FirebaseDatabase.instance.ref('/correct');
    percentageRef = FirebaseDatabase.instance.ref('/presntage');
    challengeRef = FirebaseDatabase.instance.ref('/challenge');

    _fetchInitialRTDBValues();
    _listenToCorrectChanges();
    _listenToPercentageChanges();
    _listenToChallengeChanges();
  }

  Future<void> _fetchInitialRTDBValues() async {
    correctData = (await correctRef.once()).snapshot.value?.toString();
    percentageData = (await percentageRef.once()).snapshot.value?.toString();
    
    initialCorrectData = correctData;
    initialPercentageData = percentageData;
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

    // Only update if there is a change in data
    if (correctData != initialCorrectData) learningData['correct'] = correctData;
    if (percentageData != initialPercentageData) {
      if (challengeData == 'easy') {
        learningData['presntage_easy'] = percentageData;
      } else if (challengeData == 'hard') {
        learningData['presntage_hard'] = percentageData;
      }
    }

    if (songSnapshot.exists && learningData.isNotEmpty) {
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
    await FirebaseDatabase.instance.ref().update({'name': widget.songId});
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
