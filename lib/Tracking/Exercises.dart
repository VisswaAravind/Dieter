import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Exercises extends StatefulWidget {
  const Exercises({super.key});

  @override
  State<Exercises> createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  late WebViewController con;
  @override
  void initState() {
    super.initState();
    con = WebViewController()
      ..loadRequest(
        Uri.parse('https://darebee.com/'), // Replace with your desired URL
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: WebViewWidget(
          controller: con,
        ),
      ),
    );
  }
}
