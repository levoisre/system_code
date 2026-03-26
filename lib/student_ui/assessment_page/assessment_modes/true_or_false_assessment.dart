import 'dart:async';
import 'package:flutter/material.dart';
// Ensure this matches your actual results filename
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/assessment_result.dart';

class TrueFalseQuizScreen extends StatefulWidget {
  final String quizTitle;
  const TrueFalseQuizScreen({super.key, required this.quizTitle});

  @override
  State<TrueFalseQuizScreen> createState() => _TrueFalseQuizScreenState();
}

class _TrueFalseQuizScreenState extends State<TrueFalseQuizScreen> {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color timerBlue = Color(0xFF8BAAFF);

  // --- TIMER & PROGRESS STATE ---
  double _progressValue = 1.0;
  int _secondsLeft = 30;
  Timer? _timer;
  bool? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
          _progressValue = _secondsLeft / 30;
        });
      } else {
        _timer?.cancel();
        _finishQuiz();
      }
    });
  }

  void _finishQuiz() {
    // Navigate to Results Screen when time is up or finished
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const QuizResultsScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.quizTitle,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.notifications, color: Colors.white),
          SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          // 1. TOP STATS BAR
          _buildTopStats(),

          // 2. TIMER PROGRESS BAR
          _buildTimerSection(),

          // 3. QUESTION CARD
          _buildQuestionCard(),

          // 4. CHOICE BUTTONS
          _buildChoiceButton("TRUE", Colors.greenAccent.shade100, true),
          _buildChoiceButton("FALSE", Colors.redAccent.shade100, false),

          // 5. LIVE RESPONSE WAITING AREA
          _buildWaitingArea(),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildTopStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _StatIconText(Icons.stars_outlined, "15 points"),
          _StatIconText(Icons.description_outlined, "10 questions"),
          _StatIconText(Icons.access_time, "30 seconds"),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_filled, size: 20, color: Colors.black87),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(timerBlue),
                    minHeight: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("$_secondsLeft Seconds left", 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
            )
          ],
        ),
        child: const Center(
          child: Text(
            "A stack follows the First-In, First-Out (FIFO) principle.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26, 
              fontWeight: FontWeight.w600, 
              fontFamily: 'serif',
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String label, Color color, bool value) {
    bool isSelected = _selectedAnswer == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () => setState(() => _selectedAnswer = value),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: isSelected ? 4 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: isSelected ? const BorderSide(color: darkNavy, width: 2.5) : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
              if (isSelected) const Icon(Icons.check_box, color: darkNavy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingArea() {
    return Container(
      height: 130,
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: _selectedAnswer == null 
        ? const Icon(Icons.show_chart, size: 40, color: Colors.black12)
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(strokeWidth: 2, color: darkNavy),
              SizedBox(height: 15),
              Text("Waiting for 5 more students\nto answer...", 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
            ],
          ),
    );
  }
}

// Helper Widget for the Top Stats
class _StatIconText extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StatIconText(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black87),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}