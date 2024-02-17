import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MovieListProvider extends ChangeNotifier {
  Map<String, dynamic> _movieList = {};
  Map<String, dynamic> get movieList => _movieList;

  final List<dynamic> _movieInfo = [];
  List<dynamic> get movieInfo => _movieInfo;

  Future<void> returnList(String utitle) async {
    const url = "https://movies-tv-shows-database.p.rapidapi.com/";
    final uri = Uri.parse(url).replace(queryParameters: {'title': utitle});
      final response = await http.get(
        uri,
        headers: {
          'Type': "get-movies-by-title",
          'X-RapidAPI-Key': "7348186918msh1cda5a1d7db9120p1cf437jsnbf5f8be1f333",
          'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
        }
      );
      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isNotEmpty) {
          _movieList = jsonDecode(body);
          print(_movieList);
          notifyListeners();
        }
      }
  }

  void toggleBookmark(int index){
    _movieList[index]['favorite'] = !_movieList[index]['favorite'];
    notifyListeners();
  }

  Future<void> MovieImageURLProvider() async {
    Map<String, dynamic> InfoList = {};
    for (var movie in _movieList['movie_results']){
      final imdbId = movie['imdb_id'];
      const url = "https://movies-tv-shows-database.p.rapidapi.com/";
      final uri = Uri.parse(url).replace(queryParameters: {'movieid': imdbId});
      final response = await http.get(
        uri,
        headers: {
          'Type': "get-movies-images-by-imdb",
          'X-RapidAPI-Key': "7348186918msh1cda5a1d7db9120p1cf437jsnbf5f8be1f333",
          'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
        }
      );
        if (response.statusCode == 200) {
          final body = response.body;
          if (body.isNotEmpty) {
            InfoList = jsonDecode(body);
            notifyListeners();
          }
        }
      _movieInfo.add(InfoList['poster']);
    }
    print(_movieInfo);
    notifyListeners();
  }
}

class MovieInformationProvider extends ChangeNotifier{
  
  Map<String, dynamic> _movieDets = {};
  Map<String, dynamic> get movieDets => _movieDets;
  
  Future<void> movieDetails(String? movieID) async {
    const url = "https://movies-tv-shows-database.p.rapidapi.com/";
    final uri = Uri.parse(url).replace(queryParameters: {'title': movieID});
    final response =  await http.get(
      uri,
      headers: {
        'Type': "get-movies-by-title",
        'X-RapidAPI-Key': "7348186918msh1cda5a1d7db9120p1cf437jsnbf5f8be1f333",
        'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
      }
      );
      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isNotEmpty) {
          _movieDets = jsonDecode(body);
          print(_movieDets);
          notifyListeners();
        }
      }
  }
}

// class ToggleFavButtonProvider extends ChangeNotifier {
//   bool _bookmarkState = false;
//   bool get bookmarkState => _bookmarkState;
//   void toggleBookmark(){
//     _bookmarkState = !_bookmarkState;
//     notifyListeners();
//   }
// }
