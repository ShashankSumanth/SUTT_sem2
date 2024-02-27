import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MovieListProvider extends ChangeNotifier {
  Map<String, dynamic> _movieList = {};
  Map<String, dynamic> get movieList => _movieList;

  List<dynamic> _movieInfo = [];
  List<dynamic> get movieInfo => _movieInfo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<int> returnList(String utitle) async {
    if (utitle == " "){
      const url = "https://movies-tv-shows-database.p.rapidapi.com/";
      final uri = Uri.parse(url).replace(queryParameters: {'page': '1'});
        final response = await http.get(
          uri,
          headers: {
            'Type': "get-nowplaying-movies",
            'X-RapidAPI-Key': "468ea9dcc0msh13ec1d1d0a74434p180135jsn06e756bcb814",
            'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
          }
        );
        if (response.statusCode == 200) {
          final body = response.body;
          if (body.isNotEmpty) {
            _movieList = jsonDecode(body);
            for (int counter = 0; counter<_movieList['results'];counter++){
              _movieList['movie_results'][counter]['favorite'] = false;
            }
            _isLoading = false;
            notifyListeners();
          }
        }
        return 1;
    }
    const url = "https://movies-tv-shows-database.p.rapidapi.com/";
    final uri = Uri.parse(url).replace(queryParameters: {'title': utitle});
      final response = await http.get(
        uri,
        headers: {
          'Type': "get-movies-by-title",
          'X-RapidAPI-Key': "468ea9dcc0msh13ec1d1d0a74434p180135jsn06e756bcb814",
          'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
        }
      );
      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isNotEmpty) {
          _movieList = jsonDecode(body);
          for (int counter = 0; counter<(_movieList['search_results']).toInt();counter++){
            _movieList['movie_results'][counter]['favorite'] = false;
          }
          _isLoading = false;
          notifyListeners();
        }
      }
      return 1;
  }

  void toggleBookmark(int index){
    _movieList['movie_results'][index]['favorite'] = !(_movieList['movie_results'][index]['favorite']);
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
          'X-RapidAPI-Key': "468ea9dcc0msh13ec1d1d0a74434p180135jsn06e756bcb814",
          'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
        }
      );
        if (response.statusCode == 200) {
          final body = response.body;
          if (body.isNotEmpty) {
            InfoList = jsonDecode(body);
          }
        }
      if (InfoList['poster'] != ''){
        _movieInfo.add(InfoList['poster']);
      } else{
        _movieInfo.add('https://media.istockphoto.com/id/1409329028/vector/no-picture-available-placeholder-thumbnail-icon-illustration-design.jpg?s=612x612&w=0&k=20&c=_zOuJu755g2eEUioiOUdz_mHKJQJn-tDgIAhQzyeKUQ=');
      }
    }
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
        'X-RapidAPI-Key': "468ea9dcc0msh13ec1d1d0a74434p180135jsn06e756bcb814",
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
        'X-RapidAPI-Key': "468ea9dcc0msh13ec1d1d0a74434p180135jsn06e756bcb814",
        'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
      }
      );
        if (response.statusCode == 200) {
          final body = response.body;
          if (body.isNotEmpty) {
            InfoList = jsonDecode(body);
          }
        }
    _fanArtURL = (InfoList['fanart']).split(',');
    notifyListeners();
    return 1;
  }
}
