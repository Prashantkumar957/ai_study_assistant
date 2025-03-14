import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:ai_study_assistant/ad_helper.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeeklySchedulerPage(),
    );
  }
}

class WeeklySchedulerPage extends StatefulWidget {
  @override
  _WeeklySchedulerPageState createState() => _WeeklySchedulerPageState();
}

class _WeeklySchedulerPageState extends State<WeeklySchedulerPage> {
  final TextEditingController _taskController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _selectedDate;
  List<DateTime> weekDays = [];
  List<Map<String, dynamic>> tasks = [];
  double progress = 0.0;
  String? userEmail;
  final AdHelper _adHelper = AdHelper();

  @override
  void initState() {

    _adHelper.loadInterstitialAd();
    _adHelper.showInterstitialAd();
    _adHelper.loadBannerAd1(); // Load first banner ad
    _adHelper.loadBannerAd2(); // Load second banner ad
    _adHelper.loadBannerAd3();

    super.initState();
    _fetchCurrentUser();
    _initializeWeekDays();
  }

  void _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }

  void _initializeWeekDays() {
    setState(() {
      _startDate = DateTime.now();
      _endDate = _startDate!.add(Duration(days: 6)); // Next 7 days
      _generateWeekDays();
    });
  }

  void _generateWeekDays() {
    if (_startDate == null || _endDate == null) return;
    weekDays.clear();
    for (int i = 0; i < 7; i++) {
      DateTime day = _startDate!.add(Duration(days: i));
      weekDays.add(day);
    }
    if (weekDays.isNotEmpty) {
      _selectedDate = weekDays.first;
      _fetchTasksForSelectedDate();
    }
  }

  void _fetchTasksForSelectedDate() async {
    if (userEmail == null || _selectedDate == null) return;
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('weekly_tasks')
          .where('userEmail', isEqualTo: userEmail)
          .where('date', isEqualTo: formattedDate)
          .get();

      setState(() {
        tasks = snapshot.docs.map((doc) => {
          'id': doc.id,
          'task': doc['task'],
          'completed': doc['completed'],
        }).toList();
        _updateCompletionProgress();
      });
    } catch (e) {
      print("❌ Error fetching tasks: $e");
    }
  }

  void _updateCompletionProgress() {
    if (tasks.isEmpty) {
      setState(() {
        progress = 0.0;
      });
      return;
    }
    int completedTasks = tasks.where((task) => task['completed'] == true).length;
    setState(() {
      progress = completedTasks / tasks.length;
    });
  }

  void _deleteWeeklyTask(int index) async {
    String taskId = tasks[index]['id'];
    try {
      await FirebaseFirestore.instance.collection('weekly_tasks').doc(taskId).delete();
      setState(() {
        tasks.removeAt(index);
        _updateCompletionProgress();
      });
    } catch (e) {
      print("❌ Error deleting task: $e");
    }
  }

  void _addTask() async {
    if (_taskController.text.isEmpty || userEmail == null || _selectedDate == null) return;

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    try {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('weekly_tasks').add({
        'userEmail': userEmail,
        'task': _taskController.text,
        'completed': false,
        'date': formattedDate,
      });

      setState(() {
        tasks.add({
          'id': docRef.id,
          'task': _taskController.text,
          'completed': false,
        });
        _updateCompletionProgress();
      });

      _taskController.clear();
    } catch (e) {
      print("❌ Error adding task: $e");
    }
  }

  void _toggleTaskCompletion(int index) async {
    String taskId = tasks[index]['id'];
    bool newStatus = !tasks[index]['completed'];

    try {
      await FirebaseFirestore.instance.collection('weekly_tasks').doc(taskId).update({
        'completed': newStatus,
      });

      setState(() {
        tasks[index]['completed'] = newStatus;
        _updateCompletionProgress();
      });
    } catch (e) {
      print("❌ Error updating task: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weekly Task Scheduler')),
      body: Column(
        children: [
          SizedBox(height: 10),
          // Date Selection Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: weekDays.map((date) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                      _fetchTasksForSelectedDate();
                    },
                    child: Chip(
                      label: Text(DateFormat('EEE, MMM d').format(date)),
                      backgroundColor: _selectedDate == date ? Colors.blue : Colors.grey[300],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 10),

          // Progress Indicator
          CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 8.0,
            percent: progress,
            center: Text('${(progress * 100).toInt()}%'),
            progressColor: Colors.green,
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: "Enter task here and then click on add",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text("Add"),
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(
                      tasks[index]['task'],
                      style: TextStyle(
                        decoration: tasks[index]['completed']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    leading: Checkbox(
                      value: tasks[index]['completed'],
                      onChanged: (value) => _toggleTaskCompletion(index),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteWeeklyTask(index),
                    ),
                  ),
                );
              },
            ),
          ),

          _adHelper.getBannerAdWidget2(),
          _adHelper.getBannerAdWidget3(),
        ],

      ),

    );
  }
}
