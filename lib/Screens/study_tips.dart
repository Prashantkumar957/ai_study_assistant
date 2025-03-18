import 'dart:convert';
import 'package:ai_study_assistant/Authentication_Pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:ai_study_assistant/ad_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null ? LoginScreen() : ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _reportController = TextEditingController();
  String _selectedReason = "AI-generated content issue";
  List<Map<String, String>> chatMessages = [];
  bool _isLoading = false;
  int _messageCount = 0;
  final int _maxMessages = 3;
  final AdHelper _adHelper = AdHelper();
  final String apiKey = "AIzaSyD_Nh-47V0zjIOPhO1RsvvletXjTb4j9Zw";

  @override
  void initState() {
    super.initState();
    _adHelper.loadBannerAd1();
    _adHelper.loadBannerAd2();
    _adHelper.loadBannerAd3();
  }

  Future<void> sendMessage(String message) async {
    if (_messageCount >= _maxMessages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Message limit reached! Watch an ad to continue."), backgroundColor: Colors.red),
      );
      return;
    }
    if (message.isEmpty) return;
    setState(() {
      _isLoading = true;
      chatMessages.add({"sender": "user", "text": message});
      _messageCount++;
    });

    final response = await http.post(
      Uri.parse("https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [{"text": message}]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String botReply = responseData['candidates']?[0]['content']?['parts']?[0]['text'] ?? "No response from AI.";
      setState(() {
        chatMessages.add({"sender": "bot", "text": botReply});
      });
    } else {
      setState(() {
        chatMessages.add({"sender": "bot", "text": "Error! Try again later."});
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void resetMessageCounter() {
    setState(() {
      _messageCount = 0;
    });
  }

  Future<void> _submitReport() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "Anonymous";
    if (_reportController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please provide details.")));
      return;
    }
    await FirebaseFirestore.instance.collection("user_reports").add({
      "user_id": userId,
      "reason": _selectedReason,
      "details": _reportController.text,
      "timestamp": Timestamp.now(),
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Report submitted successfully!")));
    _reportController.clear();
    Navigator.pop(context);
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Report an Issue"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                value: _selectedReason,
                items: ["AI-generated content issue", "Request account deletion", "Other help"].map((reason) {
                  return DropdownMenuItem(value: reason, child: Text(reason));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value.toString();
                  });
                },
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _reportController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Describe the issue...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(onPressed: _submitReport, child: Text("Submit")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with AI"),
        actions: [IconButton(icon: Icon(Icons.report), onPressed: _showReportDialog)],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final msg = chatMessages[index];
                bool isUser = msg["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg["text"]!, style: TextStyle(color: isUser ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),

          // **Loading Indicator When AI is Responding**
          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(),
            ),

          // **Message Input Box & Send Button**
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    sendMessage(_messageController.text);
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),

          // **Banner Ad BELOW the Text Field**
          _adHelper.getBannerAdWidget1(),
          _adHelper.getBannerAdWidget3(),


        ],
      ),

    );
  }
}