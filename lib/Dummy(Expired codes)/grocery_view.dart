import 'package:flutter/material.dart';
import 'cont_fun.dart'; // Import the service

/*
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Suggestions',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecipeSuggestionsScreen(),
    );
  }
}
*/

class RecipeSuggestionsScreen extends StatefulWidget {
  @override
  _RecipeSuggestionsScreenState createState() =>
      _RecipeSuggestionsScreenState();
}

class _RecipeSuggestionsScreenState extends State<RecipeSuggestionsScreen> {
  late Future<List<Map<String, dynamic>>> _suggestions;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _suggestions = fetchRecipeSuggestions('chicken'); // Example query
  }

  void _searchRecipes() {
    setState(() {
      _suggestions = fetchRecipeSuggestions(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Suggestions'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for recipes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchRecipes,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _suggestions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: Image.asset(
                    'assets/gif/food_indicator.gif',
                    height: 100,
                    width: 100,
                  ));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No suggestions found'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final suggestion = snapshot.data![index];
                      return ListTile(
                        leading: suggestion['image'] != null
                            ? Image.network(
                                suggestion['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : null,
                        title: Text(suggestion['label'] ?? 'No Title'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calories: ${suggestion['calories']?.toStringAsFixed(2) ?? 'N/A'}',
                            ),
                            Text(
                              'Protein: ${suggestion['protein']?.toStringAsFixed(2) ?? 'N/A'}g',
                            ),
                            Text(
                              'Fat: ${suggestion['fat']?.toStringAsFixed(2) ?? 'N/A'}g',
                            ),
                            Text(
                              'Carbs: ${suggestion['carbs']?.toStringAsFixed(2) ?? 'N/A'}g',
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
