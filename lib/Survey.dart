import 'package:cinsage/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final List<String> genres = [
    "Action",
    "Comedy",
    "Drama",
    "Horror",
    "Romance",
    "Sci-Fi",
    "Thriller",
    "Adventure",
    "Fantasy",
    "Fiction",
    "Animation",
    "Anime"
  ];
  List<String> selectedGenres = [];
  late BuildContext _scaffoldContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldContext = context;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Movie Genres")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3,
                  crossAxisSpacing: 50,
                  mainAxisSpacing: 50,
                ),
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedGenres.contains(genres[index])) {
                          selectedGenres.remove(genres[index]);
                        } else {
                          if (selectedGenres.length < 5) {
                            selectedGenres.add(genres[index]);
                          } else {
                            ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
                              const SnackBar(
                                content: Text("You can select up to 5 genres."),
                              ),
                            );
                          }
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedGenres.contains(genres[index])
                            ? Colors.blueAccent
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          genres[index],
                          style: TextStyle(
                            color: selectedGenres.contains(genres[index])
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _submitGenres,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  void _submitGenres() async {
    if (selectedGenres.length < 3 || selectedGenres.length > 5) {
      ScaffoldMessenger.of(_scaffoldContext).showSnackBar(const SnackBar(
        content: Text("Please select between 3 and 5 genres."),
      ));
      return;
    }

    showDialog(
      context: _scaffoldContext,
      barrierDismissible: false, // Prevent dialog dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Submission"),
          content: const Text("Are you sure you want to submit your selected genres?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog first

                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    print("User ID: ${user.uid}");
                    await _database.child("users/${user.uid}/genres").set(selectedGenres);
                    ScaffoldMessenger.of(_scaffoldContext).showSnackBar(const SnackBar(
                      content: Text("Genres saved successfully!"),
                    ));
                    // Navigate to MovieListScreen after genres have been saved
                    Navigator.of(_scaffoldContext).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MovieListScreen()),
                    );
                  } else {
                    // Show snackbar if user is not logged in
                    ScaffoldMessenger.of(_scaffoldContext).showSnackBar(const SnackBar(
                      content: Text("User not logged in."),
                    ));
                  }
                } catch (error) {
                  print("Error saving genres: $error");
                  ScaffoldMessenger.of(_scaffoldContext).showSnackBar(const SnackBar(
                    content: Text("Failed to save genres."),
                  ));
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}
