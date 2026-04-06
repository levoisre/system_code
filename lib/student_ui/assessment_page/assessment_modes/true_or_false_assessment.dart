import 'dart:async';
import 'package:flutter/material.dart';
import '../assessment_result.dart';

class TrueFalseQuizScreen extends StatefulWidget {
  final String quizTitle;
  const TrueFalseQuizScreen({super.key, required this.quizTitle});

  @override
  State<TrueFalseQuizScreen> createState() => _TrueFalseQuizScreenState();
}

class _TrueFalseQuizScreenState extends State<TrueFalseQuizScreen> {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color timerBlue = Color(0xFF8BAAFF);

  // --- STATE ---
  double _progressValue = 1.0;
  int _secondsLeft = 30;
  Timer? _timer;
  bool? _selectedAnswer;
  bool _isNavigating = false;

  // Heights for the "Live" bars
  double barTrue = 0;
  double barFalse = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Simulate the bars growing after a short delay, exactly like Multiple Choice
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          barTrue = 100;  // Simulated height
          barFalse = 45;  // Simulated height
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
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
    if (_isNavigating) return;
    if (mounted) {
      _isNavigating = true;
      _timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(quizTitle: widget.quizTitle)
        ),
      );
    }
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
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _buildTopStats(),
                    _buildTimerSection(),
                    
                    Flexible(child: _buildQuestionCard()),

                    _buildChoiceButton("TRUE", Colors.greenAccent.shade100, true),
                    _buildChoiceButton("FALSE", Colors.redAccent.shade100, false),

                    // --- UPDATED LIVE RESPONSES SECTION ---
                    _buildLiveResponses(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Identical to Multiple Choice styling
  Widget _buildLiveResponses() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, size: 20, color: darkNavy),
              SizedBox(width: 10),
              Text("Live Responses", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar("TRUE", barTrue, const Color(0xFF2ECC71)), // Green for True
              _bar("FALSE", barFalse, const Color(0xFFC0392B)), // Red for False
            ],
          ),
        ],
      ),
    );
  }

  // This is the specific Bar widget from your Multiple Choice code
  Widget _bar(String label, double height, Color color) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeOutQuart,
          width: 45, // Slightly wider for True/False labels
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9), 
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3), 
                blurRadius: 4, 
                offset: const Offset(0, 2)
              )
            ]
          ),
        ),
        const SizedBox(height: 8),
        Text(label, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  // ... (Remainder of UI Helper methods like _buildTopStats, _buildTimerSection, etc. stay the same)

  Widget _buildTopStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatIconText(Icons.stars_outlined, "15 pts"),
          _StatIconText(Icons.description_outlined, "10 qs"),
          _StatIconText(Icons.access_time, "30s"),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_filled, size: 18, color: Colors.black87),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(timerBlue),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text("$_secondsLeft Seconds left", 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: const Center(
        child: Text(
          "A stack follows the First-In, First-Out (FIFO) principle.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'serif', height: 1.2),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String label, Color color, bool value) {
    bool isSelected = _selectedAnswer == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
      child: SizedBox(
        width: double.infinity,
        height: 45, 
        child: ElevatedButton(
          onPressed: () {
            if (_isNavigating) return;
            setState(() => _selectedAnswer = value);
            Future.delayed(const Duration(milliseconds: 600), _finishQuiz);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: isSelected ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected ? const BorderSide(color: darkNavy, width: 2) : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)),
              if (isSelected) const Icon(Icons.check_circle, color: darkNavy, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatIconText extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StatIconText(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black54),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}