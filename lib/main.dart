import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  void toggleLike([int index = -1]) {
    if (index >= 0) {
      liked.remove(liked.elementAt(index));
    } else {
      if (liked.contains(current)) {
        liked.remove(current);
      } else {
        liked.add(current);
      }
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
                background: Colors.grey[300]!,
              )),
          title: 'Startup Name Generator',
          home: MyHomePage(),
        ));
  }
}

// class MyAppState extends ChangeNotifier {
//   var current = WordPair.random();
// }

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget page;

    if (selectedIndex == 0) {
      page = MainPage();
    } else if (selectedIndex == 1) {
      page = FavoritesPage();
    } else {
      throw UnimplementedError("Page $selectedIndex is not implemented");
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(microseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Column(
            children: [
              Expanded(child: mainArea),
              SafeArea(
                child: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Favorites',
                    ),
                  ],
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
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
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              ),
              Expanded(child: mainArea)
            ],
          );
        }
      })
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MyAppState appState = context.watch<MyAppState>();
    final WordPair wordPair = appState.current;

    IconData icon = appState.liked.contains(wordPair)
        ? Icons.favorite
        : Icons.favorite_border;

    return Center(
      child: Column(
        children: [
          SizedBox(height: 32),
          BigCard(wordPair: wordPair),
          SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleLike();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  appState.nextIdea();
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

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MyAppState appState = context.watch<MyAppState>();
    final List<WordPair> liked = appState.liked.toList();
    final theme = Theme.of(context);

    if (liked.isEmpty) {
      return Center(
        child: Text(
          'You have not liked any names yet',
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    return Column(
      children: [
      Padding(
        padding: const EdgeInsets.all(30),
        child: Text('You have ${appState.liked.length} favorites:'),
      ),
      Expanded(
        child: GridView(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            childAspectRatio: 400/80,
        
          ),
          children: [
          for (var wordPair in liked)
            ListTile(
              title: Text(
                wordPair.asPascalCase,
                ),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error,),
                onPressed: () {
                  appState.toggleLike(liked.indexOf(wordPair));
                },
              ),
            ),
          ]
        ),
      ),
      ]
    );
  }
}
