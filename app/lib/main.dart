// ignore_for_file: prefer_const_constructors, unused_catch_clause, use_key_in_widget_constructors, use_super_parameters, use_build_context_synchronously, library_private_types_in_public_api, prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}


class App extends StatelessWidget {
final Future<FirebaseApp> _initialization = Firebase.initializeApp();
@override
Widget build(BuildContext context) {
return FutureBuilder(
future: _initialization,
builder: (context, snapshot) {
if (snapshot.hasError) {
return Scaffold(
body: Center(
child: Text(snapshot.error.toString(),
textDirection: TextDirection.ltr)));
}
if (snapshot.connectionState == ConnectionState.done) {
return MyApp();
}
return Center(child: CircularProgressIndicator());
},
);
}
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserState(),
      child: MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          //primary: Colors.deepPurple,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const RandomWords(),
    )
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  var _saved = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  // ignore: unused_field, prefer_typing_uninitialized_variables
  var _user;
  
  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          _saved = _user.favorited;
          var favorites = _saved;
          final tiles = favorites.map(
            (pair) {
              return Dismissible(
                key: const Key('pair'),
                confirmDismiss: (dir) async {
                  bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Suggestion'),
                        content: Text(
                            "Are you sure you want to delete ${pair.asPascalCase} from"
                            "your saved suggestions?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes'),
                          ),
                        ],
                      );
                    },
                  );
                  return confirm;
                },
                onDismissed: (dir) async {
                  await _user.removeFavoritePair(pair);
                },
                background: Container(
                  color: Colors.deepPurple,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Delete Suggestion",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                child: ListTile(
                  title: Text(
                    pair.asPascalCase,
                    style: _biggerFont,
                  ),
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];
          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
    
  void _initiateLoginProcess() {
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController pwdCtrl = TextEditingController();
  const errorLoginSnackBar = SnackBar(
    content: Text('There was an error logging into the app'),
  );
  const errorSignUpSnackBar = SnackBar(
    content: Text('There was an error signing up into the app'),
  );
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext ctx) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
          ),
          body: ListView(
            shrinkWrap: true,
            children: <Widget>[
              const Center(
                  child: Text(
                      'Welcome to Startup Names Generator, please log in!')),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailCtrl,
                decoration: const InputDecoration(
                    labelText: 'Email', prefixIcon: Icon(Icons.email)),
              ),
              TextFormField(
                keyboardType: TextInputType.visiblePassword,
                controller: pwdCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password', prefixIcon: Icon(Icons.lock)),
              ),
              Container(
                height: 50,
                width: 50,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(32)),
                child: ElevatedButton(
                  onPressed: context.watch<UserState>().isLoading
                      ? null
                      : () async {
                          bool loginSuccess = await context
                              .read<UserState>()
                              .logInUser(emailCtrl.text, pwdCtrl.text);
                          if (!mounted) return;
                          loginSuccess
                              ? Navigator.pop(context)
                              : ScaffoldMessenger.of(ctx)
                                  .showSnackBar(errorLoginSnackBar);
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple),
                  child: context.watch<UserState>().isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              Container(
                height: 50,
                width: 50,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(32)),
                child: ElevatedButton(
                    onPressed: context.watch<UserState>().isSigning
                        ? null
                        : () async {
                            //ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            var isSuccess = await context
                                .read<UserState>()
                                .signUp(emailCtrl.text,
                                    pwdCtrl.text);
                            if (!mounted) return;
                            if (isSuccess != null) {
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(errorSignUpSnackBar);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                    child: context.watch<UserState>().isSigning
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Sign up',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
     
      _user = Provider.of<UserState>(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Startup Name Generator'),
            actions: [
              IconButton(
                icon: const Icon(Icons.star , color: Colors.white),
                onPressed: _pushSaved,
                tooltip: 'Saved Suggestions',
              ),
              context.watch<UserState>().isLoggedIn
                  ? IconButton(
                      icon: const Icon(Icons.exit_to_app),
                      onPressed: () async {
                        await context.read<UserState>().signOutUser();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Successfully logged out')));
                      },
                      tooltip: 'Logout',
                    )
                  : IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: _initiateLoginProcess,
                      tooltip: 'Login',
                    )
            ],
          ),
        body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();

          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          final alreadySaved = _saved.contains(_suggestions[index]);
          return ListTile(
            title: Text(
              _suggestions[index].asPascalCase,
              style: _biggerFont,
            ),
            trailing: Icon(
              alreadySaved ? Icons.favorite : Icons.favorite_border,
              color: alreadySaved ? Colors.red : null,
              semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
            ),
            onTap: () async {
              if (alreadySaved) {
                await _user.removeFavoritePair(_suggestions[index]);
              } else {
                await _user.addFavoritePair(_suggestions[index]);
              }
            },
          );
        },
      ),
        );
  }
}

