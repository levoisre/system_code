import 'package:flutter/material.dart';
import '../index.dart'; 
import 'leaderboard.dart';
import 'review_screen.dart'; 

class QuizResultsScreen extends StatelessWidget {
  final int quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> studentAnswers;

  const QuizResultsScreen({
    super.key, 
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.studentAnswers,
  });

  static const Color darkNavy = Color(0xFF00084D);
  static const Color lightBlueBg = Color(0xFFD0E0FF);

  @override
  Widget build(BuildContext context) {
    double percentage = (score / totalQuestions) * 100;

    return Scaffold(
      backgroundColor: lightBlueBg,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          quizTitle.toUpperCase(),
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            fontFamily: 'serif'
          ),
        ),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          // FIX: This keeps the UI clean on Desktop while allowing full width on Mobile
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildPodium(score), 
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
                    // Add subtle shadow for Desktop depth
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))
                    ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: Column(
                      children: [
                        Text(
                          percentage >= 75 ? "EXCELLENT WORK!" : "QUIZ COMPLETED!",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26, 
                            fontWeight: FontWeight.w900, 
                            color: darkNavy,
                            letterSpacing: 1.2,
                            fontFamily: 'serif'
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildStatsGrid(percentage.toInt()),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _circleActionButton(Icons.stars_rounded, "Leaderboard", () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen()));
                            }),
                            _circleActionButton(Icons.quiz_outlined, "Review Answers", () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => AssessmentReviewScreen(
                                  quizId: quizId,
                                  quizTitle: quizTitle,
                                  studentAnswers: studentAnswers,
                                  totalScore: score,
                                )
                              ));
                            }),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Divider(thickness: 1, color: Colors.black12),
                        const SizedBox(height: 20),

                        _exitButton(context, "BACK TO ASSESSMENT LIST", true, () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => StudentIndex(initialIndex: 3)),
                            (Route<dynamic> route) => false,
                          );
                        }),
                        
                        const SizedBox(height: 12),
                        
                        _exitButton(context, "GO TO HOME PAGE", false, () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => StudentIndex(initialIndex: 0)),
                            (Route<dynamic> route) => false,
                          );
                        }),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildPodium(int currentScore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _pillar("2", "${currentScore - 1} pts", 130, Colors.white.withValues(alpha: 0.7)),
        _pillar("1", "$currentScore pts", 180, Colors.white),
        _pillar("3", "${currentScore - 2} pts", 110, Colors.white.withValues(alpha: 0.5)),
      ],
    );
  }

  Widget _pillar(String rank, String pts, double height, Color color) {
    return Column(
      children: [
        const Icon(Icons.person_pin, size: 40, color: darkNavy),
        const SizedBox(height: 8),
        Container(
          width: 85, height: height,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: color, 
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25))
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

  Widget _buildStatsGrid(int pct) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, 
            children: [
              _StatTile("$pct%", "Completion"), 
              _StatTile("$totalQuestions", "Total Qs")
            ]
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(thickness: 1, color: Colors.black12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, 
            children: [
              _StatTile("$score", "Correct", valueColor: Colors.green), 
              _StatTile("${totalQuestions - score}", "Incorrect", valueColor: Colors.red)
            ]
          ),
        ],
      ),
    );
  }

  Widget _circleActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(18), 
          decoration: const BoxDecoration(color: darkNavy, shape: BoxShape.circle), 
          child: Icon(icon, color: Colors.white, size: 28)
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkNavy, fontFamily: 'serif')),
      ]),
    );
  }

  Widget _exitButton(BuildContext context, String label, bool primary, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, height: 52,
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
            fontSize: 14, 
            fontFamily: 'serif'
          )
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
    return Column(children: [
      Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: valueColor, fontFamily: 'serif')), 
      const SizedBox(height: 4), 
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w600, fontFamily: 'serif'))
    ]);
  }
}