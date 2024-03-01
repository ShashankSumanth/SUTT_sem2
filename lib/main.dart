import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sutt_task_final/riverpods.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const SplashScreen()
          ),
        GoRoute(
          path: "/signin",
          builder: (context, state) => const GoogleSignIn()
          ),
        GoRoute(
          path: "/signin/home/:username",
          builder: (context, state) {
            final username = state.pathParameters['username'];
            return HomePage(username: username ?? "");
          }
          ),
        GoRoute(
          path: "/signin/home/details/:movieID",
          builder: (context, state) {
            final movieID = state.pathParameters['movieID'];
            return DetailsScreen(
              movieID: movieID ?? "",
            );
          }
          )
      ]
      );
    return MaterialApp.router(
      title: 'Flutter Demo',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { 
    super.initState(); 
    Future.delayed(const Duration(seconds: 3), (){
      GoRouter.of(context).go('/signin');
    } 
    );
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF04073E),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Image(image: AssetImage('assets/glasses.jpg'), 
              height: 150,),
              Column(
                children: [
                  Image(image: AssetImage('assets/popcorn.jpg'),
                  height: 550,),
                  Text("MOVIE APP", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


class GoogleSignIn extends ConsumerStatefulWidget{
  const GoogleSignIn({super.key});
  @override
  ConsumerState<GoogleSignIn> createState() => _GoogleSignIn();
}

class _GoogleSignIn extends ConsumerState<GoogleSignIn> {

  @override
  Widget build(BuildContext){
    final userInformation = ref.watch(userProvider);
    print (userInformation);
    return Scaffold(
      backgroundColor: const Color(0xFF04073E),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFF04073E),
        title: const Image(image: AssetImage('assets/glasses.jpg')),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 100
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: const Size(200,50)
              ),
              onPressed: () async {
                return userInformation.when(
                  data: (userInformation) => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text("Welcome " + userInformation),
                      content: TextButton(
                        onPressed: () => (context).go('/signin/home/$userInformation'),
                        child: const Text('Continue')
                      ),
                    )
                    ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (err, stack) => Text('Error: $err')
                  );
              }, 
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image(image: AssetImage('assets/GoogleImage.png'),
                  height: 30, 
                  ),
                  Text('Sign in with Google'),
                ],
              ))
          ]
        ),
      )
    );
  }
}


class HomePage extends ConsumerStatefulWidget {
  final String username;
  HomePage({super.key, required this.username});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

  late String utitle;
  late TextEditingController myController;

  @override
  void initState() {
    super.initState();
    utitle = "";
    myController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    String? username = widget.username;
    var movieList = ref.watch(movieListProvider(utitle));
    
    final myController = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xFF04073E),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFF04073E),
        title: const Image(image: AssetImage('assets/glasses.jpg')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Welcome $username", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Search Movies",
                  suffixIcon: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFBE28),
                      ),
                    child: IconButton(
                      onPressed:() async {
                        setState(() {
                          utitle = myController.text;
                        });
                        await ref.read(movieListProvider(myController.text)).maybeWhen(
                          data: (_) => ref.refresh(movieListProvider(utitle)),
                          orElse: () {}
                        );
                      }, 
                      icon: const Icon(Icons.search, color: Colors.black),
                      ),
                  )
                ),
                controller: myController,
              ),
            ),
            movieList.when(
              loading:() => const Center(
                child: CircularProgressIndicator(),
              ),
              data: (movieList) => SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child:  GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 450,
                    ), 
                  itemCount: movieList['movie_results']?.length ?? 0,
                  itemBuilder: (context, index){
                    List<dynamic> moviesResults = movieList['movie_results'];
                    String movieTitle = moviesResults[index]['title'];
                    String movieImgURL = moviesResults[index]['poster'];
                    String movieID = moviesResults[index]['imdb_id'];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 2
                          )
                        ),
                        child: Column(
                          children: <Widget>[
                            Image.network(movieImgURL),
                            Text(movieTitle),
                            IconButton(
                              onPressed: (){
                                var isFav = ref.watch(favoriteProvider);
                                ref.read(favoriteProvider.notifier).state = !ref.read(favoriteProvider.notifier).state;
                                moviesResults[index]['favorite'] = isFav;
                              },
                              icon: moviesResults[index]['favorite']
                                  ? const Icon(Icons.favorite) : 
                                  const Icon(Icons.favorite_border_outlined)
                            ),
                            Center(
                              child: TextButton(
                                onPressed: ()=>context.go('/signin/home/details/$movieID'), 
                                child: const Row(
                                  children: <Widget>[
                                    Text('See More'),
                                    Icon(Icons.arrow_forward)
                                  ],
                                )
                                ),
                            )
                          ],
                        )
                        ),
                    );
                  },
                  )
              ),
              error: (err, stack) => Text('Error: $err')
            ),
          ],
        ),
      ),
    );
  }
}


