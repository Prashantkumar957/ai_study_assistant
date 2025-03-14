import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ai_study_assistant/ad_helper.dart';

class StudyPlanPage extends StatefulWidget {
  @override
  _StudyPlanPageState createState() => _StudyPlanPageState();
}

class _StudyPlanPageState extends State<StudyPlanPage> {
  final TextEditingController _topicController = TextEditingController();
  String _studyPlan = "Enter a topic to generate a study plan.";
  bool _isLoading = false;

  final String apiKey = "AIzaSyD_Nh-47V0zjIOPhO1RsvvletXjTb4j9Zw";
  final String apiUrl = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=";
  final AdHelper _adHelper = AdHelper();

  @override
  void initState() {
    super.initState();
    _adHelper.loadInterstitialAd();
    _adHelper.loadBannerAd1();
    _adHelper.loadBannerAd2();
    _adHelper.loadBannerAd3();
  }

  Future<void> generateStudyPlan(String topic) async {
    _adHelper.showInterstitialAd();

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
        _adHelper.showInterstitialAd();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("AI Study Planner", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            Image.asset("assets/images/img.png", height: 40),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.bottomRight,
              end: Alignment.topRight,
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
              TextField(
                controller: _topicController,
                decoration: InputDecoration(
                  labelText: "Enter Subject or Topic",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.menu_book, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
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
                    : Text("Generate Study Plan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_studyPlan, style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _adHelper.getBannerAdWidget1(),
              SizedBox(height: 10),
              _adHelper.getBannerAdWidget2(),
              SizedBox(height: 10),
              _adHelper.getBannerAdWidget3(),
            ],
          ),
        ),
      ),
    );
  }
}
