import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth.dart';
import 'package:intl/intl.dart';
import 'Piechart_Data.dart'; // Import your PiechartData widget file

class NutrientTracking extends StatelessWidget {
  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DC78),
      appBar: AppBar(
        backgroundColor: Colors.white60,
        title: Text('Nutrients Data'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Personals')
            .doc(Auth().currentUser?.uid)
            .collection('Mealtracker')
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
            return Center(child: Text('No saved data found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final document = snapshot.data!.docs[index];
                final data = document.data() as Map<String, dynamic>;
                final timestamp = data['timestamp'] as Timestamp?;
                final formattedTimestamp =
                    timestamp != null ? _formatTimestamp(timestamp) : 'No date';

                // Convert string values to double
                final calories =
                    double.tryParse(data['calories'].toString()) ?? 0;
                final protein =
                    double.tryParse(data['protein'].toString()) ?? 0;
                final fat = double.tryParse(data['fat'].toString()) ?? 0;
                final carbs = double.tryParse(data['carbs'].toString()) ?? 0;
                final fiber = double.tryParse(data['fiber'].toString()) ?? 0;
                final sugar = double.tryParse(data['sugar'].toString()) ?? 0;
                final sodium = double.tryParse(data['sodium'].toString()) ?? 0;

                return Card(
                  elevation: 20,
                  color: Colors.white60,
                  child: ListTile(
                    title: Text(
                      data['recipeName'] ?? 'Unknown Recipe',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: $formattedTimestamp'),
                        SizedBox(height: 8), // Add spacing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PiechartData(
                                      caloriesValue: calories,
                                      proteinValue: protein,
                                      fatValue: fat,
                                      carbsValue: carbs,
                                      fiberValue: fiber,
                                      sugarValue: sugar,
                                      sodiumValue: sodium,
                                    ),
                                  ),
                                );
                              },
                              child: Text('View Chart'),
                            ),
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
    );
  }
}
