import 'package:daily_task_tracker/ChartScreen.dart';
import 'package:daily_task_tracker/ReminderScreen.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController taskController = TextEditingController();
  List<Map<String, String>> taskList = [];
  int completedTasks = 0;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? tasks = prefs.getStringList('tasks');
    setState(() {
      taskList = tasks?.map((task) {
            List<String> parts = task.split('|');
            return {
              'task': parts[0],
              'date': parts[1],
              'category': parts[2],
              'isCompleted': parts[3],
            };
          }).toList() ??
          [];
      completedTasks =
          taskList.where((task) => task['isCompleted'] == 'true').length;
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tasks = taskList.map((task) {
      return '${task['task']}|${task['date']}|${task['category']}|${task['isCompleted']}';
    }).toList();
    await prefs.setStringList('tasks', tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Tracker", style: GoogleFonts.roboto()),
        backgroundColor: Color(0xFF399EF6),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReminderScreen()),
              );
            },
          ),
           IconButton(
      icon: Icon(Icons.pie_chart), // Use an appropriate icon for charts
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChartScreen(
              completedTasks: completedTasks,
              totalTasks: taskList.length,
            ),
          ),
        );
      },
    ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              color: Color(0xFF399EF6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    "You finished ${taskList.isEmpty ? 0 : (completedTasks / taskList.length * 100).toStringAsFixed(0)}%",
                    style: TextStyle(color: Colors.white)),
                SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    value:
                        taskList.isEmpty ? 0 : completedTasks / taskList.length,
                    backgroundColor: Colors.white,
                    color: Colors.green,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          taskList.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child:
                      Text("No tasks added yet!", style: GoogleFonts.roboto()),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: ListTile(
                          title: Text(taskList[index]['task'] ?? '',
                              style: GoogleFonts.roboto()),
                          subtitle: Text(
                              "${taskList[index]['date']} - ${taskList[index]['category']}",
                              style: TextStyle(color: Colors.grey[600])),
                          trailing: Checkbox(
                            value: taskList[index]['isCompleted'] == 'true',
                            onChanged: (bool? checked) {
                              setState(() {
                                taskList[index]['isCompleted'] =
                                    checked! ? 'true' : 'false';
                                completedTasks = taskList
                                    .where(
                                        (task) => task['isCompleted'] == 'true')
                                    .length;
                                _saveTasks(); // Save tasks after completion change
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
          // Display error message if exists
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              DateTime? selectedDate;
              String? selectedCategory = 'Work'; // Default category
              List<String> categories = ['Work', 'Personal', 'Study'];

              return AlertDialog(
                title: Text("Add Task", style: GoogleFonts.roboto()),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: taskController,
                      decoration: InputDecoration(hintText: 'Enter your task'),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      child: Text("Pick Date"),
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        ).then((pickedDate) {
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                              errorMessage = null; // Clear error message
                            });
                          } else {
                            setState(() {
                              errorMessage = "Please select a date.";
                            });
                          }
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedCategory,
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newCategory) {
                        setState(() {
                          selectedCategory = newCategory;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (taskController.text.isEmpty ||
                          selectedDate == null ||
                          selectedCategory == null) {
                        // Show alert if any field is empty
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text("Please fill all fields."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // If all fields are filled, add the task
                        setState(() {
                          taskList.add({
                            'task': taskController.text,
                            'date': selectedDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                            'category': selectedCategory!,
                            'isCompleted': 'false',
                          });
                          taskController.clear();
                          errorMessage = null;
                          _saveTasks(); // Save tasks after adding a new one
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF399EF6), // Match the app bar color
      ),
    );
  }
}
