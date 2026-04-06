import 'package:flutter/material.dart';
// REMOVED: The two broken imports that were causing the "File not found" errors
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/assessment_modes/multiple_choice_assessment.dart';
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/assessment_modes/true_or_false_assessment.dart';

class QuizInstructionScreen extends StatelessWidget {
  final String quizTitle;
  final String points;
  final String questions;
  final String duration;

  const QuizInstructionScreen({
    super.key,
    required this.quizTitle,
    required this.points,
    required this.questions,
    required this.duration,
  });

  static const Color darkNavy = Color(0xFF00084D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quizTitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: darkNavy, 
                fontFamily: 'serif'
              ),
            ),
            const SizedBox(height: 10),
            const Text("Instructions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              "Read carefully. You cannot pause the timer once you begin.",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            
            _buildStatItem(Icons.help_outline, "Questions", "$questions Items"),
            _buildStatItem(Icons.stars_rounded, "Total Points", "$points Points"),
            _buildStatItem(Icons.timer_outlined, "Time Limit", 
              duration == "1800" ? "30 Minutes" : "$duration Seconds"),
            
            const Spacer(),
            
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () => _handleStart(context),
                  child: const Text(
                    "START ASSESSMENT",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- FIXED: Removed the logic for Crossword and Identification ---
  void _handleStart(BuildContext context) {
    Widget page;

    // We now only check for Multiple Choice (Quiz) or default to True/False
    if (quizTitle.toLowerCase().contains("quiz")) {
      page = MultipleChoiceQuizScreen(quizTitle: quizTitle);
    } else {
      page = TrueFalseQuizScreen(quizTitle: quizTitle);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: darkNavy, size: 22),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.black38, fontSize: 11)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          )
        ],
      ),
    );
  }
}