import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


final userProvider = FutureProvider<String>((ref) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  UserCredential userCreds;
  String? username;
  try {
    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
    if (googleSignInAccount == null) return "NA";
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    final OAuthCredential googleCredential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    userCreds = await _auth.signInWithCredential(googleCredential);
    username = userCreds.user?.displayName;
    return username.toString();
  } catch (e) {
    print("Error signing in with Google: $e");
    return e.toString();
  }
}
);


final movieListProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, String utitle) async {
  Map<String, dynamic> movieList = {};
  Map<String, dynamic> ImageList = {};

  if (utitle == ""){
    print('1.');
    const url = "https://movies-tv-shows-database.p.rapidapi.com/";
    final uri = Uri.parse(url).replace(queryParameters: {'page': '1'});
    final response = await http.get(
      uri,
      headers: {
        'Type': "get-nowplaying-movies",
        'X-RapidAPI-Key': "574e021e0amsh775fac3b27f6bd9p1bc7edjsn0eb0dc3cc467",
        'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
      }
      );
      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isNotEmpty) {
          movieList = jsonDecode(body);
        }
      }
    print(movieList);
  }else{
    print('2');
    const url = "https://movies-tv-shows-database.p.rapidapi.com/";
    final uri = Uri.parse(url).replace(queryParameters: {'title': utitle});
    final response = await http.get(
      uri,
      headers: {
        'Type': "get-movies-by-title",
        'X-RapidAPI-Key': "574e021e0amsh775fac3b27f6bd9p1bc7edjsn0eb0dc3cc467",
        'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
        }
      );
      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isNotEmpty) {
          movieList = jsonDecode(body);
        }
      }
      print(movieList);
  };
  for (int counter = 0; counter<(movieList['movie_results']).length; counter++){
    movieList['movie_results'][counter]['favorite'] = false;
    String imdbID = movieList['movie_results'][counter]['imdb_id'];
    const url = "https://movies-tv-shows-database.p.rapidapi.com/";
    final uri = Uri.parse(url).replace(queryParameters: {'movieid': imdbID});
    final response = await http.get(
      uri,
      headers: {
        'Type': "get-movies-images-by-imdb",
        'X-RapidAPI-Key': "574e021e0amsh775fac3b27f6bd9p1bc7edjsn0eb0dc3cc467",
        'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
      }
    );
    if (response.statusCode == 200) {
      final body = response.body;
      if (body.isNotEmpty) {
        ImageList = jsonDecode(body);
      }
    }
    if (ImageList['poster'] != ""){
      movieList['movie_results'][counter]['poster'] = ImageList['poster'];
    } else {
      movieList['movie_results'][counter]['poster'] = 'https://media.istockphoto.com/id/1409329028/vector/no-picture-available-placeholder-thumbnail-icon-illustration-design.jpg?s=612x612&w=0&k=20&c=_zOuJu755g2eEUioiOUdz_mHKJQJn-tDgIAhQzyeKUQ=';
    }
  }
  print(movieList);
  return movieList;
});

final favoriteProvider = StateProvider<bool>((_) => true);

final movieDetailsProvider = FutureProvider.family<Map<String, dynamic>, String?>((ref, String? movieID) async{
  print('3.');
  Map<String, dynamic> movieDets = {};
  Map<String, dynamic> InfoList = {};
  List<String> fanArtURL = [];
  const url1 = "https://movies-tv-shows-database.p.rapidapi.com/";
  final uri1 = Uri.parse(url1).replace(queryParameters: {'movieid': movieID});
  final response1 =  await http.get(
    uri1,
    headers: {
      'Type': "get-movie-details",
      'X-RapidAPI-Key': "574e021e0amsh775fac3b27f6bd9p1bc7edjsn0eb0dc3cc467",
      'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
    }
  );
  if (response1.statusCode == 200) {
    final body1 = response1.body;
    if (body1.isNotEmpty) {
      movieDets = jsonDecode(body1);
    }
  }

  const url2 = "https://movies-tv-shows-database.p.rapidapi.com/";
  final uri2 = Uri.parse(url2).replace(queryParameters: {'movieid': movieID});
  final response2 = await http.get(
    uri2,
    headers: {
      'Type': "get-movies-images-by-imdb",
      'X-RapidAPI-Key': "574e021e0amsh775fac3b27f6bd9p1bc7edjsn0eb0dc3cc467",
      'X-RapidAPI-Host': "movies-tv-shows-database.p.rapidapi.com"
    }
    );
    if (response2.statusCode == 200) {
      final body = response2.body;
      if (body.isNotEmpty) {
        InfoList = jsonDecode(body);
      }
    }
  print(InfoList);
  fanArtURL = (InfoList['fanart']).split(',');
  if (fanArtURL == ""){
    movieDets['fanart'] = "https://media.istockphoto.com/id/1409329028/vector/no-picture-available-placeholder-thumbnail-icon-illustration-design.jpg?s=612x612&w=0&k=20&c=_zOuJu755g2eEUioiOUdz_mHKJQJn-tDgIAhQzyeKUQ=";
  } else {
    movieDets['fanart'] = fanArtURL;
  }
  print(movieDets);
  return movieDets;
});
