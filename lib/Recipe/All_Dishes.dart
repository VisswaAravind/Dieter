import 'package:flutter/material.dart';
import 'package:dieter/fapi/constant_function.dart';

import '../fapi/cont_fun.dart';
import '../fapi/recipe_fun.dart';

class AllDishes extends StatefulWidget {
  const AllDishes({super.key});

  @override
  State<AllDishes> createState() => _AllDishesState();
}

class _AllDishesState extends State<AllDishes> {
  late Future<List<Map<String, dynamic>>> recipeFuture;
  TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Sort'; // Default filter

  @override
  void initState() {
    super.initState();
    recipeFuture = RecipeFunction.getRespon(
        "Dosa", _selectedFilter); // Default search term and filter
  }

  void _searchRecipes(String query) {
    setState(() {
      recipeFuture = RecipeFunction.getRespon(query, _selectedFilter);
    });
  }

  void _onFilterChanged(String? newFilter) {
    setState(() {
      _selectedFilter = newFilter!;
      _searchRecipes(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DC78),
      appBar: AppBar(
        backgroundColor: Colors.white60,
        title: Text('Recipe Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search for recipes',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          _searchRecipes(_searchController.text);
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: <String>[
                    'Sort',
                    'Vegetarian',
                    'Gluten-Free',
                    'Vegan',
                    'Low Carb',
                    'Egg-Free',
                    'Fish-Free'
                        'Soy-Free',
                    'Sesame-Free',
                    'Red-Meat-Free',
                    'Pork-Free',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: _onFilterChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: recipeFuture,
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
                  return Center(child: Text('No recipes found'));
                } else {
                  var recipes = snapshot.data!;
                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      var recipe = recipes[index];
                      return Card(
                        elevation: 20.0,
                        color: Colors.white60,
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              recipe['image'] != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 2.0),
                                        borderRadius: BorderRadius.circular(
                                            5.0), // Adjust the radius as needed
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            3.0), // Adjust the radius as needed
                                        child: Image.network(
                                          recipe['image'],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Text(
                                recipe['label'] ?? 'No Title',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              // SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        showDialog<void>(
                                          context: context,
                                          builder:
                                              (BuildContext dialogContext) {
                                            return AlertDialog(
                                              title:
                                                  Text('Cooking Instructions '),
                                              content: Text(
                                                (recipe['ingredientLines']
                                                        as List<dynamic>)
                                                    .join(', \n'),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: Image.asset(
                                        'assets/images/img_10.png',
                                        width: 50,
                                        height: 50,
                                      )),
                                  IconButton(
                                    onPressed: () {
                                      showDialog<void>(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return AlertDialog(
                                            title: Text('Nutrients'),
                                            content: Text(
                                              _buildNutrientInfo(recipe),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: Image.asset(
                                      'assets/images/Nutrients_veg.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  // Padding(padding: Edg),
                                ],
                              ),
                            ],
                          ),
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

  String _buildNutrientInfo(Map<String, dynamic> recipe) {
    String protein =
        _formatNutrientValue(recipe['totalNutrients']['PROCNT']['quantity']);
    String carbs =
        _formatNutrientValue(recipe['totalNutrients']['CHOCDF']['quantity']);
    String fat =
        _formatNutrientValue(recipe['totalNutrients']['FAT']['quantity']);
    String kcal = _formatNutrientValue(
        recipe['totalNutrients']['ENERC_KCAL']['quantity']);

    return 'Protein: $protein g\nCarbs: $carbs g\nFat: $fat g\nCalories: $kcal g';
  }

  String _formatNutrientValue(dynamic value) {
    return value != null
        ? value.toStringAsFixed(2)
        : 'N/A'; // Format the value to two decimal places
  }
}
