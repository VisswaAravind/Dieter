import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth.dart';
import 'package:intl/intl.dart'; // For formatting the timestamp

class CustomData extends StatelessWidget {
  final Map<int, TextEditingController> _weightControllers = {};

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd – kk:mm')
        .format(dateTime); // Format the date and time
  }

  Future<void> _calculateNutrition(
      Map<String, dynamic> data, int index, BuildContext context) async {
    final enteredWeight =
        double.tryParse(_weightControllers[index]?.text ?? '0');
    if (enteredWeight != null && enteredWeight > 0) {
      final originalWeight =
          double.tryParse(data['weight']?.toString() ?? '0') ?? 0;
      final calories =
          ((double.tryParse(data['calories']?.toString() ?? '0') ?? 0) /
                  originalWeight) *
              enteredWeight;
      final protein =
          ((double.tryParse(data['protein']?.toString() ?? '0') ?? 0) /
                  originalWeight) *
              enteredWeight;
      final fat = ((double.tryParse(data['fat']?.toString() ?? '0') ?? 0) /
              originalWeight) *
          enteredWeight;
      final carbs = ((double.tryParse(data['carbs']?.toString() ?? '0') ?? 0) /
              originalWeight) *
          enteredWeight;
      final fiber = ((double.tryParse(data['fiber']?.toString() ?? '0') ?? 0) /
              originalWeight) *
          enteredWeight;
      final sugar = ((double.tryParse(data['sugar']?.toString() ?? '0') ?? 0) /
              originalWeight) *
          enteredWeight;
      final sodium =
          ((double.tryParse(data['sodium']?.toString() ?? '0') ?? 0) /
                  originalWeight) *
              enteredWeight;

      final user = Auth().currentUser;
      final userUid = user?.uid;
      final userRef =
          FirebaseFirestore.instance.collection('Personals').doc(userUid);
      final mealTrackerRef = userRef.collection('Mealtracker');

      try {
        await mealTrackerRef.add({
          'recipeName': data['Food Name'] ?? 'Unknown Recipe',
          'calories': calories,
          'protein': protein,
          'fat': fat,
          'carbs': carbs,
          'fiber': fiber,
          'sugar': sugar,
          'sodium': sodium,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Calculated Values Saved:\nCalories: ${calories.toStringAsFixed(2)}\nProtein: ${protein.toStringAsFixed(2)} g\nFat: ${fat.toStringAsFixed(2)} g\nCarbs: ${carbs.toStringAsFixed(2)} g\nFiber: ${fiber.toStringAsFixed(2)} g\nSugar: ${sugar.toStringAsFixed(2)} g\nSodium: ${sodium.toStringAsFixed(2)} mg'),
            duration: Duration(seconds: 5),
          ),
        );
      } catch (error) {
        print('Error saving calculated values: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error saving calculated values. Please try again later.'),
            duration: Duration(seconds: 5),
          ),
        );
      }

      final snackBar = SnackBar(
        content: Text(
          'Calculated Values:\n'
          'Calories: ${calories.toStringAsFixed(2)}\n'
          'Protein: ${protein.toStringAsFixed(2)} g\n'
          'Fat: ${fat.toStringAsFixed(2)} g\n'
          'Carbs: ${carbs.toStringAsFixed(2)} g\n'
          'Fiber: ${fiber.toStringAsFixed(2)} g\n'
          'Sugar: ${sugar.toStringAsFixed(2)} g\n'
          'Sodium: ${sodium.toStringAsFixed(2)} mg',
          style: TextStyle(fontSize: 16),
        ),
        duration: Duration(seconds: 5),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = SnackBar(
        content: Text('Please enter a valid weight'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _showNutrientsDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nutritional Information'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _buildNutritionInfo(data),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildNutritionInfo(Map<String, dynamic> data) {
    List<String> nutrients = [
      'calories',
      'protein',
      'fat',
      'carbs',
      'fiber',
      'sugar',
      'sodium'
    ];
    return nutrients.map((nutrient) {
      double? value = double.tryParse(data[nutrient]?.toString() ?? '0') ?? 0.0;
      return Text(
        '${nutrient[0].toUpperCase() + nutrient.substring(1)}: ${value.toStringAsFixed(2)}',
        style: TextStyle(fontSize: 16),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DC78),
      appBar: AppBar(
        backgroundColor: Colors.white60,
        title: Text('Custom Food Entries'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Personals')
            .doc(Auth().currentUser?.uid)
            .collection('CustomFoodEntry')
            .snapshots(),
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
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No custom food entries found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final document = snapshot.data!.docs[index];
                final data = document.data() as Map<String, dynamic>;
                final timestamp = data['timestamp'] as Timestamp?;
                final formattedTimestamp =
                    timestamp != null ? _formatTimestamp(timestamp) : 'No date';

                _weightControllers[index] ??= TextEditingController();

                return Card(
                  elevation: 60,
                  color: Colors.white60,
                  shadowColor: Colors.black,
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        data['image_url'] != null
                            ? Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 2.0),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3.0),
                                  child: Image.network(
                                    data['image_url'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['Food Name'] ?? 'No Title',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller:
                                                  _weightControllers[index],
                                              decoration: InputDecoration(
                                                labelText: 'Enter weight (gm)',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.calculate),
                                            onPressed: () {
                                              _calculateNutrition(
                                                  data, index, context);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              TextButton(
                                onPressed: () {
                                  _showNutrientsDialog(context, data);
                                },
                                child: Text('Show Nutrients'),
                              ),
                            ],
                          ),
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
    );
  }
}
