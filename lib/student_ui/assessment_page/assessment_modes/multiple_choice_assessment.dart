import 'dart:async';
import 'package:flutter/material.dart';
// Standardize this import to your project structure
import '../assessment_result.dart';

class MultipleChoiceQuizScreen extends StatefulWidget {
  final String quizTitle;
  const MultipleChoiceQuizScreen({super.key, required this.quizTitle});

  @override
  State<MultipleChoiceQuizScreen> createState() => _MultipleChoiceQuizScreenState();
}

class _MultipleChoiceQuizScreenState extends State<MultipleChoiceQuizScreen> {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color timerBlue = Color(0xFF8BAAFF);

  // --- STATE ---
  int _secondsLeft = 30;
  final int _totalTime = 30;
  double _progressValue = 1.0;
  Timer? _timer;
  String? _selectedOption;
  bool _isNavigating = false;
  
  // Simulated Live Data (Heights for the bars)
  double barA = 0;
  double barB = 0;
  double barC = 0;
  double barD = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Trigger the "Live" bar animation after a short delay to simulate data fetching
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          barA = 40;
          barB = 100;
          barC = 60;
          barD = 25;
        });
      }
    });
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
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('ASSESSMENT', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: const [Icon(Icons.notifications, color: Colors.white), SizedBox(width: 15)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildTimerSection(),
            _buildQuestionCard(),
            
            // OPTIONS GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _optionBtn("A.", "Queue", const Color(0xFF000080))),
                      const SizedBox(width: 15),
                      Expanded(child: _optionBtn("C.", "Linked List", const Color(0xFFE67E22))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _optionBtn("B.", "Stack", const Color(0xFF2ECC71))),
                      const SizedBox(width: 15),
                      Expanded(child: _optionBtn("D.", "Binary Tree", const Color(0xFFC0392B))),
                    ],
                  ),
                ],
              ),
            ),

            // LIVE RESPONSES SECTION
            _buildLiveResponses(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Text(widget.quizTitle, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(Icons.star_border, "40 points"),
              _Stat(Icons.assignment_outlined, "20 questions"),
              _Stat(Icons.access_time, "30 seconds"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(timerBlue),
                    minHeight: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text("$_secondsLeft Seconds left", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: const Text(
        "Which data structure uses LIFO (Last In First Out) order?",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, fontFamily: 'serif'),
      ),
    );
  }

  Widget _optionBtn(String label, String text, Color color) {
    bool isSelected = _selectedOption == label;
    return GestureDetector(
      onTap: () {
        if (_isNavigating) return;
        setState(() => _selectedOption = label);
        // Short delay to let the student see their selection before transitioning
        Future.delayed(const Duration(milliseconds: 600), _navigateToResults);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: color,
              child: Text(label.replaceAll(".", ""), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveResponses() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, size: 20, color: darkNavy),
              SizedBox(width: 10),
              Text("Live Responses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar("A", barA, const Color(0xFF000080)),
              _bar("B", barB, const Color(0xFF2ECC71)),
              _bar("C", barC, const Color(0xFFE67E22)),
              _bar("D", barD, const Color(0xFFC0392B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(String label, double height, Color color) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeOutQuart,
          width: 35,
          height: height,
          decoration: BoxDecoration(
            // FIXED: Using withValues(alpha:) to resolve deprecation warnings
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Stat(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black45), 
        const SizedBox(width: 4), 
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.black45))
      ]
    );
  }
}