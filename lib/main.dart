import 'dart:convert';
import 'dart:math';
import 'package:cinsage/Chat.dart';
import 'package:cinsage/Survey.dart';
import 'package:cinsage/accounts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cinsage/firebase_options.dart';
import 'package:carousel_slider/carousel_slider.dart';

Future<void> main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:
  DefaultFirebaseOptions.currentPlatform,);

}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TMDB Flutter App',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red, // Customize primary color
        secondaryHeaderColor: Colors.black, // Customize accent color
        colorScheme: const ColorScheme(brightness: Brightness.dark, primary: Colors.blue, onPrimary: Colors.red,
            secondary: Colors.red, onSecondary: Colors.lightBlueAccent, error: Colors.red, onError: Colors.redAccent, surface: Colors.black, onSurface: Colors.white)
      ),
      home: const MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  _MovieListScreenState createState() => _MovieListScreenState();

  void onApplyFilters(List<String> selectedGenres, DateTime? selectedReleaseDate, String? selectedLanguage, double? selectedRating) {}
}

class _MovieListScreenState extends State<MovieListScreen> with SingleTickerProviderStateMixin {

  final String apiKey = '2739efeaf44f3e2a44571898f5523c92';
  final Uri apiUrlTvShows = Uri.parse(
      'https://api.themoviedb.org/3/tv/popular');

