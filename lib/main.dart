import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sutt_sem2_v1/providers.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
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
          path: "/home",
          builder: (context, state) => const HomePage()
          )
      ]
      );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MovieListProvider>(
          create: (context) => MovieListProvider()
          ),
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
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
      GoRouter.of(context).go('/home');
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final movies = Provider.of<MovieListProvider>(context);
    final myController = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xFF04073E),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFF04073E),
        title: const Image(image: AssetImage('assets/glasses.jpg'),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Movie Guide", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
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
                    child: IconButton(onPressed:() async {
                      await movies.returnList(myController.text);
                      await movies.MovieImageURLProvider();
                      }, 
                      icon: const Icon(Icons.search, color: Colors.black, ),
                      ),
                  )
                ),
                controller: myController,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder(
                future: movies.MovieImageURLProvider(),
                builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else{
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 390,
                    ), 
                  itemCount: movies.movieList['movie_results']?.length ?? 0,
                  itemBuilder: (context, index){
                    List<dynamic> moviesResults = movies.movieList['movie_results'];
                    String movieTitle = moviesResults[index]['title'];
                    String movieImgURL = movies.movieInfo[index];
                    final isFavorite = moviesResults[index]['favorite'] ?? false;
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
                                movies.toggleBookmark(index);
                              },
                              icon: isFavorite
                              ? const Icon(Icons.favorite) : 
                              const Icon(Icons.favorite_border_outlined)
                              )
                          ],
                        )
                        ),
                    );
                  },
                  );
                }
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Image(image: AssetImage('assets/glasses.jpg')),
        centerTitle: true,
        
      ),
    );
  }
}