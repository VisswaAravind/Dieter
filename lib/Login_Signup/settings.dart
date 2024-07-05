import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../Custom_Food_Entry/Custom_Entry_Results.dart';
import '../Tracking/Bmi_records.dart';
import '../fapi/nutrient_data.dart';
import 'Personal_data.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DC78),
      appBar: AppBar(
        backgroundColor: Color(0xFFB9DC78),
        title: Text(
          'Settings Page',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.food_bank_outlined),
              title: const Text(
                'Logged meal datas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.delete_forever),
              onTap: () {
                Get.to(SavedDataPage());
              },
            ),
            Divider(
              height: 10,
              color: Colors.black,
            ),
            ListTile(
              leading: Icon(Icons.emoji_food_beverage_outlined),
              title: const Text(
                'Custom meal datas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.delete_forever),
              onTap: () {
                Get.to(CustomDataPage());
              },
            ),
            Divider(
              height: 10,
              color: Colors.black,
            ),
            ListTile(
              leading: Icon(Icons.directions_bike_rounded),
              title: const Text(
                'Bmi & Waist,hip ratio datas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.delete_forever),
              onTap: () {
                Get.to(BmiRecordsPage());
              },
            ),
            Divider(
              height: 10,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }
}