enum Status { uninitialized, authenticated, authenticating, unauthenticated }

class UserState extends ChangeNotifier {
  List<WordPair> _favorited= [];
  User? _user;
  Status _status = Status.uninitialized;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isSigning = false;


  UserState() {
    _auth.authStateChanges().listen((User? firebaseUser) async{
      _user = firebaseUser;
      _status = _user == null ? Status.unauthenticated : Status.authenticated;
      notifyListeners();
    });
  }

  Status get status => _status;
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSigning => _isSigning;
  bool get isLoggedIn => _isLoggedIn;
  List<WordPair> get favorited => _favorited;

  Future<UserCredential?> signUp(String userEmail, String userPassword) async {
    try {
      _isSigning = true;
      _status = Status.authenticating;
      notifyListeners();
      UserCredential wanted = await _auth.createUserWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

    
      await createUserDoc(wanted.user!.uid, userEmail);
      return wanted;
    } catch (e) {
      print(e);
      _status = Status.unauthenticated;
      _isSigning = false;
      notifyListeners();
      return null;
    } finally {
      _isSigning = false;
      if (_status == Status.authenticated) print(true);
    }
  }


  Future<void> createUserDoc(String uid, String email) async {
    await _db.collection('userInfo').doc(uid).set({
      'mail': email,
      'favorited': [],
    });
  }


  Future<bool> logInUser(String userEmail, String userPassword) async {
  _isLoading = true;
  _status = Status.authenticating;
  notifyListeners();

  bool isLoginSuccessful = await tryLogin(userEmail, userPassword);

  if (isLoginSuccessful) {
    _isLoggedIn = true;
    await synchronizeFavorites();
    _status = Status.authenticated;
  } else {
    _status = Status.unauthenticated;
  }

  notifyListeners();
  _isLoading = false;

  return isLoginSuccessful;
}

Future<bool> tryLogin(String userEmail, String userPassword) async {
  try {
    await _auth.signInWithEmailAndPassword(
      email: userEmail,
      password: userPassword,
    );
    return true;
  } catch (error) {
    print(error);
    return false;
  }
}

Future<void> synchronizeFavorites() async {
  await uploadFavoriteItems();
  _favorited = await fetchFavorites();
}

Future signOutUser() async {
  _auth.signOut();
  _status = Status.unauthenticated;
  _user = null;
  _favorited = [];
  _isLoggedIn = false;
  notifyListeners();
  return Future.delayed(Duration.zero);
}

Future<void> uploadFavoriteItems() async {
  if (_status == Status.authenticated || _status == Status.authenticating) {
    var mappedFavorites = mapFavorites(_favorited);
    await updateFavoritesInDatabase(mappedFavorites);
  }
}

List<Map<String, dynamic>> mapFavorites(List<WordPair> favorites) {
  return favorites
      .map((item) => {"first": item.first, "second": item.second})
      .toList();
}

Future<void> updateFavoritesInDatabase(
    List<Map<String, dynamic>> mappedFavorites) async {
  await _db
      .collection('userInfo')
      .doc(_auth.currentUser?.uid)
      .update({'favorited': FieldValue.arrayUnion(mappedFavorites)});
}

Future<List<WordPair>> fetchFavorites() async {
  final result = <WordPair>[];
  try {
    var userDocument =
        await _db.collection('userInfo').doc(_auth.currentUser?.uid).get();
    await userDocument['favorited'].forEach((element) async {
      String first = await element["first"];
      String second = await element["second"];
      result.add(WordPair(first, second));
    });
  } catch (error) {
    // Handles cases where there are no favorites or user is not signed in.
    return Future<List<WordPair>>.value([]);
  }
  return Future<List<WordPair>>.value(result);
}

Future<void> addFavoritePair(WordPair pair) async {
  _favorited.add(pair);
  notifyListeners();
  if (_status == Status.authenticated) {
    await _db.collection('userInfo').doc(_auth.currentUser?.uid).update({
      'favorited': FieldValue.arrayUnion([
        {"first": pair.first, "second": pair.second}
      ]),
    });
  }
}

Future<void> removeFavoritePair(WordPair pair) async {
  _favorited.remove(pair);
  notifyListeners();
  if (_status == Status.authenticated) {
    await _db.collection("userInfo").doc(_auth.currentUser?.uid).update({
      'favorited': FieldValue.arrayRemove([
        {"first": pair.first, "second": pair.second}
      ]),
    });
  }
}
  
}