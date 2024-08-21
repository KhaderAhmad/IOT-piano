import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tracking_board_app/navigation_bar_widgets/show_tasks.dart';
import 'package:tracking_board_app/screens/signin_screen.dart';

import '../navigation_bar_widgets/add_task.dart';
import '../navigation_bar_widgets/logout.dart';
import '../navigation_bar_widgets/progress.dart';

class HomeScreen extends StatefulWidget {
  final String vec1;
  final String name1;
  final Map<String, dynamic> tasks1;
  const HomeScreen(
      {super.key, required this.vec1, required this.name1, required this.tasks1});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _widgetOptions;
  late Connectivity _connectivity;
  late bool _isConnected;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      ShowSongs(userName: widget.name1),
      AddSong(userName: widget.name1, songs: widget.tasks1),
      Progress(vec1: widget.vec1, name1: widget.name1),
      LogOut(name1: widget.name1),
    ];

    _connectivity = Connectivity();
    _isConnected = true;
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
        if (!_isConnected && !flag) {
          _showConnectionLostMessage();
          flag = true;
        }
        if (_isConnected && flag) {
          _showConnectionRestoredMessage();
          flag = false;
        }
      });
    });
  }

  bool flag = false;

  @override
  Widget build(BuildContext context) {
    Future<int> getUsersDocumentSize() async {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      return querySnapshot.size;
    }

    getUsersDocumentSize().then((size) {
      if (size == 0) {
        FirebaseAuth.instance.signOut().then((value) => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignInScreen()))
            });
      }
    });

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_currentIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.music_note, size: 30, color: Colors.white),
          Icon(Icons.add, size: 30, color: Colors.white),
          Icon(Icons.bar_chart, size: 30, color: Colors.white),
          Icon(Icons.logout, size: 30, color: Colors.white),
        ],
        color: Color(0xFF4B39EF),
        buttonBackgroundColor: Color(0xFF4B39EF),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  void _showConnectionLostMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: const Text('Internet connection lost'),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConnectionRestoredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: const Text('Internet connection restored'),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }
}
