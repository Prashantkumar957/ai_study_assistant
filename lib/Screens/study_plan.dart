import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudyPlanPage extends StatefulWidget {
  @override
  _StudyPlanPageState createState() => _StudyPlanPageState();
}

class _StudyPlanPageState extends State<StudyPlanPage> {
  final TextEditingController _topicController = TextEditingController();
  String _studyPlan = "Enter a topic to generate a study plan.";

  // Replace with your actual Google Gemini API Key
  final String apiKey = "YOUR_GEMINI_API_KEY";
  final String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateText";

  Future<void> generateStudyPlan(String topic) async {
    setState(() {
      _studyPlan = "Generating study plan...";
    });

    final response = await http.post(
      Uri.parse("$apiUrl?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "prompt": {"text": "Generate a detailed study plan for $topic."},
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _studyPlan = responseData['candidates'][0]['output'] ?? "No response from AI.";
      });
    } else {
      setState(() {
        _studyPlan = "Error generating study plan. Try again!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Study Plan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: "Enter Subject or Topic",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => generateStudyPlan(_topicController.text),
              child: Text("Generate Study Plan"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_studyPlan, style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
