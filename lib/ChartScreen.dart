import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final int workTasks;
  final int personalTasks;
  final int studyTasks;

  const ChartScreen({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.workTasks,
    required this.personalTasks,
    required this.studyTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Statistics"),
        backgroundColor: const Color(0xFF399EF6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tasks Overview",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
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
                  titlesData: const FlTitlesData(
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
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          "Category Breakdown",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  color: Colors.blue,
                                  value: workTasks.toDouble(),
                                  title: 'Work',
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: Colors.orange,
                                  value: personalTasks.toDouble(),
                                  title: 'Personal',
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: Colors.purple,
                                  value: studyTasks.toDouble(),
                                  title: 'Study',
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          "Task Completion",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: completedTasks.toDouble(),
                                  title: 'Completed',
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: Colors.red,
                                  value:
                                      (totalTasks - completedTasks).toDouble(),
                                  title: 'Remaining',
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
