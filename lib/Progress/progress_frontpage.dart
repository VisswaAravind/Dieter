import 'package:dieter/Login_Signup/home_page_ink_well.dart';
import 'package:dieter/Progress/Nutrient_Tracking.dart';
import 'package:dieter/Progress/bmi_progress.dart';
import 'package:dieter/Progress/waist_hip_ratio_progress.dart';
import 'package:dieter/Progress/weight_progress.dart';
import 'package:flutter/material.dart';

class ProgressFrontpage extends StatefulWidget {
  const ProgressFrontpage({super.key});

  @override
  State<ProgressFrontpage> createState() => _ProgressFrontpageState();
}

class _ProgressFrontpageState extends State<ProgressFrontpage> {
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
            child: Container(
                /*decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    */ /*Colors.black,
                    Colors.green,*/ /*
                    Colors.black54,
                    Colors.green,
                  ],
                ),
              ),*/
                ),
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
                      'Hello....',
                      style: TextStyle(
                          fontSize: 60,
                          color: Colors.black54,
                          fontFamily: 'ChocoChici-2OMyW'),
                    ),
                  ],
                ),
                Text(
                  'Choose One...',
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontFamily: 'ShadeBlue-2OozX'),
                ),
                Text(
                  'To View the Progress...',
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
                      icons: Image.asset(
                        'assets/images/img_8.png',
                        width: 50,
                        height: 50,
                      ),
                      screen: BmiProgress(),
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
                      icons: Image.asset(
                        'assets/images/img_6.png',
                        width: 50,
                        height: 50,
                      ),
                      screen: WeightProgress(),
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
                      icons: Image.asset(
                        'assets/images/wai,hip_progress.png',
                        width: 50,
                        height: 50,
                      ),
                      screen: WaistHipRatioPage(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    HomePageInkWell(
                      icons: Image.asset(
                        'assets/images/Calories_icon.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}
