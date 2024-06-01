import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:animate_do/animate_do.dart';
import 'package:cinsage/Survey.dart';
import 'dart:io'as io;

class SignUpScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  File? _image;

  SignUpScreen({Key? key});

  void signUp(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Access the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Upload profile picture to Firebase Storage
      String? profilePictureUrl = await _uploadProfilePicture(user!.uid);

      // Push the username and profile picture URL to the Realtime Database
      if (user != null) {
        await FirebaseDatabase.instance.reference().child('users').child(user.uid).set({
          'user_name': usernameController.text,
          'profile_picture': profilePictureUrl,
        });
      }

      // Navigate to the next screen upon successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SurveyPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Sign-up Failed'),
              content: const Text('An unexpected error occurred. Please try again later.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String?> _uploadProfilePicture(String userId) async {
    if (_image != null) {
      try {
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('profile_pictures').child('$userId.jpg');
        await ref.putFile(_image!);
        return await ref.getDownloadURL();
      } catch (e) {
        print('Error uploading profile picture: $e');
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> _getImage(BuildContext context, ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For web platform, create a File object from the selected file using the createFileFromBytes method.
        final bytes = await pickedFile.readAsBytes();
        _image = File(pickedFile.name)
          ..writeAsBytes(bytes);
      } else {
        // For other platforms, use the picked file directly.
        _image = File(pickedFile.path);
      }
    }

    Navigator.pop(context);
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a picture'),
                onTap: () {
                  _getImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  _getImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
    body: SingleChildScrollView(
    child: Container(
    padding: const EdgeInsets.all(20.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    Container(
    height: 300,
    decoration: const BoxDecoration(
    image: DecorationImage(
    image: AssetImage('assets/background.png'),
    fit: BoxFit.fill,
    ),
    ),
    child: Stack(
    children: <Widget>[
    Positioned(
    left: 30,
    width: 80,
    height: 200,
    child: FadeInUp(
    duration: const Duration(seconds: 1),
    child: Container(
    decoration: const BoxDecoration(
    image: DecorationImage(
    image: AssetImage('assets/light-1.png'),
    ),
    ),
    ),
    ),
    ),
    Positioned(
    left: 140,
    width: 80,
    height: 150,
    child: FadeInUp(
    duration: const Duration(milliseconds: 1200),
    child: Container(
    decoration: const BoxDecoration(
    image: DecorationImage(
    image: AssetImage('assets/light-2.png'),
    ),
    ),
    ),
    ),
    ),
    Positioned(
    right: 40,
    top: 40,
    width: 80,
    height: 150,
    child: FadeInUp(
    duration: const Duration(milliseconds: 1300),
    child: Container(
    decoration: const BoxDecoration(
    image: DecorationImage(
    image: AssetImage('assets/clock.png'),
    ),
    ),
    ),
    ),
    ),
    Positioned(
    child: FadeInUp(
    duration: const Duration(milliseconds: 1600),
    child: Container(
    margin: const EdgeInsets.only(top: 50),
    child: const Center(
    child: Text(
    "Sign Up",
    style: TextStyle(
    color: Colors.white,
    fontSize: 40,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    ),
    ),
    ),
    ],
    ),
    ),
    const SizedBox(height: 30),
    FadeInUp(
    duration: const Duration(milliseconds: 1800),
    child: GestureDetector(
    onTap: () {
    _showImagePicker(context);
    },
    child: CircleAvatar(
    radius: 50,
    backgroundImage: _image != null ? FileImage(_image!) : null,
    child: _image == null
    ? const Icon(
    Icons.add_a_photo,
    size: 50,
    )
        : null,
    ),
    ),
    ),
    const SizedBox(height: 30),
    FadeInUp(
    duration: const Duration(milliseconds: 1800),
    child: Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
    color : Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color.fromRGBO(143, 148, 251, 1)),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(143, 148, 251, .2),
          blurRadius: 20.0,
          offset: Offset(0, 10),
        ),
      ],
    ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color.fromRGBO(143, 148, 251, 1))),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              controller: emailController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Email or Phone number",
                hintStyle: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Password",
                hintStyle: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              controller: usernameController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Username",
                hintStyle: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    ),
    ),
      const SizedBox(height: 30),
      FadeInUp(
        duration: const Duration(milliseconds: 1900),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            onPressed: () => signUp(context),
            child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),

    ],
    ),
    ),
    ),
    );
  }
}

