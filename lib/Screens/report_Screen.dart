import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _detailsController = TextEditingController();
  String _selectedReason = "AI-generated content issue";

  final List<String> _reportReasons = [
    "AI-generated content issue",
    "Request account deletion",
    "Other help",
  ];

  Future<void> _submitReport() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "Anonymous";

    if (_detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide details.")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("user_reports").add({
      "user_id": userId,
      "reason": _selectedReason,
      "details": _detailsController.text,
      "timestamp": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Report submitted successfully!")),
    );

    _detailsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Report an Issue")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Reason:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: _selectedReason,
              items: _reportReasons.map((reason) {
                return DropdownMenuItem(value: reason, child: Text(reason));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value.toString();
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Text("Details:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _detailsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe the issue...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitReport,
                child: Text("Submit Report"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
