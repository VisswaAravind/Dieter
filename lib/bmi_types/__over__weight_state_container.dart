import 'package:flutter/material.dart';

class Over_WeightStateContainer extends StatelessWidget {
  const Over_WeightStateContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Do',
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            'D',
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            'Do',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
