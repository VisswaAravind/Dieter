import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class WaistHipRatioPage extends StatefulWidget {
  @override
  _WaistHipRatioPageState createState() => _WaistHipRatioPageState();
}

class _WaistHipRatioPageState extends State<WaistHipRatioPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  late TooltipBehavior _tooltipBehavior;
  String selectedPeriod = 'daily'; // Default selected period

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  List<RatioData> _aggregateData(
      List<DocumentSnapshot> records, String period) {
    Map<String, List<double>> groupedData = {};
    DateTime currentDate = DateTime.now();
    DateTime startDate = period == 'daily'
        ? currentDate.subtract(Duration(days: 20))
        : period == 'weekly'
            ? currentDate.subtract(Duration(days: 140)) // 20 weeks
            : period == 'monthly'
                ? currentDate.subtract(Duration(days: 365)) // 12 months
                : currentDate.subtract(Duration(days: 365 * 5)); // 5 years

    for (var doc in records) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      final waistHipRatio = (data['waistHipRatio'] ?? 0.0).toDouble();

      if (date.isBefore(startDate)) continue;

      String key;
      if (period == 'daily') {
        key = DateFormat('yyyy-MM-dd').format(date); // Get day of the month
      } else if (period == 'weekly') {
        final weekStart =
            DateTime(date.year, date.month, date.day - (date.weekday - 1));
        key = DateFormat('yyyy-MM-dd')
            .format(weekStart); // Get start of the week day
      } else if (period == 'monthly') {
        key = DateFormat('yyyy-MM').format(date); // Get month abbreviation
      } else if (period == 'yearly') {
        key = DateFormat('yyyy').format(date);
      } else {
        key = '';
      }

      if (!groupedData.containsKey(key)) {
        groupedData[key] = [];
      }
      groupedData[key]!.add(waistHipRatio);
    }

    // Add today's data if not already present
    if (period == 'daily') {
      String todayKey = DateFormat('yyyy-MM-dd').format(currentDate);
      if (!groupedData.containsKey(todayKey)) {
        groupedData[todayKey] = [];
      }
    }

    return groupedData.entries.map((entry) {
      final date = _parseDate(entry.key, period);
      double value;
      if (period == 'daily') {
        value = entry.value.isNotEmpty ? entry.value.first : 0.0;
      } else {
        value = entry.value.reduce((a, b) => a + b) / entry.value.length;
      }
      return RatioData(date, value, entry.key);
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
        title: Text('Waist-Hip Ratio Progress'),
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
                      'assets/images/yearly.png',
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
                      _buildChart('Daily Waist-Hip Ratio Report', dailyData,
                          isDaily: true),
                      _buildChart('Weekly Waist-Hip Ratio Report', weeklyData,
                          isWeekly: true),
                      _buildChart('Monthly Waist-Hip Ratio Report', monthlyData,
                          isMonthly: true),
                      _buildChart('Yearly Waist-Hip Ratio Report', yearlyData),
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

  Widget _buildChart(String title, List<RatioData> data,
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
                  interval: 1,
                  intervalType: DateTimeIntervalType.auto,
                ),
          primaryYAxis: NumericAxis(
            minimum: 0.1,
            maximum: 1.5,
            interval: 0.1,
          ),
          title: ChartTitle(text: title),
          legend: Legend(isVisible: true),
          tooltipBehavior: _tooltipBehavior,
          series: <CartesianSeries<RatioData, dynamic>>[
            ColumnSeries<RatioData, dynamic>(
              dataSource: data,
              xValueMapper: (RatioData data, _) =>
                  isMonthly ? data.label : data.date,
              yValueMapper: (RatioData data, _) => data.ratio,
              dataLabelSettings: DataLabelSettings(isVisible: true),
              color: Colors.green, // Set the color of the bars
            ),
          ],
        ),
      ),
    );
  }
}

class RatioData {
  RatioData(this.date, this.ratio, [this.label]);
  final DateTime date;
  final double ratio;
  final String? label;
}
