import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PiechartData extends StatelessWidget {
  final double caloriesValue;
  final double proteinValue;
  final double carbsValue;
  final double sodiumValue;
  final double sugarValue;
  final double fatValue;
  final double fiberValue;

  const PiechartData({
    required this.caloriesValue,
    required this.proteinValue,
    Key? key,
    required this.carbsValue,
    required this.sodiumValue,
    required this.sugarValue,
    required this.fatValue,
    required this.fiberValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text('Nutrient Chart'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutrient Values',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildColorRow(Colors.greenAccent, 'Calories', caloriesValue),
                _buildColorRow(Colors.cyanAccent, 'Protein', proteinValue),
                _buildColorRow(Colors.orange, 'Carbs', carbsValue),
                _buildColorRow(Colors.lightGreenAccent, 'Sodium', sodiumValue),
                _buildColorRow(Colors.green, 'Sugar', sugarValue),
                _buildColorRow(Colors.white, 'Fat', fatValue),
                _buildColorRow(Colors.redAccent, 'Fiber', fiberValue),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 120,
                      sections: [
                        PieChartSectionData(
                          value: caloriesValue,
                          color: Colors.greenAccent,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: proteinValue,
                          color: Colors.cyanAccent,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: carbsValue,
                          color: Colors.orange,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: sodiumValue,
                          color: Colors.lightGreenAccent,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: sugarValue,
                          color: Colors.green,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: fatValue,
                          color: Colors.white,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: fiberValue,
                          color: Colors.redAccent,
                          title: '',
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Nutrients Data',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(Color color, String name, double value) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 5),
        Text(
          '$name: $value',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
