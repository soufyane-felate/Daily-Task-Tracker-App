import 'package:daily_task_tracker/ChartScreen.dart';
import 'package:daily_task_tracker/ReminderScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  final TextEditingController searchController = TextEditingController();
  List<Map<String, String>> taskList = [];
  int completedTasks = 0;
  String? errorMessage;
  bool _isNotificationEnabled = true;
  String _selectedFilter = 'All';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tz.initializeTimeZones(); // Initialize timezone database
    _loadTasks();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
              'time': parts[2],
              'category': parts[3],
              'isCompleted': parts[4],
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
      return '${task['task']}|${task['date']}|${task['time']}|${task['category']}|${task['isCompleted']}';
    }).toList();
    await prefs.setStringList('tasks', tasks);
  }
  Future<void> _editTask(int index, String newTask, String newDate,
      String newTime, String newCategory) async {
    setState(() {
      taskList[index]['task'] = newTask;
      taskList[index]['date'] = newDate;
      taskList[index]['time'] = newTime;
      taskList[index]['category'] = newCategory;
      _saveTasks();
    });
  }
  void _toggleCompletion(int index, bool? isChecked) {
    setState(() {
      taskList[index]['isCompleted'] = isChecked! ? 'true' : 'false';
      completedTasks =
          taskList.where((task) => task['isCompleted'] == 'true').length;
      _saveTasks();
    });
  }
  void _deleteTask(int index) {
    setState(() {
      taskList.removeAt(index);
      _saveTasks();
    });
  }
 void _showTaskDialog({int? index}) {
  String? selectedCategory = 'Work';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  if (index != null) {
    selectedCategory = taskList[index]['category'];
    taskController.text = taskList[index]['task']!;
    selectedDate = DateTime.parse(taskList[index]['date']!);
    selectedTime = TimeOfDay(
      hour: int.parse(taskList[index]['time']!.split(':')[0]),
      minute: int.parse(taskList[index]['time']!.split(':')[1]),
    );
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        title: Text(
          index == null ? "Add Task" : "Edit Task",
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF399EF6),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                style: TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Enter your task',
                  filled: true,
                  fillColor: Color(0xFFEFEFEF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF399EF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text("Pick Date"),
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  ).then((pickedDate) {
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        errorMessage = null;
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF399EF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text("Pick Time"),
                onPressed: () {
                  showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  ).then((pickedTime) {
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                        errorMessage = null;
                      });
                    } else {
                      setState(() {
                        errorMessage = "Please select a time.";
                      });
                    }
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFEFEFEF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 15),
                ),
                items: ['Work', 'Personal', 'Study'].map((String category) {
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
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF399EF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              if (taskController.text.isEmpty ||
                  selectedDate == null ||
                  selectedTime == null ||
                  selectedCategory == null) {
                setState(() {
                  errorMessage = "Please fill all fields.";
                });
              } else {
                if (index == null) {
                  setState(() {
                    taskList.add({
                      'task': taskController.text,
                      'date': selectedDate!.toLocal().toString().split(' ')[0],
                      'time': selectedTime!.format(context),
                      'category': selectedCategory!,
                      'isCompleted': 'false',
                    });
                    taskController.clear();
                    errorMessage = null;
                  });
                } else {
                  _editTask(
                    index,
                    taskController.text,
                    selectedDate!.toLocal().toString().split(' ')[0],
                    selectedTime!.format(context),
                    selectedCategory!,
                  );
                }
                _saveTasks();
                Navigator.of(context).pop();
              }
            },
            child: Text(index == null ? "Add" : "Save"),
          ),
        ],
      );
    },
  );
}


  void _scheduleNotification(int index, DateTime scheduledTime) async {
    var androidDetails = const AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      importance: Importance.high,
    );
    var platformDetails = NotificationDetails(android: androidDetails);

    // Convert DateTime to TZDateTime for scheduling
    tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      index, // unique ID for each notification
      'Task Reminder',
      'You have a task: ${taskList[index]['task']}',
      tzScheduledTime,
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents:
          DateTimeComponents.time, // Trigger notification at the specific time
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredTasks = taskList
        .where((task) {
          final searchQuery = searchController.text.toLowerCase();
          return (task['task']!.toLowerCase().contains(searchQuery) ||
              task['date']!.contains(searchQuery));
        })
        .where((task) =>
            _selectedFilter == 'All' || task['category'] == _selectedFilter)
        .toList();

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
            icon: Icon(Icons.pie_chart),
            onPressed: () {
              int workTasks =
                  taskList.where((task) => task['category'] == 'Work').length;
              int personalTasks = taskList
                  .where((task) => task['category'] == 'Personal')
                  .length;
              int studyTasks =
                  taskList.where((task) => task['category'] == 'Study').length;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChartScreen(
                    completedTasks: completedTasks,
                    totalTasks: taskList.length,
                    workTasks: workTasks,
                    personalTasks: personalTasks,
                    studyTasks: studyTasks,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by task or date',
              border: OutlineInputBorder(),
              fillColor: Color(0xFF399EF6),
              filled: true,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          // Segmented Control for filtering tasks
          Container(
            width: double.infinity,
            color: Color(0xFF399EF6),
            padding: const EdgeInsets.all(10.0),
            child: SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(value: 'All', label: Text('All')),
                ButtonSegment<String>(value: 'Work', label: Text('Work')),
                ButtonSegment<String>(
                    value: 'Personal', label: Text('Personal')),
                ButtonSegment<String>(value: 'Study', label: Text('Study')),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedFilter = newSelection.first;
                });
              },
            ),
          ),

          // Progress Bar
          Container(
            height: 60,
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
              children: [
                Text(
                  "You finished ${taskList.isEmpty ? 0 : (completedTasks / taskList.length * 100).toStringAsFixed(0)}%",
                  style: TextStyle(color: Colors.white),
                ),
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
          filteredTasks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child:
                      Text("No tasks added yet!", style: GoogleFonts.roboto()),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: ListTile(
                          title: Text(filteredTasks[index]['task'] ?? '',
                              style: GoogleFonts.roboto()),
                          subtitle: Text(
                              "${filteredTasks[index]['date']} ${filteredTasks[index]['time']} - ${filteredTasks[index]['category']}",
                              style: TextStyle(color: Colors.grey[600])),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: filteredTasks[index]['isCompleted'] ==
                                    'true',
                                onChanged: (bool? checked) {
                                  _toggleCompletion(
                                      taskList.indexOf(filteredTasks[index]),
                                      checked);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showTaskDialog(
                                    index:
                                        taskList.indexOf(filteredTasks[index])),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Delete Task",
                                            style: GoogleFonts.roboto()),
                                        content: Text(
                                            "Are you sure you want to delete this task?"),
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text("Delete"),
                                            onPressed: () {
                                              _deleteTask(taskList.indexOf(
                                                  filteredTasks[index]));
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(_isNotificationEnabled
                                    ? Icons.notifications
                                    : Icons.notifications_off),
                                onPressed: () {
                                  if (_isNotificationEnabled) {
                                    DateTime taskDate = DateTime.parse(
                                        taskList[index]['date']!);
                                    TimeOfDay taskTime = TimeOfDay(
                                        hour: int.parse(taskList[index]['time']!
                                            .split(':')[0]),
                                        minute: int.parse(taskList[index]
                                                ['time']!
                                            .split(':')[1]));
                                    DateTime scheduledTime = DateTime(
                                        taskDate.year,
                                        taskDate.month,
                                        taskDate.day,
                                        taskTime.hour,
                                        taskTime.minute);

                                    _scheduleNotification(index, scheduledTime);
                                  }

                                  setState(() {
                                    _isNotificationEnabled =
                                        !_isNotificationEnabled;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          SizedBox(height: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF399EF6),
        onPressed: () => _showTaskDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