class DetailsScreen extends ConsumerStatefulWidget {
  final String movieID;
  const DetailsScreen({Key? key, required this.movieID});
  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {

  @override
  Widget build(BuildContext context) {
    final movieDetails = ref.watch(movieDetailsProvider(widget.movieID));
    return Scaffold(
      backgroundColor: const Color(0xFF04073E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04073E),
        title: const Image(image: AssetImage('assets/glasses.jpg')),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: ()=>context.go('/signin/home/ '),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black
              )
            ),
            child: movieDetails.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              data: (movieDetails) => Column(
                      children: <Widget>[
                        CarouselSlider.builder(
                          itemCount: movieDetails['fanart'].length, 
                          itemBuilder: (BuildContext context, int index, int realIndex) {
                            if (movieDetails['fanart'] == ""){
                              movieDetails['fanart'] = "https://media.istockphoto.com/id/1409329028/vector/no-picture-available-placeholder-thumbnail-icon-illustration-design.jpg?s=612x612&w=0&k=20&c=_zOuJu755g2eEUioiOUdz_mHKJQJn-tDgIAhQzyeKUQ=";
                            }
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: const BoxDecoration(color: Colors.white),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network(movieDetails['fanart'][index]),
                                  ),
                                ],
                              ),
                            );
                          }, 
                          options: CarouselOptions(
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 4),
                          )
                          ),
                        Text(movieDetails['title'] ?? 'No title available', style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),),
                        Text(movieDetails['year'] ?? 'No year available', style: const TextStyle(
                          fontWeight: FontWeight.bold
                        ),),
                        const SizedBox(height: 10,),
                        Text(movieDetails['tagline'] ?? 'No tagline available'),
                        const SizedBox(height: 10,),
                        RatingBar.builder(
                          initialRating: ((double.parse(movieDetails['imdb_rating'] ?? 0))/2),
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(Icons.star,color: Colors.amber,),
                          onRatingUpdate: (rating) {},
                        ),
                        const SizedBox(height: 10,),
                        ExpansionTile(
                          title: const Text("Description", style: TextStyle(
                            fontWeight: FontWeight.w500
                          ),
                          ),
                          children: <Widget>[
                            Text(movieDetails['description']?? 'None')
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text('Age Rating: ', style: TextStyle(fontWeight: FontWeight.w500),),
                            Text(movieDetails['rated']),
                          ],
                        ),
                        TextButton(
                          onPressed:  () async {
                            String youtubeTrailerKey = movieDetails['youtube_trailer_key'];
                            Uri url = Uri.parse("https://www.youtube.com/watch?v=$youtubeTrailerKey");
                            if (await canLaunchUrl(url)) {
                              print('here');
                              await launchUrl(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          }, 
                          child: const Text('Watch the trailer'))
                      ],
                    ),
              error: (err, stack) => Text('Error: $err')
            )
          ),
        ),
      ),
    );
  }
}
