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
  static const Color accentGold = Color(0xFFFFD100);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color errorRed = Color(0xFFC0392B);

  // --- STATE ---
  double _progressValue = 1.0;
  int _secondsLeft = 30;
  Timer? _timer;
  bool? _selectedAnswer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.quizTitle.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTimerBar(),
          _buildQuestionHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuestionCard(),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: _buildGamifiedChoice(true)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildGamifiedChoice(false)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildBottomStatus(),
        ],
      ),
    );
  }

  Widget _buildTimerBar() {
    return Container(
      height: 6,
      width: double.infinity,
      color: Colors.black12,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _progressValue,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_progressValue < 0.3 ? errorRed : successGreen, Colors.greenAccent]),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: darkNavy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _badge(Icons.help_center_outlined, "Question 4/10"),
          _badge(Icons.bolt, "250 XP"),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: accentGold, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: const Text(
        "A stack follows the First-In, First-Out (FIFO) principle.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'serif', height: 1.4, color: darkNavy),
      ),
    );
  }

  Widget _buildGamifiedChoice(bool isTrue) {
    bool isSelected = _selectedAnswer == isTrue;
    Color baseColor = isTrue ? successGreen : errorRed;

    return GestureDetector(
      onTap: () {
        if (_isNavigating) return;
        setState(() => _selectedAnswer = isTrue);
        Future.delayed(const Duration(milliseconds: 600), _finishQuiz);
      },
      child: AnimatedScale(
        scale: isSelected ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: isSelected ? baseColor : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isSelected ? baseColor : Colors.black12, width: 3),
            boxShadow: [
              if (isSelected) BoxShadow(color: baseColor.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8))
              else BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isTrue ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 60,
                color: isSelected ? Colors.white : baseColor,
              ),
              const SizedBox(height: 15),
              Text(
                isTrue ? "TRUE" : "FALSE",
                style: TextStyle(
                  color: isSelected ? Colors.white : darkNavy,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _secondsLeft < 10 ? errorRed.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
            child: Text("$_secondsLeft", style: TextStyle(fontWeight: FontWeight.w900, color: _secondsLeft < 10 ? errorRed : Colors.blue)),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              "Select the correct principle to earn maximum points!",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}