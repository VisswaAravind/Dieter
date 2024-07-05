import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class WeightProgress extends StatefulWidget {
  @override
  _WeightProgressState createState() => _WeightProgressState();
}

class _WeightProgressState extends State<WeightProgress> {
  final User? user = FirebaseAuth.instance.currentUser;
  late TooltipBehavior _tooltipBehavior;
  String selectedPeriod = 'daily'; // Default selected period

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  List<WeightData> _aggregateData(
      List<DocumentSnapshot> records, String period) {
    Map<String, List<double>> groupedData = {};
    DateTime currentDate = DateTime.now();
    DateTime startDate = period == 'daily'
        ? currentDate.subtract(Duration(days: 20))
        : period == 'weekly'
            ? currentDate.subtract(Duration(days: 140)) // 20 weeks
            : currentDate.subtract(Duration(days: 365));

    for (var doc in records) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      if (date.isBefore(startDate)) continue;
      final weight = (data['weight'] ?? 0.0).toDouble();

      String key;
      if (period == 'daily') {
        key = DateFormat('yyyy-MM-dd').format(date); // Get day of the month
        groupedData[key] = [
          weight
        ]; // Directly map the weight value without averaging
      } else if (period == 'weekly') {
        final weekStart =
            DateTime(date.year, date.month, date.day - (date.weekday - 1));
        key = DateFormat('yyyy-MM-dd')
            .format(weekStart); // Get start of the week day
        if (!groupedData.containsKey(key)) {
          groupedData[key] = [];
        }
        groupedData[key]!.add(weight);
      } else if (period == 'monthly') {
        key = DateFormat('yyyy-MM').format(date); // Get month abbreviation
        if (!groupedData.containsKey(key)) {
          groupedData[key] = [];
        }
        groupedData[key]!.add(weight);
      } else if (period == 'yearly') {
        key = DateFormat('yyyy').format(date);
        if (!groupedData.containsKey(key)) {
          groupedData[key] = [];
        }
        groupedData[key]!.add(weight);
      } else {
        key = '';
      }
    }

    return groupedData.entries.map((entry) {
      final averageWeight =
          entry.value.reduce((a, b) => a + b) / entry.value.length;
      final date = _parseDate(entry.key, period);
      return WeightData(
          date,
          period == 'daily' ? entry.value.first : averageWeight,
          entry.key); // Direct weight value for daily
    }).toList();
  }

  DateTime _parseDate(String dateStr, String period) {
    if (period == 'daily' || period == 'weekly') {
      return DateFormat('yyyy-MM-dd').parse(dateStr); // Parse day of the month
    } else if (period == 'monthly') {
      return DateFormat('yyyy-MM').parse(dateStr); // Parse month abbreviation
    } else if (period == 'yearly') {
      return DateFormat('yyyy').parse(dateStr);
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DC78),
      appBar: AppBar(
        backgroundColor: Color(0xFFB9DC78),
        title: Text('Weight Progress'),
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
            return Center(
                child: Image.asset(
              'assets/gif/food_indicator.gif',
              height: 100,
              width: 100,
            ));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No records found.'));
          }

          final records = snapshot.data!.docs;
          final dailyData = _aggregateData(records, 'daily');
          final weeklyData = _aggregateData(records, 'weekly');
          final monthlyData = _aggregateData(records, 'monthly');
          final yearlyData = _aggregateData(records, 'yearly');

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedPeriod = 'daily';
                      });
                    },
                    icon: Image.asset(
                      'assets/images/daily.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedPeriod = 'weekly';
                      });
                    },
                    icon: Image.asset(
                      'assets/images/weekly.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedPeriod = 'monthly';
                      });
                    },
                    icon: Image.asset(
                      'assets/images/monthly.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedPeriod = 'yearly';
                      });
                    },
                    icon: Image.asset(
                      'assets/images/monthly.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildChart('Daily Weight Report', dailyData,
                          isDaily: true),
                      _buildChart('Weekly Weight Report', weeklyData,
                          isWeekly: true),
                      _buildChart('Monthly Weight Report', monthlyData,
                          isMonthly: true),
                      _buildChart('Yearly Weight Report', yearlyData),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChart(String title, List<WeightData> data,
      {bool isDaily = false, bool isWeekly = false, bool isMonthly = false}) {
    return Visibility(
      visible: isDaily && selectedPeriod == 'daily' ||
          isWeekly && selectedPeriod == 'weekly' ||
          isMonthly && selectedPeriod == 'monthly' ||
          selectedPeriod == 'yearly',
      child: Container(
        margin: EdgeInsets.all(10),
        child: SfCartesianChart(
          primaryXAxis: isMonthly
              ? CategoryAxis()
              : DateTimeAxis(
                  dateFormat:
                      isDaily || isWeekly ? DateFormat.d() : DateFormat.yMd(),
                ),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 200, // Assuming max weight in kg
            interval: 20,
          ),
          title: ChartTitle(text: title),
          legend: Legend(isVisible: true),
          tooltipBehavior: _tooltipBehavior,
          series: <CartesianSeries<WeightData, dynamic>>[
            ColumnSeries<WeightData, dynamic>(
              dataSource: data,
              xValueMapper: (WeightData data, _) =>
                  isMonthly ? data.label : data.date,
              yValueMapper: (WeightData data, _) => data.weight,
              dataLabelSettings: DataLabelSettings(isVisible: true),
              color: Colors.blue, // Set the color of the bars
            ),
          ],
        ),
      ),
    );
  }
}

class WeightData {
  WeightData(this.date, this.weight, [this.label]);
  final DateTime date;
  final double weight;
  final String? label;

  @override
  String toString() {
    return 'WeightData{date: $date, weight: $weight, label: $label}';
  }
}
