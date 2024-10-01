import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;

  const ChartScreen({Key? key, required this.completedTasks, required this.totalTasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Statistics"),
        backgroundColor: Color(0xFF399EF6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Tasks Overview", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: completedTasks.toDouble(),
                          color: Colors.green,
                          width: 30,
                        ),
                        BarChartRodData(
                          toY: (totalTasks - completedTasks).toDouble(),
                          color: Colors.red,
                          width: 30,
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
