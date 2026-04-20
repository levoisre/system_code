import 'package:flutter/material.dart';
import 'assessment_modes/multiple_choice_assessment.dart';
import 'assessment_modes/true_or_false_assessment.dart';
import 'assessment_modes/identification_assessment.dart'; 
import 'assessment_modes/crossword_assessment.dart';        

class QuizInstructionScreen extends StatelessWidget {
  final int quizId; 
  final String quizTitle;
  final String points;
  final String questions;
  final String duration;
  final String quizType; 

  const QuizInstructionScreen({
    super.key,
    required this.quizId, 
    required this.quizTitle,
    required this.points,
    required this.questions,
    required this.duration,
    required this.quizType, 
  });

  static const Color darkNavy = Color(0xFF00084D);

  // --- Instruction Logic per Type ---
  Map<String, String> _getSpecificInstructions() {
    switch (quizType.toLowerCase()) {
      case 'identification':
        return {
          "howTo": "Type the correct answer in the text field. Accuracy is key—spelling counts!",
          "rule": "Avoid using extra spaces at the end of your answer."
        };
      case 'tf':
      case 'true_false':
      case 'true or false':
        return {
          "howTo": "Read the statement carefully and select whether it is True or False.",
          "rule": "You only have one attempt per question. No undoing your choice!"
        };
      case 'crossword':
        return {
          "howTo": "Use the coordinates (Row/Col) to fill in the grid. Letters must match at the intersections.",
          "rule": "The timer keeps running even while you are reading the clues."
        };
      case 'multiple_choice':
      default:
        return {
          "howTo": "Choose the best answer from the four choices provided.",
          "rule": "Points are only awarded for the exact correct choice."
        };
    }
  }

  String _formatDuration(String raw) {
    String clean = raw.replaceAll(RegExp(r'[^0-9]'), "");
    if (clean == "1800" || clean == "30") return "30 Minutes";
    if (clean.isEmpty) return "N/A";
    return "$clean Minutes";
  }

  @override
  Widget build(BuildContext context) {
    final specificData = _getSpecificInstructions();

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
      // FIXED: Added SingleChildScrollView to prevent "Bottom Overflow" on mobile
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quizTitle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: darkNavy, 
                    fontFamily: 'serif'
                  )),
                const SizedBox(height: 20),
                
                const Text("How to Play", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(specificData["howTo"]!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
                
                const SizedBox(height: 15),
                const Text("Rules", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(specificData["rule"]!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
                
                const SizedBox(height: 15),
                const Text("Warning", 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                const Text("You cannot pause the timer once you begin the session.",
                  style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5)),
                
                const SizedBox(height: 30),
                _buildStatItem(Icons.help_outline, "Questions", "$questions Items"),
                _buildStatItem(Icons.stars_rounded, "Total Points", "$points Points"),
                _buildStatItem(Icons.timer_outlined, "Time Limit", _formatDuration(duration)),
                
                const SizedBox(height: 40), // Spacing before button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => _handleStart(context),
                    child: const Text("I UNDERSTAND, START", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleStart(BuildContext context) {
    Widget page;
    String type = quizType.toLowerCase();

    // FIXED: Standardized case handling for all Assessment Types
    if (type.contains('crossword')) {
      page = CrosswordAssessment(quizId: quizId, quizTitle: quizTitle);
    } else if (type.contains('identification')) {
      page = IdentificationQuizScreen(quizId: quizId, quizTitle: quizTitle);
    } else if (type.contains('tf') || type.contains('true')) {
      page = TrueFalseQuizScreen(quizId: quizId, quizTitle: quizTitle);
    } else {
      page = MultipleChoiceQuizScreen(quizId: quizId, quizTitle: quizTitle);
    }

    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => page)
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