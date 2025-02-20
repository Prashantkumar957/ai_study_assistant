import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> chatMessages = [];
  bool _isLoading = false;
  int _messageCount = 0; // Counter for user messages
  final int _maxMessages = 3; // Max messages allowed before reset
  final String apiKey = "??";
  final String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=";

  Future<void> sendMessage(String message) async {
    if (_messageCount >= _maxMessages) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Message limit reached! Watch an ad to continue."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (message.isEmpty) return;
    setState(() {
      _isLoading = true;
      chatMessages.add({"sender": "user", "text": message});
      _messageCount++; // Increment counter
    });

    final response = await http.post(
      Uri.parse("$apiUrl$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String botReply = responseData['candidates'][0]['content']['parts'][0]['text'] ?? "No response from AI.";

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
      _messageCount = 0; // Reset counter
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
          if (_messageCount >= _maxMessages)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Watch an ad to continue chatting!"))
                  );
                  resetMessageCounter(); // Reset message limit after ad
                },
                child: Text("Watch Ad to Continue"),
              ),
            ),
          if (_messageCount < _maxMessages)
            Padding(
              padding: const EdgeInsets.only(bottom: 108.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: "Type a message",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: _messageCount < _maxMessages ? Colors.blue : Colors.grey),
                    onPressed: _messageCount < _maxMessages
                        ? () {
                      sendMessage(_messageController.text);
                      _messageController.clear();
                    }
                        : null, // Disable if limit reached
                  )
                ],
                // android studio verison string=AIzaSyD_Nh-47V0zjIOPhO1RsvvletXjTb4j9Zw
              ),
            ),
        ],
      ),
    );
  }
}

