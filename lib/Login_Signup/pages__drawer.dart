import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dieter/Custom_Food_Entry/Custom_Entry.dart';
import 'package:dieter/Login_Signup/Personal_data.dart';
import 'package:dieter/Login_Signup/settings.dart';
import 'package:dieter/Progress/Nutrient_Tracking.dart';
import 'package:dieter/Recipe/All_Dishes.dart';
import 'package:dieter/Tracking/Exercises.dart';
import 'package:dieter/Tracking/bmi_track.dart';
import 'package:dieter/fapi/food_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../Custom_Food_Entry/Custom_data.dart';
import '../Progress/progress_frontpage.dart';

class Pages_Drawer extends StatelessWidget {
  final User? user;
  final Future<void> Function() onSignOut;

  const Pages_Drawer({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  Future<String> _fetchUserName() async {
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('Personals')
          .doc(user!.uid)
          .get();
      return doc.data()?['name'] ?? 'User Name';
    }
    return 'User Name';
  }

  @override
  Widget build(BuildContext context) {
    return /*GetMaterialApp(
      home:*/
        Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      elevation: 5.0,
      child: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<String>(
              future: _fetchUserName(),
              builder: (context, snapshot) {
                String userName = snapshot.data ?? 'Loading...';

                return UserAccountsDrawerHeader(
                  accountName: Text(
                    userName,
                    style: TextStyle(color: Colors.black),
                  ),
                  accountEmail: Text(
                    user?.email ?? 'User email',
                    style: TextStyle(color: Colors.black),
                  ),
                  currentAccountPicture: CircleAvatar(
                    child: Text(
                      user?.email?.substring(0, 1) ?? '',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFB9DC78),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Profile Setup'),
              onTap: () {
                Get.to(PersonalData());
              },
            ),
            //    Divider(height: 0.5),
            ListTile(
              leading: Icon(Icons.directions_bike_rounded),
              title: Text('BMI and Suggestions'),
              onTap: () {
                Get.to(BmiTracking());
              },
            ),
            // Divider(height: 0.5),
            ListTile(
              leading: Icon(Icons.food_bank_outlined),
              title: Text('Meal Logging'),
              onTap: () {
                Get.to(FoodView());
              },
            ),
            //  Divider(height: 0.5),
            ListTile(
              leading: Icon(Icons.fastfood_outlined),
              title: Text('Custom Meals'),
              onTap: () {
                Get.to(CustomData());
              },
            ),
            //  Divider(height: 0.5),
            ListTile(
              leading: Icon(Icons.track_changes_rounded),
              title: Text('Nutrient Tracking'),
              onTap: () {
                Get.to(NutrientTracking());
              },
            ),
            //  Divider(height: 0.5),
            ListTile(
              leading: Icon(Icons.emoji_food_beverage_outlined),
              title: Text('Custom Food Entry'),
              onTap: () {
                Get.to(CustomEntry());
              },
            ),
            //    Divider(height: 0.5),
            ListTile(
              leading: Icon(Icons.auto_graph),
              title: Text('Progress'),
              onTap: () {
                Get.to(ProgressFrontpage());
              },
            ),
            //  Divider(height: 0.5),
            ListTile(
              leading: Icon(Icons.cookie_outlined),
              title: Text('Food Recipes'),
              onTap: () {
                Get.to(AllDishes());
              },
            ),
            //   Divider(height: 0.5),
            ListTile(
              leading: Icon(Icons.run_circle_outlined),
              title: Text('Workout'),
              onTap: () {
                Get.to(Exercises());
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Get.to(SettingsPage());
              },
            ),
            SizedBox(
              height: 20,
            ),
            /*IconButton(
              onPressed: onSignOut,
              icon: Icon(
                Icons.power_settings_new_outlined,
                color: Colors.red,
              ),
            ),*/
          ],
        ),
      ),
      // ),
    );
  }
}
