import 'dart:async';
import 'package:flutter/material.dart';
import '../assessment_result.dart';

class MultipleChoiceQuizScreen extends StatefulWidget {
  final String quizTitle;
  const MultipleChoiceQuizScreen({super.key, required this.quizTitle});

  @override
  State<MultipleChoiceQuizScreen> createState() => _MultipleChoiceQuizScreenState();
}

class _MultipleChoiceQuizScreenState extends State<MultipleChoiceQuizScreen> with SingleTickerProviderStateMixin {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color errorRed = Color(0xFFC0392B);

  // --- STATE ---
  int _secondsLeft = 30;
  final int _totalTime = 30;
  double _progressValue = 1.0;
  Timer? _timer;
  String? _selectedOption;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
          _progressValue = _secondsLeft / _totalTime;
        });
      } else {
        _timer?.cancel();
        _navigateToResults();
      }
    });
  }

  void _navigateToResults() {
    if (_isNavigating) return;
    if (mounted) {
      _isNavigating = true;
      _timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(quizTitle: widget.quizTitle),
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
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(widget.quizTitle.toUpperCase(), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPulsingTimerProgress(),
          _buildImmersiveHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
              child: Column(
                children: [
                  _buildQuestionCard(),
                  const SizedBox(height: 30),
                  _buildGamifiedOption("A", "Queue", const Color(0xFF3498DB), Icons.layers),
                  _buildGamifiedOption("B", "Stack", const Color(0xFF2ECC71), Icons.align_vertical_bottom),
                  _buildGamifiedOption("C", "Linked List", const Color(0xFFE67E22), Icons.link),
                  _buildGamifiedOption("D", "Binary Tree", const Color(0xFF9B59B6), Icons.account_tree_outlined),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          _buildInteractiveFooter(),
        ],
      ),
    );
  }

  Widget _buildPulsingTimerProgress() {
    return Container(
      height: 8,
      width: double.infinity,
      color: Colors.black.withValues(alpha: 0.05),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _progressValue,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _progressValue < 0.3 ? errorRed : const Color(0xFF4A90E2),
                _progressValue < 0.3 ? errorRed.withValues(alpha: 0.8) : Colors.cyanAccent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImmersiveHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: const BoxDecoration(
        color: darkNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _heroBadge(Icons.auto_awesome, "STAGE 4"),
          _heroBadge(Icons.bolt, "BONUS: 2.5x", isHighlighted: true),
        ],
      ),
    );
  }

  Widget _heroBadge(IconData icon, String text, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? stiGold.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isHighlighted ? stiGold : Colors.white24, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: isHighlighted ? stiGold : Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: isHighlighted ? stiGold : Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
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
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: darkNavy.withValues(alpha: 0.08), blurRadius: 25, offset: const Offset(0, 12))
        ],
      ),
      child: const Text(
        "Which data structure uses LIFO (Last In First Out) order?",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'serif', height: 1.4, color: darkNavy),
      ),
    );
  }

  Widget _buildGamifiedOption(String label, String text, Color color, IconData icon) {
    bool isSelected = _selectedOption == label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          if (_isNavigating) return;
          setState(() => _selectedOption = label);
          Future.delayed(const Duration(milliseconds: 500), _navigateToResults);
        },
        child: AnimatedScale(
          scale: isSelected ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? color : Colors.black.withValues(alpha: 0.08), 
                width: 2.5
              ),
              boxShadow: [
                if (isSelected) 
                  BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8))
                else 
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.25) : color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: isSelected ? Colors.white : color, size: 22),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(text, 
                    style: TextStyle(
                      fontSize: 17, 
                      fontWeight: FontWeight.w800, 
                      color: isSelected ? Colors.white : Colors.black87
                    )
                  ),
                ),
                if (isSelected) 
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.check, color: Colors.green, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, color: _secondsLeft < 10 ? errorRed : darkNavy, size: 20),
              const SizedBox(width: 8),
              Text("$_secondsLeft", 
                style: TextStyle(
                  fontWeight: FontWeight.w900, 
                  fontSize: 16, 
                  color: _secondsLeft < 10 ? errorRed : darkNavy,
                  fontFamily: 'monospace'
                )
              ),
              Text("s", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _secondsLeft < 10 ? errorRed : darkNavy)),
            ],
          ),
          const Text("THINK FAST!", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black26, letterSpacing: 2)),
        ],
      ),
    );
  }
}