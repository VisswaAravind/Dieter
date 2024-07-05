import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class HomePageInkWell extends StatelessWidget {
  const HomePageInkWell({
    super.key,
    required this.icons,
    this.screen,
  });

  final dynamic icons; // Use dynamic to accept both IconData and Image
  final Widget? screen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(screen!);
      },
      child: CircleAvatar(
        radius: 70.0, // Adjust the radius as needed
        backgroundColor:
            Colors.white60, // Adjust the background color as needed
        child: _buildIconOrImage(),
      ),
    );
  }

  Widget _buildIconOrImage() {
    if (icons is IconData) {
      return Icon(
        icons,
        color: Colors.black,
        size: 50,
      );
    } else if (icons is Image) {
      return icons;
    } else {
      return const SizedBox
          .shrink(); // Return an empty widget if the type is unsupported
    }
  }
}
