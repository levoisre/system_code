import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/leaderboard.dart';

// --- IMPORTS FOR ALL 4 REVIEW MODES ---
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/result_modes/true_or_false_answer.dart';
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/result_modes/identification_answer.dart';
// Note: You can create specific files for MCQ and Crossword reviews later. 
// For now, these route to the most compatible existing review layouts.

class QuizResultsScreen extends StatelessWidget {
  final String quizTitle;

  const QuizResultsScreen({
    super.key, 
    this.quizTitle = "Assessment Result"
  });

  static const Color darkNavy = Color(0xFF00084D);
  static const Color lightBlueBg = Color(0xFFD0E0FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueBg,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          quizTitle,
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // 1. THE 3D PODIUM
            _buildPodium(),

            const SizedBox(height: 25),

            // 2. THE WHITE RANKING CARD
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  children: [
                    const Text(
                      "YOU RANKED 1ST!",
                      style: TextStyle(
                        fontSize: 26, 
                        fontWeight: FontWeight.w900, 
                        color: darkNavy,
                        letterSpacing: 1.2
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    _buildStatsGrid(),

                    const SizedBox(height: 40),

                    // 3. ACTION BUTTONS (CIRCULAR)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _circleActionButton(Icons.stars_rounded, "Leaderboard", () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => const LeaderboardScreen())
                          );
                        }),
                        
                        // --- DYNAMIC REVIEW NAVIGATION ---
                        _circleActionButton(Icons.quiz_outlined, "Review Answers", () {
                          String title = quizTitle.toLowerCase();
                          
                          if (title.contains("identification") || title.contains("crossword")) {
                            // Identification and Crossword both use text-based review
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const ReviewIdentificationScreen())
                            );
                          } 
                          else if (title.contains("quiz 3") || title.contains("algorithms")) {
                            // Multiple choice review logic
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const ReviewIdentificationScreen())
                            );
                          } 
                          else {
                            // Default: True or False review
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const ReviewAnswersScreen())
                            );
                          }
                        }),
                      ],
                    ),

                    const SizedBox(height: 40),
                    const Divider(thickness: 1, color: Colors.black12),
                    const SizedBox(height: 20),

                    // 4. EXIT NAVIGATION
                    _exitButton(context, "BACK TO ASSESSMENT LIST", true, () => Navigator.pop(context)),
                    const SizedBox(height: 12),
                    _exitButton(context, "GO TO HOME PAGE", false, () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    }),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _pillar("2", "14 pts", 130, Colors.white.withValues(alpha: 0.7)),
        _pillar("1", "15 pts", 180, Colors.white),
        _pillar("3", "13 pts", 110, Colors.white.withValues(alpha: 0.5)),
      ],
    );
  }

  Widget _pillar(String rank, String pts, double height, Color color) {
    return Column(
      children: [
        const Icon(Icons.person_pin, size: 40, color: darkNavy),
        const SizedBox(height: 8),
        Container(
          width: 85,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(rank, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: darkNavy)),
              Text(pts, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkNavy)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _StatTile("%100", "Completion"),
              _StatTile("20", "Total Questions"),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(thickness: 1, color: Colors.black12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _StatTile("15", "Correct", valueColor: Colors.green),
              _StatTile("5", "Incorrect", valueColor: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(color: darkNavy, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkNavy)),
        ],
      ),
    );
  }

  Widget _exitButton(BuildContext context, String label, bool primary, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: primary ? darkNavy : Colors.white,
          side: const BorderSide(color: darkNavy, width: 2),
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: primary ? Colors.white : darkNavy, 
            fontWeight: FontWeight.bold, 
            fontSize: 14
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String val, label;
  final Color valueColor;
  const _StatTile(this.val, this.label, {this.valueColor = QuizResultsScreen.darkNavy});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: valueColor)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600)),
      ],
    );
  }
}