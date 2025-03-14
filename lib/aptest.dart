import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String apiKey = "YOUR_API_KEY"; // Replace with your key
  const String apiUrl = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey";

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "Generate a detailed study plan for Mathematics."}
            ]
          }
        ]
      }),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
  } catch (e) {
    print("Error: $e");
  }
}
