import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dieter/Custom_Food_Entry/Custom_Entry.dart';
import 'package:dieter/Login_Signup/Personal_data.dart';
import 'package:dieter/Login_Signup/home_page_ink_well.dart';
import 'package:dieter/Login_Signup/pages__drawer.dart';
import 'package:dieter/Login_Signup/settings.dart';
import 'package:dieter/Progress/bmi_progress.dart';
import 'package:dieter/Progress/progress_frontpage.dart';
import 'package:dieter/Recipe/All_Dishes.dart';
import 'package:dieter/Tracking/Exercises.dart';
import 'package:dieter/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Custom_Food_Entry/Custom_data.dart';
import '../Progress/Nutrient_Tracking.dart';
import '../Tracking/bmi_track.dart';
import '../fapi/food_view.dart';
import 'login_register_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final User? user = Auth().currentUser;

  Future<void> signOut(BuildContext context) async {
    await Auth().signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

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
    return Scaffold(
      backgroundColor: Color(0xFFB9DC78),
/*      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_circle_right),
            onPressed: () {
              signOut(context);
            },
          ),
        ],
      ),*/
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*Text(user?.email ?? 'User email'),*/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Hii....',
                      style: TextStyle(
                          fontSize: 60,
                          color: Colors.black54,
                          fontFamily: 'ChocoChici-2OMyW'),
                    ),
                  ],
                ),
                FutureBuilder<String>(
                    future: _fetchUserName(),
                    builder: (context, snapshot) {
                      String userName = snapshot.data ?? 'Loading...';

                      return Text(
                        userName,
                        style: const TextStyle(
                            fontSize: 40,
                            color: Colors.black54,
                            fontFamily: 'ChocoChici-2OMyW'),
                      );
                    }),
                Text(
                  'Welcome To',
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontFamily: 'ShadeBlue-2OozX'),
                ),
                Text(
                  'Dieter...',
                  style: TextStyle(
                      fontSize: 65,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontFamily: 'ShadeBlue-2OozX'),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    HomePageInkWell(
                      icons: Icons.person_2_outlined,
                      screen: PersonalData(),
                    ),
                    SizedBox(width: 20),
                    HomePageInkWell(
                      icons: Icons.directions_bike_rounded,
                      screen: BmiTracking(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    HomePageInkWell(
                      icons: Icons.food_bank_outlined,
                      screen: FoodView(),
                    ),
                    SizedBox(width: 20),
                    HomePageInkWell(
                      icons: Icons.fastfood_outlined,
                      screen: CustomData(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    HomePageInkWell(
                      icons: Icons.track_changes_sharp,
                      screen: NutrientTracking(),
                    ),
                    SizedBox(width: 20),
                    HomePageInkWell(
                      icons: Icons.emoji_food_beverage_outlined,
                      screen: CustomEntry(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    HomePageInkWell(
                      icons: Icons.auto_graph,
                      screen: ProgressFrontpage(),
                    ),
                    SizedBox(width: 20),
                    HomePageInkWell(
                      icons: Icons.cookie_outlined,
                      screen: AllDishes(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    HomePageInkWell(
                      icons: Icons.run_circle_outlined,
                      screen: Exercises(),
                    ),
                    SizedBox(width: 20),
                    HomePageInkWell(
                      icons: Icons.settings,
                      screen: SettingsPage(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        onPressed: () {
                          signOut(context);
                        },
                        icon: Icon(
                          Icons.power_settings_new,
                          color: Colors.red,
                          size: 40,
                        ))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Pages_Drawer(
        user: user,
        onSignOut: () => signOut(context),
      ),
    );
  }
}
