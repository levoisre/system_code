import 'package:flutter/material.dart';

class ReviewAnswersScreen extends StatelessWidget {
  const ReviewAnswersScreen({super.key});

  static const Color darkNavy = Color(0xFF00084D);
  static const Color bgGrey = Color(0xFFF1F4F8);

  // Mock data for the review
  final List<Map<String, dynamic>> reviewData = const [
    {
      "question": "A stack follows the First-In, First-Out (FIFO) principle.",
      "userAnswer": "False",
      "isCorrect": true,
      "correctAnswer": "False (Stack is LIFO)"
    },
    {
      "question": "Flutter uses the Dart programming language.",
      "userAnswer": "True",
      "isCorrect": true,
      "correctAnswer": "True"
    },
    {
      "question": "StatelessWidgets can change their state during runtime.",
      "userAnswer": "True",
      "isCorrect": false,
      "correctAnswer": "False"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false, // Custom back button used instead
        title: const Text(
          'REVIEW ANSWERS',
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
          // --- TOP SCORE BANNER ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: darkNavy,
            child: const Text(
              "Final Score: 15/20",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // --- QUESTIONS LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: reviewData.length,
              itemBuilder: (context, index) {
                final item = reviewData[index];
                return _buildReviewCard(item, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> item, int number) {
    Color statusColor = item['isCorrect'] ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: darkNavy,
                child: Text(number.toString(), 
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Icon(
                item['isCorrect'] ? Icons.check_circle : Icons.cancel, 
                color: statusColor, 
                size: 20
              ),
              const Spacer(),
              Text(
                item['isCorrect'] ? "CORRECT" : "INCORRECT",
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            item['question'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'serif'),
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _answerLabel("Your Answer:", item['userAnswer'], statusColor),
              if (!item['isCorrect'])
                _answerLabel("Correct Answer:", item['correctAnswer'], Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _answerLabel(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}