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

  @override
  Widget build(BuildContext context) {
    List<String> notes = ['Do', 'Re', 'Me', 'Fa', 'Sol', 'La', 'Si', 'Do'];

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

                  widget.songs[DateTime.now().toString()] = selectedNotes;

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({'songs': widget.songs});

                  Navigator.pop(context);
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
}
