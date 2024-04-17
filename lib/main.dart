import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var liked = <WordPair>{};

  void nextIdea() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleLike() {
    if (liked.contains(current)) {
      liked.remove(current);
    } else {
      liked.add(current);
    }
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepOrange,
                  background: Color.fromARGB(255, 213, 228, 236))),
          title: 'Startup Name Generator',
          home: MyHomePage(),
        ));
  }
}

// class MyAppState extends ChangeNotifier {
//   var current = WordPair.random();
// }

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var wordPair = appState.current;

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (index) {
                print('Selected index: $index');
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              child: MainPage(wordPair: wordPair, appState: appState),
            ),
          )
        ],
      )
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({
    super.key,
    required this.wordPair,
    required this.appState,
  });

  final WordPair wordPair;
  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(wordPair: wordPair),
          SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: (){
                  appState.toggleLike();
                },
                icon: Icon(Icons.favorite),
                label: Text('Like'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  appState.nextIdea();
                  // showDialog(
                  //     context: context,
                  //     builder: (context) => AlertDialog(
                  //           title: Text('New Idea'),
                  //           content:
                  //               Chip(label: Text(appState.current.asLowerCase)),
                  //           actions: [
                  //             FilledButton(
                  //                 onPressed: () {
                  //                   Navigator.of(context).pop();
                  //                 },
                  //                 child: Text('OK'))
                  //           ],
                  //         ));
                },
                child: Text('Next Idea'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.wordPair,
  });

  final WordPair wordPair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      );


    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
            wordPair.asLowerCase,
            style: style,
            semanticsLabel: "${wordPair.first} ${wordPair.second}",
          ),
      ),
    );
  }
}
