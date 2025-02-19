import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
      home: TaskSchedulerPage(),
    );
  }
}

class TaskSchedulerPage extends StatefulWidget {
  @override
  _TaskSchedulerPageState createState() => _TaskSchedulerPageState();
}

class _TaskSchedulerPageState extends State<TaskSchedulerPage> {
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay? _selectedTime;
  List<Map<String, dynamic>> tasks = [];
  double progress = 0.0;
  String? userEmail;

  void _deleteTask(int index) async {
    String taskId = tasks[index]['id'];

    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();

      setState(() {
        tasks.removeAt(index);
        _updateProgress();
      });

      _showSnackbar('🗑️ Task deleted!', Colors.red);
    } catch (e) {
      _showSnackbar('❌ Error deleting task!', Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
      _fetchTasks();
    }
  }

  void _fetchTasks() async {
    if (userEmail == null) return;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userEmail', isEqualTo: userEmail)
          .where('date', isEqualTo: today)
          .get();

      setState(() {
        tasks = snapshot.docs.map((doc) => {
          'id': doc.id,
          'task': doc['task'],
          'time': doc['time'],
          'completed': doc['completed'],
        }).toList();
        _updateProgress();
      });
    } catch (e) {
      print("❌ Error fetching tasks: $e");
    }
  }

  void _addTask() async {
    if (_taskController.text.trim().isEmpty || _selectedTime == null || userEmail == null) {
      _showSnackbar('⚠️ Please enter a task and select a time!', Colors.red);
      return;
    }

    String formattedTime = DateFormat('hh:mm a').format(
      DateTime(0, 0, 0, _selectedTime!.hour, _selectedTime!.minute),
    );
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('tasks').add({
        'task': _taskController.text.trim(),
        'time': formattedTime,
        'date': today,
        'completed': false,
        'userEmail': userEmail,
      });

      setState(() {
        tasks.add({'id': docRef.id, 'task': _taskController.text.trim(), 'time': formattedTime, 'completed': false});
        _taskController.clear();
        _selectedTime = null;
        _updateProgress();
      });

      _showSnackbar('✅ Task added successfully!', Colors.green);
    } catch (e) {
      _showSnackbar('❌ Failed to add task!', Colors.red);
    }
  }

  void _updateProgress() {
    int completedTasks = tasks.where((task) => task['completed']).length;
    setState(() {
      progress = tasks.isEmpty ? 0 : completedTasks / tasks.length;
    });
  }

  void _toggleTaskCompletion(int index) async {
    String taskId = tasks[index]['id'];
    bool newStatus = !tasks[index]['completed'];
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({'completed': newStatus});
    setState(() {
      tasks[index]['completed'] = newStatus;
      _updateProgress();
    });
  }

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Task Scheduler')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 10.0,
              percent: progress,
              center: Text("${(progress * 100).toInt()}%", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              progressColor: Colors.blue,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Enter Task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickTime,
                    icon: Icon(Icons.timer),
                    label: Text(_selectedTime == null ? 'Pick Time' : _selectedTime!.format(context)),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _addTask,
                  child: Icon(Icons.add, size: 30, color: Colors.white),
                  backgroundColor: Colors.blue,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Checkbox(
                        value: tasks[index]['completed'],
                        onChanged: (value) => _toggleTaskCompletion(index),
                      ),
                      title: Text(tasks[index]['task'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text('Time: ${tasks[index]['time']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _deleteTask(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
