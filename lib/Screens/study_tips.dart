import 'dart:convert';
import 'package:ai_study_assistant/Authentication_Pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:ai_study_assistant/ad_helper.dart'; // Import the AdHelper class

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
  List<Map<String, String>> chatMessages = [];
  bool _isLoading = false;
  int _messageCount = 0;
  final int _maxMessages = 3;
  final String apiKey = "AIzaSyD_Nh-47V0zjIOPhO1RsvvletXjTb4j9Zw"; // Replace with your actual API key
  final AdHelper _adHelper = AdHelper();

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
            "parts": [
              {"text": message}
            ]
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with AI")),
      body: Column(
        children: [
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

          // Message Limit Warning
          if (_messageCount >= _maxMessages)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  _adHelper.showInterstitialAd();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Watch an ad to continue chatting!")),
                  );
                  resetMessageCounter();
                },
                child: Text("Watch Ad to Continue"),
              ),
            ),

          if (_messageCount < _maxMessages)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Text Input Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isLoading, // Disable input when loading
                          decoration: InputDecoration(
                            labelText: "Type a message",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: _messageCount < _maxMessages ? Colors.blue : Colors.grey),
                        onPressed: _messageCount < _maxMessages && !_isLoading
                            ? () {
                          sendMessage(_messageController.text);
                          _messageController.clear();
                        }
                            : null,
                      ),
                    ],
                  ),

                  // Loading Indicator (Shown Above the TextField)
                  if (_isLoading)
                    Positioned(
                      right: 50,
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),

          // Banner Ads
          _adHelper.getBannerAdWidget3(),
          _adHelper.getBannerAdWidget2(),
          _adHelper.getBannerAdWidget1(),
        ],
      ),
    );
  }
}
