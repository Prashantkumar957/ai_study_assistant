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
  bool _isLoading = false;

  final String apiKey = "??";
  final String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=";

  Future<void> generateStudyPlan(String topic) async {
    if (topic.isEmpty) {
      setState(() {
        _studyPlan = "Please enter a topic!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _studyPlan = "Generating study plan...";
    });

    try {
      final response = await http.post(
        Uri.parse("$apiUrl$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "Generate a detailed study plan for $topic."}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('candidates') && responseData['candidates'].isNotEmpty) {
          setState(() {
            _studyPlan = responseData['candidates'][0]['content']['parts'][0]['text'] ?? "No response from AI.";
          });
        } else {
          setState(() {
            _studyPlan = "No valid response from AI.";
          });
        }
      } else {
        setState(() {
          _studyPlan = "Error generating study plan. Please try again!";
        });
      }
    } catch (e) {
      setState(() {
        _studyPlan = "Failed to fetch data. Check your internet connection.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70), // Custom AppBar Height
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.bottomRight,
              end: Alignment.topRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Center(

                  child: Text(
                    "AI Study Planner",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),

                    
                  ),
                ),
                SizedBox(width: 15,),
                Image.asset("assets/images/google_logo.png", height: 50, width: 50),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 🟢 Book Logo Below Title


              // 🟡 Text Field with Prefix Icon
              TextField(
                controller: _topicController,
                decoration: InputDecoration(
                  labelText: "Enter Subject or Topic",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.menu_book, color: Colors.deepPurple), // Book Icon
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // 🟠 Generate Button
              ElevatedButton(
                onPressed: _isLoading ? null : () => generateStudyPlan(_topicController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Generate Study Plan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),

              // 🟢 Study Plan Output
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _studyPlan,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
