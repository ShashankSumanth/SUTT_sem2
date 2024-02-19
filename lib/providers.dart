import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MovieListProvider extends ChangeNotifier {
  Map<String, dynamic> _movieList = {};
  Map<String, dynamic> get movieList => _movieList;

  List<dynamic> _movieInfo = [];
  List<dynamic> get movieInfo => _movieInfo;

  Future<int> returnList(String utitle) async {
    const url = "https://movies-tv-shows-database.p.rapidapi.com/";
    final uri = Uri.parse(url).replace(queryParameters: {'title': utitle});
      final response = await http.get(
        uri,
        headers: {
          'Type': "get-movies-by-title",
          'X-RapidAPI-Key': "f939b86969msh02e0ea20f27cabdp111b43jsn04fb778de5d2",
          'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
        }
      );
      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isNotEmpty) {
          _movieList = jsonDecode(body);
          print('1.');
          print(_movieList);
          notifyListeners();
        }
      }
      return 1;
  }

  void toggleBookmark(int index){
    _movieList[index]['favorite'] = !(_movieList[index]['favorite'] ?? false);
    notifyListeners();
  }

  Future<int> MovieImageURLProvider() async {
    _movieInfo = [];
    Map<String, dynamic> InfoList = {};
    for (var movie in _movieList['movie_results']){
      final imdbId = movie['imdb_id'];
      const url = "https://movies-tv-shows-database.p.rapidapi.com/";
      final uri = Uri.parse(url).replace(queryParameters: {'movieid': imdbId});
      final response = await http.get(
        uri,
        headers: {
          'Type': "get-movies-images-by-imdb",
          'X-RapidAPI-Key': "f939b86969msh02e0ea20f27cabdp111b43jsn04fb778de5d2",
          'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
        }
      );
        if (response.statusCode == 200) {
          final body = response.body;
          if (body.isNotEmpty) {
            InfoList = jsonDecode(body);
          }
        }
      _movieInfo.add(InfoList['poster']);
    }
    print('2.');
    print(_movieInfo);
    notifyListeners();
    return 1;
  }
}

class MovieInformationProvider extends ChangeNotifier{
  
  Map<String, dynamic> _movieDets = {};
  Map<String, dynamic> get movieDets => _movieDets;

  List<String> _fanArtURL = [];
  List<String> get fanArtURL => _fanArtURL;
  
  Future<int> movieDetails(String? movieID) async {
    const url = "https://movies-tv-shows-database.p.rapidapi.com/";
    final uri = Uri.parse(url).replace(queryParameters: {'movieid': movieID});
    final response =  await http.get(
      uri,
      headers: {
        'Type': "get-movie-details",
        'X-RapidAPI-Key': "f939b86969msh02e0ea20f27cabdp111b43jsn04fb778de5d2",
        'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
      }
      );
      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isNotEmpty) {
          _movieDets = jsonDecode(body);
          notifyListeners();
          return 1;
        }
      }
      return 1;
  }

  Future<int> movieImageURLProvider(String? movieID) async {
    _fanArtURL = [];
    Map<String, dynamic> InfoList = {};
    const url = "https://movies-tv-shows-database.p.rapidapi.com/";
    final uri = Uri.parse(url).replace(queryParameters: {'movieid': movieID});
    final response = await http.get(
      uri,
      headers: {
        'Type': "get-movies-images-by-imdb",
        'X-RapidAPI-Key': "f939b86969msh02e0ea20f27cabdp111b43jsn04fb778de5d2",
        'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
      }
      );
        if (response.statusCode == 200) {
          final body = response.body;
          if (body.isNotEmpty) {
            InfoList = jsonDecode(body);
          }
        }
    _fanArtURL = (InfoList['fanart']);
    print(_fanArtURL);
    notifyListeners();
    return 1;
  }
}
