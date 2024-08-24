import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/signin_screen.dart';
import 'walkthrough_screen.dart'; // Import the WalkthroughScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // Check if the walkthrough has been seen
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seenWalkthrough = prefs.getBool('seenWalkthrough') ?? false;

  runApp(MyApp(seenWalkthrough: seenWalkthrough));
}

class MyApp extends StatelessWidget {
  final bool seenWalkthrough;

  const MyApp({Key? key, required this.seenWalkthrough}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: seenWalkthrough ? const SignInScreen() : WalkthroughScreen(), // Show WalkthroughScreen or SignInScreen
      debugShowCheckedModeBanner: false,
    );
  }
}
