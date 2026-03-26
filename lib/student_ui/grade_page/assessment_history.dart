import 'package:flutter/material.dart';

class AssessmentHistoryPage extends StatefulWidget {
  const AssessmentHistoryPage({super.key});

  @override
  State<AssessmentHistoryPage> createState() => _AssessmentHistoryPageState();
}

class _AssessmentHistoryPageState extends State<AssessmentHistoryPage> {
  static const Color darkNavy = Color(0xFF0C1446);
  String selectedMonth = "March 2026";

  // Mock data grouped by month
  final Map<String, List<Map<String, dynamic>>> assessmentData = {
    "March 2026": [
      {
        "date": "March 9, 2026",
        "items": [
          {"title": "Unit Test: Mobile Dev", "score": "38/45"},
          {"title": "Laboratory Exercise 4", "score": "15/15"},
        ]
      },
      {
        "date": "March 8, 2026",
        "items": [
          {"title": "Quiz 1: Software Lifecycle", "score": "9/10"},
          {"title": "Assignment - UI Design", "score": "7/18"},
          {"title": "Long Quiz #2", "score": "18/25"},
        ]
      },
      {
        "date": "March 3, 2026",
        "items": [
          {"title": "SQL Query Practice", "score": "15/15"},
          {"title": "SQL Query Practice", "score": "9/10"},
          {"title": "SQL Query Practice", "score": "19/20"},
          {"title": "SQL Query Practice", "score": "4/10"},
        ]
      },
    ],
    "February 2026": [
      {
        "date": "February 22, 2026",
        "items": [
          {"title": "Midterm Exam", "score": "45/50"},
        ]
      }
    ]
  };

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        List<String> months = assessmentData.keys.toList();
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Select Month", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif')),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(months[index], style: const TextStyle(fontFamily: 'serif')),
                      trailing: selectedMonth == months[index] ? const Icon(Icons.check, color: darkNavy) : null,
                      onTap: () {
                        setState(() => selectedMonth = months[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthRecords = assessmentData[selectedMonth] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('ASSESSMENT HISTORY', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'serif')),
        actions: const [Icon(Icons.notifications, color: Colors.white), SizedBox(width: 15)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // Pushes the Month Selector to the Right
          children: [
            // Month Selector Button
            GestureDetector(
              onTap: _showMonthPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(selectedMonth, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Main List Container
            Container(
              width: double.infinity, // Ensures the card takes up full width
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Keeps date headers and items on the left
                children: [
                  if (currentMonthRecords.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text("No assessments found for this month."),
                      ),
                    )
                  else
                    ...currentMonthRecords.map((data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _dateDivider(data['date']),
                        ...data['items'].map<Widget>((item) => _assessmentRow(item['title'], item['score'])).toList(),
                        const SizedBox(height: 15),
                      ],
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assessmentRow(String title, String score) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: Colors.black54, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, color: Colors.black87))),
          Text(score, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // UPDATED: LEFT-ALIGNED DATE DIVIDER
  Widget _dateDivider(String dateText) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateText, 
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              color: Colors.black, 
              fontSize: 14,
              fontFamily: 'serif'
            ),
          ),
          const SizedBox(height: 5),
          const Divider(thickness: 1, color: Colors.black12),
        ],
      ),
    );
  }
}