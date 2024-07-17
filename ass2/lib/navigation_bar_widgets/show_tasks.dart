import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'learnsongs.dart'; // Import the new page

class ShowSongs extends StatefulWidget {
  final String userName;

  const ShowSongs({Key? key, required this.userName});

  @override
  State<ShowSongs> createState() => _ShowSongsState();
}

class _ShowSongsState extends State<ShowSongs> {
  late Stream<QuerySnapshot> _songsStream;

  @override
  void initState() {
    super.initState();
    _fetchSongsStream();
  }

  void _fetchSongsStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _songsStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('songs')
          .snapshots();
    } else {
      _songsStream = Stream.empty(); // Handle case where user is null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.userName}\'s Songs',
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _songsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No songs available'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> song =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(
                  document.id,
                  style: const TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500),
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LearnPage(songId: document.id),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.black26;
                        }
                        return const Color(0xFF4B39EF);
                      }),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)))),
                  child: const Text(
                    'Learn',
                    style: TextStyle(
                        color: Color(0xFFF1F4F8),
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
