import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  List<String> selectedNotes = [];
  List<String> selectedLetters = [];

  // Mapping musical notes to corresponding letters
  final Map<String, String> noteToLetter = {
    'Do': 'A',
    'Re': 'B',
    'Me': 'C',
    'Fa': 'D',
    'Sol': 'E',
    'La': 'F',
    'Si': 'G',
    'Do2': 'H'  // If you want 'Do' to map to 'H' the second time, otherwise map it to 'A' again
  };

  @override
  Widget build(BuildContext context) {
    List<String> notes = ['Do', 'Re', 'Me', 'Fa', 'Sol', 'La', 'Si', 'Do2'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add a new song for ${widget.userName}',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Wrap(
                spacing: 10.0,
                children: notes.map((note) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedNotes.add(note);
                        selectedLetters.add(noteToLetter[note]!);
                      });
                    },
                    child: Text(note),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                'Selected Notes: ${selectedNotes.join(', ')}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (selectedNotes.isEmpty) {
                    _showErrorMessage(context, 'Please select at least one note.');
                    return;
                  }

                  String songId = DateTime.now().toString();

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('songs')
                      .doc(songId)
                      .set({'notes': selectedLetters});

                  _showSuccessMessage(context, 'Added successfully');

                  setState(() {
                    selectedNotes.clear(); // Clear selected notes after submission
                    selectedLetters.clear(); // Clear selected letters after submission
                  });
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.black26;
                      }
                      return Color(0xFF4B39EF);
                    }),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)))),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                      color: Color(0xFFF1F4F8),
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
