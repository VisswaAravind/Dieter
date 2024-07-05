import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth.dart';

class BmiRecordsPage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI & Waist-Hip Ratio Records'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Personals')
            .doc(user?.uid)
            .collection('Tracker')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Image.asset(
              'assets/gif/food_indicator.gif',
              height: 100,
              width: 100,
            ));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No records found.'));
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index].data() as Map<String, dynamic>;

              print('Raw record: $record');

              // Check if 'timestamp' field exists and has a valid value
              final timestamp = record.containsKey('timestamp') &&
                      record['timestamp'] != null &&
                      record['timestamp'] is Timestamp
                  ? (record['timestamp'] as Timestamp).toDate().toString()
                  : 'N/A';

              print('Processed timestamp: $timestamp');

              final bmi = record.containsKey('bmi')
                  ? record['bmi'].toStringAsFixed(2)
                  : 'N/A';
              final waistHipRatio = record.containsKey('waistHipRatio')
                  ? record['waistHipRatio'].toStringAsFixed(2)
                  : 'N/A';
              final weight = record.containsKey('weight')
                  ? record['weight'].toString()
                  : 'N/A';
              final height = record.containsKey('height')
                  ? record['height'].toString()
                  : 'N/A';
              final waist = record.containsKey('waist')
                  ? record['waist'].toString()
                  : 'N/A';
              final hip =
                  record.containsKey('hip') ? record['hip'].toString() : 'N/A';

              return Card(
                elevation: 30,
                child: ListTile(
                  title: Text('Recorded on: \n$timestamp'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BMI: $bmi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Weight: $weight kg'),
                      Text('Height: $height cm'),
                      Text(
                        'Waist-Hip Ratio: $waistHipRatio',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Waist: $waist cm'),
                      Text('Hip: $hip cm'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: Text('Delete Record'),
                            content: Text('Are You Sure ????'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('Personals')
                                        .doc(Auth().currentUser?.uid)
                                        .collection('Tracker')
                                        .doc(records[index].id)
                                        .delete();
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: Text('Yes'))
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
