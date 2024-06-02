import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'main.dart';


class Searchdetails extends StatelessWidget {
  final String title;
  final String posterUrl;
  final String releaseDate;
  final String overview;
  final double rating;

  const Searchdetails({
    required this.title,
    required this.posterUrl,
    required this.releaseDate,
    required this.overview,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(posterUrl),
            const SizedBox(height: 8.0),
            Text('Release Date: $releaseDate'),
            const SizedBox(height: 8.0),
            Text('Rating: $rating'),
            const SizedBox(height: 8.0),
            Text('Overview: $overview'),
          ],
        ),
      ),
    );
  }
}