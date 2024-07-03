import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cinsage/Chat.dart';
import 'package:cinsage/Chatbot.dart';
import 'package:cinsage/accounts.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinsage/firebase_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'const.dart';
import 'dart:async';

//import 'Chatbot.dart';


Future<void> main() async {
  Gemini.init(apiKey: GEMINI_API_KEY);

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
        primaryColor: Colors.blueAccent, // Customize primary color
        secondaryHeaderColor: Colors.black, // Customize accent color
        colorScheme: const ColorScheme(brightness: Brightness.dark, primary: Colors.blue, onPrimary: Colors.black,
            secondary: Colors.blue, onSecondary: Colors.black, error: Colors.red, onError: Colors.redAccent, surface: Colors.black, onSurface: Colors.white)
      ),
      home: const MovieListScreen(),
    );
  }
}

class FilterDebounce {
Timer? _debounce;

void run(VoidCallback action, {Duration duration = const Duration(milliseconds: 500)}) {
  if (_debounce?.isActive ?? false) _debounce?.cancel();
  _debounce = Timer(duration, action);
}

void dispose() {
  _debounce?.cancel();
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
  final FilterDebounce debounce = FilterDebounce();


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ChatPage()),);
      }
    });
  }
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();

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
  int? selectedReleaseYear;

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
                    _buildReleaseDateFilter(setState),
                    SizedBox(height: 16),
                    _buildLanguageFilter(setState),
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          debounce.run(() async {
                            // Load movies
                            List<Movie> allMovies = await loadMovies('assets/movies.csv');
                            print('All movies loaded: ${allMovies.length}');

                            // Apply filters
                            List<Movie> filteredMovies = allMovies.where((movie) {
                              bool matchesGenre = selectedGenres.isEmpty ||
                                  selectedGenres.any((genre) => movie.genre.toLowerCase().split(', ').contains(genre.toLowerCase()));
                              bool matchesReleaseYear = selectedReleaseYear == null ||
                                  (movie.releaseYear != null && movie.releaseYear == selectedReleaseYear);
                              bool matchesLanguage = selectedLanguage == null ||
                                  movie.language.toLowerCase() == selectedLanguage!.toLowerCase();
                              return matchesGenre && matchesReleaseYear && matchesLanguage;
                            }).toList();

                            // Debugging output
                            print('Selected Genres: $selectedGenres');
                            print('Selected Release Year: $selectedReleaseYear');
                            print('Selected Language: $selectedLanguage');
                            print('Filtered movies: ${filteredMovies.length}');
                            for (var movie in filteredMovies) {
                              print('Filtered movie: ${movie.title}, Genre: ${movie.genre}, Release Year: ${movie.releaseYear}, Language: ${movie.language}');
                            }

                            // Navigate to filtered movie list screen
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => FilteredMoviesScreen(
                                  movies: filteredMovies,
                                ),
                              ),
                            );
                          });
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

  Widget _buildReleaseDateFilter(StateSetter setState) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('Release Year'),
      subtitle: Text(selectedReleaseYear != null ? '$selectedReleaseYear' : 'Any'),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Select Release Year'),
              content: Container(
                width: double.minPositive,
                child: YearPicker(
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  initialDate: DateTime.now(),
                  selectedDate: selectedReleaseYear != null
                      ? DateTime(selectedReleaseYear!)
                      : DateTime.now(),
                  onChanged: (DateTime dateTime) {
                    setState(() {
                      selectedReleaseYear = dateTime.year;
                      Navigator.pop(context);
                    });
                  },
                ),
              ),
            );
          },
        );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Chatbot()),
          );
        },
        child: SvgPicture.asset('assets/cb_icon.svg',
            width: 35,
            height: 35,
          color: Colors.black,
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



          //masla yaha he boss




          ListTile(
            leading: Icon(Icons.person, color: Colors.blueAccent),
            title: const Text('Account', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) =>  AccountsScreen())

              );
            },
          ),

          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(

              child: ElevatedButton.icon(
                onPressed: () {
                  _signOut();
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: "Signed out successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
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
  final List<String> selectedGenres;
  final DateTime? selectedReleaseDate;
  final String? selectedLanguage;
  final double? selectedRating;
  List<Map<String, dynamic>> movies = [];
  bool isCsvLoaded = false;

  MovieSearchDelegate({
    required this.selectedGenres,
    required this.selectedReleaseDate,
    required this.selectedLanguage,
    required this.selectedRating,
  }) {
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    final csvData = await rootBundle.loadString('assets/movies.csv');
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);

    movies = csvTable.skip(1).map<Map<String, dynamic>>((row) {
      try {
        return {
          'title': row[2].toString(),
          'genres': row[3].toString().split(','),
          'release_date': row[4].toString(),
          'language': row[5].toString(),
          'rating': double.tryParse(row[6].toString()),
          'overview': row[7].toString(),
          'poster_url': row[10].toString(),




        };
      } catch (e) {
        return {};
      }
    }).toList();

    isCsvLoaded = true;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
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
    if (!isCsvLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredMovies = fetchSearchResults(query);

    return filteredMovies.isEmpty
        ? const Center(child: Text('No results found'))
        : ListView.builder(
      itemCount: filteredMovies.length,
      itemBuilder: (context, index) {
        final movie = filteredMovies[index];
        final title = movie['title'];
        final rating = movie['rating'];

        return ListTile(
          title: Text(title),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(
                  title: title,
                  posterUrl: movie['poster_url'],
                  releaseDate: movie['release_date'],
                  overview: movie['overview'],
                  rating: rating,
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> fetchSearchResults(String query) {
    return movies.where((movie) {
      return movie['title'].toString().toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}


class Movie {
  final String title;
  final String posterUrl;
  final String releaseDate;
  final String overview;
  final double rating;
  final String genre;
  final String language;

  Movie({
    required this.title,
    required this.posterUrl,
    required this.releaseDate,
    required this.overview,
    required this.rating,
    required this.genre,
    required this.language,
  });

  factory Movie.fromCsv(List<dynamic> csvRow) {
    return Movie(
      title: csvRow[2].toString(),
      posterUrl: csvRow[10].toString(),
      releaseDate: csvRow[4].toString(),
      overview: csvRow[8].toString(),
      rating: double.tryParse(csvRow[6].toString()) ?? 0.0,
      genre: csvRow[3].toString(),
      language: csvRow[5].toString(),
    );
  }

  int? get releaseYear {
    try {
      final parts = releaseDate.split('/');
      if (parts.length == 3) {
        return int.parse(parts[2]);
      } else if (releaseDate.length == 4) { // For cases where only the year is provided
        return int.parse(releaseDate);
      }
    } catch (e) {
      print('Error parsing release year: $e');
    }
    return null;
  }
}

Future<List<Movie>> loadMovies(String path) async {
  final csvData = await rootBundle.loadString(path);
  List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);

  final movies = csvTable.skip(1).map<Movie>((row) {
    return Movie.fromCsv(row);
  }).toList();

  for (var movie in movies.take(10)) {
    print('Parsed movie: ${movie.title}, Genre: ${movie.genre}, Release Year: ${movie.releaseYear}, Language: ${movie.language}');
  }

  return movies;
}

class FilteredMoviesScreen extends StatelessWidget {
  final List<Movie> movies;

  FilteredMoviesScreen({required this.movies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Movies'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: movies.isEmpty
            ? Center(child: Text('No movies found'))
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.7,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _buildMovieCard(context, movie);
          },
        ),
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(
              title: movie.title,
              posterUrl: movie.posterUrl,
              releaseDate: movie.releaseDate,
              overview: movie.overview,
              rating: movie.rating,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: movie.posterUrl != null && movie.posterUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: movie.posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(
                  color: Colors.black,
                  child: Center(
                    child: Icon(Icons.error, color: Colors.white),
                  ),
                ),
              )
                  : Container(
                color: Colors.black,
                child: Center(
                  child: Icon(Icons.movie, size: 50, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                movie.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




