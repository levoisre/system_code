import 'package:flutter/material.dart';
import '../index.dart'; 
import 'leaderboard.dart';
// Ensure this import matches your actual file structure
// import 'review_answers.dart'; 

class QuizResultsScreen extends StatelessWidget {
  final String quizTitle;
  final int totalQuestions;
  final int correctAnswers;

  const QuizResultsScreen({
    super.key, 
    this.quizTitle = "Assessment Result",
    this.totalQuestions = 20,
    this.correctAnswers = 15,
  });

  static const Color darkNavy = Color(0xFF0C1446);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color accentBlue = Color(0xFF4A90E2);
  static const Color lightBlueBg = Color(0xFFF0F4F8);

  @override
  Widget build(BuildContext context) {
    double percentage = (correctAnswers / totalQuestions) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFF000040), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          quizTitle.toUpperCase(),
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 13, 
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildPodium(),
          const SizedBox(height: 25),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                child: Column(
                  children: [
                    // --- CIRCULAR SCORE INDICATOR ---
                    _buildCircularScore(percentage),
                    const SizedBox(height: 25),
                    
                    Text(
                      percentage >= 75 ? "EXCELLENT PERFORMANCE!" : "ASSESSMENT COMPLETE!",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.w900, 
                        color: darkNavy,
                        fontFamily: 'serif'
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    _buildStatsGrid(),
                    
                    const SizedBox(height: 35),
                    
                    // --- ENHANCED ACTION BUTTONS ---
                    _buildMainActions(context),
                    
                    const SizedBox(height: 40),
                    
                    _exitButton(context, "RETAKE / BACK TO LIST", true, () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => StudentIndex(initialIndex: 3)),
                        (route) => false,
                      );
                    }),
                    const SizedBox(height: 12),
                    _exitButton(context, "RETURN TO DASHBOARD", false, () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => StudentIndex(initialIndex: 0)),
                        (route) => false,
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularScore(double percent) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: darkNavy.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 140, width: 140,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              backgroundColor: const Color(0xFFF0F4F8),
              valueColor: AlwaysStoppedAnimation<Color>(percent >= 75 ? Colors.green : stiGold),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${percent.toInt()}%", 
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkNavy)
              ),
              const Text(
                "ACCURACY", 
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black26, letterSpacing: 1)
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMainActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            context,
            Icons.fact_check_rounded, 
            "VIEW ANSWERS", 
            "Review items",
            () { /* Navigate to review */ }
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _actionCard(
            context,
            Icons.emoji_events_rounded, 
            "LEADERBOARD", 
            "See rankings",
            () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen()));
            }
          ),
        ),
      ],
    );
  }

  Widget _actionCard(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: darkNavy.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: darkNavy.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: darkNavy, size: 28),
            const SizedBox(height: 12),
            Text(
              title, 
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: darkNavy, letterSpacing: 0.5)
            ),
            Text(
              subtitle, 
              style: const TextStyle(fontSize: 9, color: Colors.black38, fontWeight: FontWeight.w600)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightBlueBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(correctAnswers.toString(), "CORRECT", Colors.green),
          _verticalDivider(),
          _statItem((totalQuestions - correctAnswers).toString(), "WRONG", Colors.redAccent),
          _verticalDivider(),
          _statItem(totalQuestions.toString(), "TOTAL", accentBlue),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.black45, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _verticalDivider() => Container(height: 30, width: 1, color: Colors.black12);

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _pillar("2", "14 pts", 90, Colors.white.withValues(alpha: 0.15)),
        const SizedBox(width: 12),
        _pillar("1", "15 pts", 120, Colors.white.withValues(alpha: 0.3), isFirst: true),
        const SizedBox(width: 12),
        _pillar("3", "13 pts", 75, Colors.white.withValues(alpha: 0.1)),
      ],
    );
  }

  Widget _pillar(String rank, String pts, double height, Color color, {bool isFirst = false}) {
    return Column(
      children: [
        if (isFirst) const Icon(Icons.workspace_premium_rounded, color: stiGold, size: 22),
        const SizedBox(height: 4),
        Container(
          width: 70, height: height,
          decoration: BoxDecoration(
            color: color, 
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(rank, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
              Text(pts, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.5))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _exitButton(BuildContext context, String label, bool primary, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? darkNavy : Colors.white,
          foregroundColor: primary ? Colors.white : darkNavy,
          side: const BorderSide(color: darkNavy, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          label, 
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
        ),
      ),
    );
  }
}