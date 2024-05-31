import 'package:cinsage/Survey.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:animate_do/animate_do.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  SignUpScreen({Key? key});

  void signUp(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Access the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Push the username to the Realtime Database
      if (user != null) {
        await FirebaseDatabase.instance.reference().child('users').child(user.uid).set({
          'user_name': usernameController.text,
        });
      }

      // Navigate to the next screen upon successful sign-up
      // Replace NextScreen() with your desired screen
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
    height: 400,
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
    child: Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
    color: Colors.white,
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
    const SizedBox(height:70),
      FadeInUp(
        duration: const Duration(milliseconds: 2000),
        child: const Text("Forgot Password?", style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1))),
      ),
    ],
    ),
    ),
    ),
    );
  }
}

