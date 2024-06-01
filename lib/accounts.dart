import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  User? _user;
  String? _userName;
  String? _profilePictureUrl;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  // Function to check if a user is logged in and fetch user name and profile picture
  // Function to check if a user is logged in and fetch user name and profile picture
  Future<void> _getUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      DatabaseReference userRef = _database.child('users').child(user.uid);
      try {
        DatabaseEvent event = await userRef.once();
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic>? userData = snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null) {
          setState(() {
            _user = user;
            _userName = userData['user_name'] as String?;
            _profilePictureUrl = userData['profile_picture'] as String?;
          });
        }
      } catch (error) {
        print("Failed to retrieve user's data: $error");
      }
    } else {
      setState(() {
        _user = null;
        _userName = null;
        _profilePictureUrl = null;
      });
    }
  }


  // Function to handle sign out
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _user = null;
      _userName = null;
      _profilePictureUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: Center(
        child: _user != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _profilePictureUrl != null
                  ? NetworkImage(_profilePictureUrl!)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              'Logged in as ${_user!.email}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Name: ${_userName ?? 'No Name Provided'}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 16)),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Cinsage App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'To access more features, please sign up or log in.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to the login screen
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Login', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AccountsScreen(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