  //final Uri apiUrlUrdu=Uri.parse('https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&region=PK');
  final int _selectedIndex1 = 0;


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ChatPage()),);
      }
    });
  }

  late TabController _tabController;
  late DrawerController _drawerController;

  List<dynamic> movies = [];
  List<dynamic> tvShows = [];
  List<dynamic> Umovies = [];
  List<dynamic> UtvShows = [];

  List<dynamic> movieRatings = [];
  List<dynamic> tvShowRatings = [];
  List<dynamic> umovieRatings = [];
  List<dynamic> utvShowRatings = [];
  List<String> selectedGenres = [];
  DateTime? selectedReleaseDate;
  String? selectedLanguage;
  double? selectedRating;
  int _selectedIndex = 0;

  void navToChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          fetchMovies();
          fetchUrduMovies();
        } else if (_tabController.index == 1) {
          fetchTvShows();
          fetchUrduTvShows();
        }
      }
    });
    fetchMovies();
    fetchUrduMovies();
  }


  Future<void> fetchMovies() async {
    final pkUrl = 'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&region=PK';
    final response = await http.get(Uri.parse(pkUrl));


    if (response.statusCode == 200) {
      setState(() {
        movies = json.decode(response.body)['results'];
        movieRatings = movies.map((movie) => movie['vote_average']).toList();
      });
    } else {
      // Handle errors
      print('Failed to load movies');
    }
  }

  Future<void> fetchTvShows() async {
    final pkUrl = 'https://api.themoviedb.org/3/discover/tv?api_key=$apiKey&region=PK';
    final response = await http.get(Uri.parse(pkUrl));

    if (response.statusCode == 200) {
      List<dynamic> tvShowsData = json.decode(response.body)['results'];

      setState(() {
        tvShows = tvShowsData;
        tvShowRatings =
            tvShowsData.map((show) => show['vote_average']).toList();
      });
    } else {
      // Handle errors
      print('Failed to load TV shows');
    }
  }

  Future<void> fetchUrduMovies() async {
    final pkUrl = 'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&with_original_language=ur';
    final response = await http.get(Uri.parse(pkUrl));

    if (response.statusCode == 200) {
      setState(() {
        Umovies = json.decode(response.body)['results'];
        umovieRatings = Umovies.map((movie) => movie['vote_average']).toList();
      });
    } else {
      // Handle errors
      print('Failed to load movies');
    }
  }

  Future<void> fetchUrduTvShows() async {
    final pkUrl = 'https://api.themoviedb.org/3/discover/tv?api_key=$apiKey&with_original_language=ur';
    final response = await http.get(Uri.parse(pkUrl));

    if (response.statusCode == 200) {
      List<dynamic> tvShowsData = json.decode(response.body)['results'];

      setState(() {
        UtvShows = json.decode(response.body)['results'];
        utvShowRatings = UtvShows.map((show) => show['vote_average']).toList();
      });
    } else {
      // Handle errors
      print('Failed to load TV shows');
    }
  }

  void _openFiltersMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Filter Options',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildGenresFilter(setState),
                    SizedBox(height: 16),
                    _buildReleaseDateFilter(context),
                    SizedBox(height: 16),
                    _buildLanguageFilter(setState),
                    SizedBox(height: 16),
                    _buildRatingFilter(setState),
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Apply the filters and close the modal
                          widget.onApplyFilters(
                            selectedGenres,
                            selectedReleaseDate,
                            selectedLanguage,
                            selectedRating,
                          );
                          Navigator.pop(context); // Close the Filters menu
                        },
                        child: Text(
                          'Apply Filters',
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildReleaseDateFilter(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('Release Date'),
      subtitle: Text(selectedReleaseDate != null ? '${selectedReleaseDate!.toLocal()}'.split(' ')[0] : 'Any'),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedReleaseDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null) {
          setState(() {
            selectedReleaseDate = picked;
          });
        }
      },
    );
  }

  Widget _buildGenresFilter(StateSetter setState) {
    final genres = ['Action', 'Comedy', 'Drama', 'Horror', 'Romance', 'Sci-Fi'];

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: genres.map((genre) {
        final isSelected = selectedGenres.contains(genre);
        return FilterChip(
          label: Text(genre),
          selected: isSelected,
          selectedColor: Colors.blue,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                selectedGenres.add(genre);
              } else {
                selectedGenres.remove(genre);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildLanguageFilter(StateSetter setState) {
    final languages = ['English', 'Urdu'];

    return DropdownButtonFormField<String>(
      value: selectedLanguage,
      decoration: InputDecoration(
        labelText: 'Language',
        border: OutlineInputBorder(),
      ),
      items: languages.map((String language) {
        return DropdownMenuItem<String>(
          value: language,
          child: Text(language),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedLanguage = newValue;
        });
      },
    );
  }

  Widget _buildRatingFilter(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            for (int i = 1; i <= 10; i++)
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRating = i.toDouble();
                  });
                },
                child: Icon(
                  i <= (selectedRating ?? 0) ? Icons.star : Icons.star_border,
                  color: i <= (selectedRating ?? 0) ? Colors.orange : Colors.grey,
                ),
              ),
          ],
        ),
        if (selectedRating != null)
          Text(
            '${selectedRating!.toInt()} Star${selectedRating! > 1 ? 's' : ''}',
            style: TextStyle(color: Colors.black),
          ),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: SizedBox(
          height: 1200,
          child: Column(
            children: [
              buildRatingSlideshow(movies),
              _buildSectionHeader('Popular'),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHorizontalList(movies, movieRatings.map((rating) => rating as double?).toList(), true),
                    _buildHorizontalList(tvShows, tvShowRatings.map((rating) => rating as double?).toList(), false),
                  ],
                ),
              ),
              _buildSectionHeader('Pakistani'),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHorizontalList(Umovies, umovieRatings.map((rating) => rating as double?).toList(), true),
                    _buildHorizontalList(UtvShows, utvShowRatings.map((rating) => rating as double?).toList(), false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black, // Set the background color of the bottom navigation bar to dark blue
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.movie, size: 28, color: Colors.white),
          label: 'Movies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.live_tv, size: 28, color: Colors.white),
          label: 'TV Shows',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat, size: 28, color: Colors.white),
          label: 'Chat',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
          _tabController.index = _selectedIndex;

          if (_selectedIndex == 0) {
            fetchMovies();
            fetchUrduMovies();
          } else if (_selectedIndex == 1) {
            fetchTvShows();
            fetchUrduTvShows();
          }
          else if (index==2){
            _onItemTapped(index);

          }
        });
      },
    );
  }



  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Cinsage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      elevation: 10,
      backgroundColor: Colors.black26,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, size: 24),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: _openFiltersMenu,
          icon: const Icon(Icons.tune, size: 24), // Updated icon to "tune"
        ),
        IconButton(
          onPressed: () {
            showSearch(
              context: context,
              delegate: MovieSearchDelegate(
                selectedGenres: selectedGenres,
                selectedReleaseDate: selectedReleaseDate,
                selectedLanguage: selectedLanguage,
                selectedRating: selectedRating,
              ),
            );
          },
          icon: const Icon(Icons.search, size: 24),
        ),
      ],
      bottomOpacity: 0.5,
    );
  }



  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset(
                  //   'assets/logo.png', // Path to your logo image
                  //   width: 40,
                  //   height: 40,
                  // ),
                  SizedBox(width: 10),
                  Text(
                    'Cinsage',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.blueAccent),
            title: const Text('Account', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => const AccountsScreen())

              );
            },
          ),
          ListTile(
            leading: Icon(Icons.display_settings, color: Colors.blueAccent),
            title: const Text('Display', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.blueAccent),
            title: const Text('Settings', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.blueAccent),
            title: const Text('Notifications', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.storage, color: Colors.blueAccent),
            title: const Text('Storage', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.blueAccent),
            title: const Text('About', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback, color: Colors.blueAccent),
            title: const Text('Send Feedback', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.logout, color: Colors.black),
                label: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildSectionHeader(String title) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHorizontalList(List<dynamic> items, List<double?> ratings, bool isMovie) {
    final ScrollController scrollController = ScrollController();

    void scrollLeft() {
      scrollController.animateTo(
        scrollController.offset - 150, // Adjust this value to your liking
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }

    void scrollRight() {
      scrollController.animateTo(
        scrollController.offset + 150, // Adjust this value to your liking
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: scrollLeft,
        ),
        Expanded(
          child: SizedBox(
            height: 250,
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final posterPath = item['poster_path'];
                final posterUrl = 'https://image.tmdb.org/t/p/w185/$posterPath';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailsScreen(
                          title: isMovie ? item['title'] : item['name'],
                          posterUrl: posterUrl,
                          releaseDate: isMovie ? item['release_date'] : item['first_air_date'],
                          overview: item['overview'],
                          rating: ratings[index],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                            child: CachedNetworkImage(
                              imageUrl: posterUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            isMovie ? item['title'] : item['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: scrollRight,
        ),
      ],
    );
  }




  Widget buildRatingSlideshow(List<dynamic> items) {
    items.sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));

    return CarouselSlider.builder(
      itemCount: items.length,
      options: CarouselOptions(
        height: 500.0,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        viewportFraction: 0.8,
      ),
      itemBuilder: (BuildContext context, int index, int realIndex) {
        final item = items[index];
        final posterPath = item['poster_path'];
        final posterUrl = 'https://image.tmdb.org/t/p/w500/$posterPath';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(
                  title: item['title'] ?? item['name'] ?? 'N/A',
                  posterUrl: posterUrl,
                  releaseDate: item['release_date'] ?? '',
                  overview: item['overview'] ?? 'No overview available.',
                  rating: item['vote_average']?.toDouble() ?? 0.0,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            width: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              image: DecorationImage(
                image: NetworkImage(posterUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}


class MovieDetailsScreen extends StatefulWidget {
  final String title;
  final String posterUrl;
  final String releaseDate;
  final String overview;
  final double? rating;

  MovieDetailsScreen({
    required this.title,
    required this.posterUrl,
    required this.releaseDate,
    required this.overview,
    required this.rating,
  });

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}




class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool isWatchlistAdded = false;
  bool isSeen = false;
  bool isLiked = false;
  bool isDisliked = false;
  int likes = Random().nextInt(100); // Random initial likes count
  int dislikes = Random().nextInt(50); // Random initial dislikes count
  int duration = 90 + Random().nextInt(90); // Random duration between 90 and 180 minutes
  int userRating = 0; // User's rating

  void onStarTap(int rating) {
    setState(() {
      userRating = rating;
    });
  }

  String getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Bad!';
      case 2:
        return 'Fair!';
      case 3:
        return 'Good!';
      case 4:
        return 'Very Good!';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    widget.posterUrl,
                    width: 150,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 35),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'PG-13',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '$duration mins',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Rating: ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.rating != null ? widget.rating!.toStringAsFixed(1) : 'N/A',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: 8),
                            if (widget.rating != null)
                              Icon(Icons.star, color: Colors.amber)
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.releaseDate,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          isWatchlistAdded ? Icons.bookmark : Icons.bookmark_border,
                          color: isWatchlistAdded ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isWatchlistAdded = !isWatchlistAdded;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isWatchlistAdded ? 'Added to watchlist' : 'Removed from watchlist')),
                          );
                        },
                      ),
                      Text(
                        'Watchlist',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          isSeen ? Icons.visibility : Icons.visibility_off,
                          color: isSeen ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isSeen = !isSeen;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isSeen ? 'Marked as seen' : 'Marked as not seen')),
                          );
                        },
                      ),
                      Text(
                        'Seen',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                          color: isLiked ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isDisliked) {
                              isDisliked = false;
                              dislikes--;
                            }
                            isLiked = !isLiked;
                            if (isLiked) {
                              likes++;
                            } else {
                              likes--;
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isLiked ? 'Liked' : 'Unliked')),
                          );
                        },
                      ),
                      Text(
                        'Like ($likes)',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          isDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
                          color: isDisliked ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isLiked) {
                              isLiked = false;
                              likes--;
                            }
                            isDisliked = !isDisliked;
                            if (isDisliked) {
                              dislikes++;
                            } else {
                              dislikes--;
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isDisliked ? 'Disliked' : 'Undisliked')),
                          );
                        },
                      ),
                      Text(
                        'Dislike ($dislikes)',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 32),
              DefaultTabController(
                length: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'About'),
                        Tab(text: 'Comments'),
                        Tab(text: 'Review'),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 300,
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  widget.overview,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Center(child: Text('Comments')),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Rate the movie:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return IconButton(
                                    icon: Icon(
                                      index < userRating ? Icons.star : Icons.star_border,
                                      color: index < userRating ? Colors.amber : Colors.grey,
                                    ),
                                    onPressed: () => onStarTap(index + 1),
                                  );
                                }),
                              ),
                              SizedBox(height: 8),
                              Text(
                                getRatingText(userRating),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieSearchDelegate extends SearchDelegate {
  final String apiKey = '2739efeaf44f3e2a44571898f5523c92';
  final Uri apiUrl = Uri.parse('https://api.themoviedb.org/3/search/multi');

  final List<String> selectedGenres;
  final DateTime? selectedReleaseDate;
  final String? selectedLanguage;
  final double? selectedRating;

  MovieSearchDelegate({
    required this.selectedGenres,
    required this.selectedReleaseDate,
    required this.selectedLanguage,
    required this.selectedRating,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: fetchSearchResults(query, selectedGenres, selectedReleaseDate, selectedLanguage, selectedRating),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Text('No results found');
        } else {
          List<dynamic> searchResults = snapshot.data as List<dynamic>;

          return ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final result = searchResults[index];
              final title = result['title'] ?? result['name'];
              final rating = result['rating'];

              return ListTile(
                title: Text(title),
                onTap: () {
                  // Navigate to the details screen with rating
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailsScreen(
                        title: title,
                        posterUrl: 'https://image.tmdb.org/t/p/w185/${result['poster_path']}',
                        releaseDate: result['release_date'] ?? '',
                        overview: result['overview'] ?? 'No overview available.',
                        rating: rating,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  Future<List<dynamic>> fetchSearchResults(String query, List<String> selectedGenres, DateTime? selectedReleaseDate, String? selectedLanguage, double? selectedRating) async {
    final response = await http.get(apiUrl.replace(queryParameters: {
      'api_key': apiKey,
      'query': query,
      // Add filter parameters to the API request
      'with_genres': selectedGenres.isNotEmpty ? selectedGenres.join(',') : null,
      'release_date.gte': selectedReleaseDate?.toIso8601String(),
      'language': selectedLanguage,
      'vote_average.gte': selectedRating?.toString(),
    }));

    if (response.statusCode == 200) {
      List<dynamic> searchResults = json.decode(response.body)['results'];

      // Fetch ratings for each search result
      for (var result in searchResults) {
        String type = result['media_type'] ?? 'movie'; // Default to movie if media_type is null
        int id = result['id'];

        final ratingResponse = await http.get(Uri.parse('https://api.themoviedb.org/3/$type/$id?api_key=$apiKey'));
        if (ratingResponse.statusCode == 200) {
          result['rating'] = json.decode(ratingResponse.body)['vote_average'];
        } else {
          result['rating'] = null;
        }
      }

      return searchResults;
    } else {
      // Handle errors
      print('Failed to load search results');
      return [];
    }
  }

}

class FiltersMenu extends StatefulWidget {
  final List<String> selectedGenres;
  late final DateTime? selectedReleaseDate;
  late final String? selectedLanguage;
  late final double? selectedRating;
  final Function(List<String>, DateTime?, String?, double?) onApplyFilters;

   FiltersMenu({super.key,
    required this.selectedGenres,
    required this.selectedReleaseDate,
    required this.selectedLanguage,
    required this.selectedRating,
    required this.onApplyFilters,
  });

  @override
  _FiltersMenuState createState() => _FiltersMenuState();
}

class _FiltersMenuState extends State<FiltersMenu> {
  late List<String> availableGenres = ['Action', 'Drama', 'Comedy', 'Sci-Fi']; // Replace with actual genre list
  late TextEditingController _dateController;
  double _ratingSliderValue = 5.0;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    if (widget.selectedReleaseDate != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(widget.selectedReleaseDate!);
    }
    if (widget.selectedRating != null) {
      _ratingSliderValue = widget.selectedRating!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          DropdownButton<String>(
            value: widget.selectedGenres.isNotEmpty ? widget.selectedGenres[0] : null,
            onChanged: (String? newValue) {
              setState(() {
                widget.selectedGenres.clear();
                if (newValue != null) {
                  widget.selectedGenres.add(newValue);
                }
              });
            },
            items: availableGenres.map((String genre) {
              return DropdownMenuItem<String>(
                value: genre,
                child: Text(genre),
              );
            }).toList(),
            hint: const Text('Select Genre',style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          DropdownButton<int>(
            value: widget.selectedReleaseDate?.year,
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  widget.selectedReleaseDate = DateTime(newValue);
                  _dateController.text = newValue.toString();
                });
              }
            },
            items: getReleaseYearDropdownItems(),
            hint: const Text('Select Release Year',style:TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: widget.selectedLanguage,
            onChanged: (String? newValue) {
              setState(() {
                widget.selectedLanguage = newValue;
              });
            },
            items: ['English', 'Spanish', 'French', 'German'] // Replace with actual language list
                .map((String language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            hint: const Text('Select Language',style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Rating: ${_ratingSliderValue.toStringAsFixed(1)}'),
              Slider(
                value: _ratingSliderValue,
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (double value) {
                  setState(() {
                    _ratingSliderValue = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Ensure at least one filter is selected before calling fetchFilteredResults
              if (widget.selectedGenres.isNotEmpty ||
                  widget.selectedReleaseDate != null ||
                  widget.selectedLanguage != null ||
                  widget.selectedRating != null) {
                List<dynamic> results = await fetchFilteredResults();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultScreen(searchResults: results),
                  ),
                );
              }
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );


  }
  List<DropdownMenuItem<int>> getReleaseYearDropdownItems() {
    // Generate a list of years from 2000 to 2024
    List<int> years = List.generate(25, (index) => 2000 + index);

    return years.map((year) {
      return DropdownMenuItem<int>(
        value: year,
        child: Text(year.toString()),
      );
    }).toList();
  }
  Future<List<dynamic>> fetchFilteredResults() async {
    const String apiKey = '2739efeaf44f3e2a44571898f5523c92';
    final Uri apiUrl = Uri.parse('https://api.themoviedb.org/3/discover/movie');

    Map<String, dynamic> queryParameters = {
      'api_key': apiKey,
    };

    // Add filters to query parameters if they are selected
    if (widget.selectedGenres.isNotEmpty) {
      queryParameters['with_genres'] = widget.selectedGenres.join(',');
    }

    if (widget.selectedReleaseDate != null) {
      queryParameters['primary_release_year'] = widget.selectedReleaseDate!.year.toString();
    }

    if (widget.selectedLanguage != null) {
      queryParameters['language'] = widget.selectedLanguage!;
    }

    if (widget.selectedRating != null) {
      queryParameters['vote_average.gte'] = widget.selectedRating!.toString();
    }

    final response = await http.get(apiUrl.replace(queryParameters: queryParameters));

    if (response.statusCode == 200) {
      List<dynamic> searchResults = json.decode(response.body)['results'];

      // Fetch ratings for each search result
      for (var result in searchResults) {
        String type = 'movie'; // You are specifically searching for movies
        int id = result['id'];

        final ratingResponse = await http.get(Uri.parse('https://api.themoviedb.org/3/$type/$id?api_key=$apiKey'));
        if (ratingResponse.statusCode == 200) {
          result['rating'] = json.decode(ratingResponse.body)['vote_average'];
        } else {
          result['rating'] = null;
        }
      }

      return searchResults;
    } else {
      // Handle errors
      print('Failed to load filtered results');
      print('Response Code: ${response.statusCode}');
      return [];
    }
  }



}
class SearchResultScreen extends StatelessWidget {
  final List<dynamic> searchResults;

  const SearchResultScreen({super.key, required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // You can adjust the number of columns as needed
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          // Build your UI for each search result here
          // You can use a similar approach as in the MovieDetailsScreen
          final result = searchResults[index];

          return GestureDetector(
            onTap: () {
              // Handle the tap on the grid item, e.g., navigate to details screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsScreen(
                    title: result['title'] ?? result['name'] ?? 'N/A',
                    posterUrl: 'https://image.tmdb.org/t/p/w185/${result['poster_path']}',
                    releaseDate: result['release_date'] ?? '',
                    overview: result['overview'] ?? 'No overview available.',
                    rating: result['rating']?.toDouble(),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage('https://image.tmdb.org/t/p/w185/${result['poster_path']}'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    result['title'] ?? result['name'] ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}