import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'learnsongs.dart';

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
      _songsStream = Stream.empty();
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
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF4B39EF),
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Available Songs for ${widget.userName}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  padding: const EdgeInsets.all(8.0),
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: Color.fromARGB(255, 241, 70, 19), width: 2.0), // Pink border for the box
                      ),
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 167, 219, 243), // Light blue background
                          borderRadius: BorderRadius.circular(12.0),
      
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          title: Text(
                            document.id,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LearnPage(songId: document.id),
                                  ),
                                );
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.black26;
                                }
                                return Color.fromARGB(255, 236, 60, 11);
                              }),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Learn',
                              style: TextStyle(
                                color: Color.fromARGB(255, 249, 246, 246),
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
