import 'package:flutter/material.dart';

class ReviewIdentificationScreen extends StatelessWidget {
  const ReviewIdentificationScreen({super.key});

  static const Color darkNavy = Color(0xFF00084D);
  static const Color bgGrey = Color(0xFFF1F4F8);

  // Mock data specifically for identification mode
  final List<Map<String, dynamic>> reviewData = const [
    {
      "question": "An algorithm that explores all nodes at the present depth level before moving deeper.",
      "userAnswer": "DEPTH FIRST SEARCH",
      "isCorrect": false,
      "correctAnswer": "BREADTH FIRST SEARCH"
    },
    {
      "question": "A linear data structure which follows a particular order in which the operations are performed.",
      "userAnswer": "STACK",
      "isCorrect": true,
      "correctAnswer": "STACK"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        title: const Text(
          'REVIEW IDENTIFICATION',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: darkNavy,
            child: const Text(
              "Your Score: 18/20",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: reviewData.length,
              itemBuilder: (context, index) {
                final item = reviewData[index];
                return _buildCard(item, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item, int number) {
    Color statusColor = item['isCorrect'] ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: darkNavy,
                child: Text("$number", style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
              const SizedBox(width: 10),
              Text(
                item['isCorrect'] ? "CORRECT" : "INCORRECT",
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Spacer(),
              Icon(item['isCorrect'] ? Icons.check_circle : Icons.cancel, color: statusColor, size: 20),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            item['question'],
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'serif', height: 1.4),
          ),
          const Divider(height: 30),
          _answerRow("Your Input:", item['userAnswer'], statusColor),
          if (!item['isCorrect']) ...[
            const SizedBox(height: 10),
            _answerRow("Correct Answer:", item['correctAnswer'], Colors.green),
          ]
        ],
      ),
    );
  }

  Widget _answerRow(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    );
  }
}