import 'dart:async';
import 'package:flutter/material.dart';
// Ensure this matches your file path exactly
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/assessment_result.dart';

class IdentificationQuizScreen extends StatefulWidget {
  final String quizTitle;
  const IdentificationQuizScreen({super.key, required this.quizTitle});

  @override
  State<IdentificationQuizScreen> createState() => _IdentificationQuizScreenState();
}

class _IdentificationQuizScreenState extends State<IdentificationQuizScreen> {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color timerBlue = Color(0xFF8BAAFF);

  final TextEditingController _controller = TextEditingController();
  double _progressValue = 1.0;
  int _secondsLeft = 60; 
  Timer? _timer;
  bool _isCorrect = false;

  final String correctAnswer = "BREADTH FIRST SEARCH";

  @override
  void initState() {
    super.initState();
    _startTimer();
    _controller.addListener(_checkAnswer);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
          _progressValue = _secondsLeft / 60;
        });
      } else {
        _timer?.cancel();
        _navigateToResults();
      }
    });
  }

  void _checkAnswer() {
    if (_controller.text.toUpperCase() == correctAnswer) {
      setState(() => _isCorrect = true);
      Future.delayed(const Duration(milliseconds: 800), _navigateToResults);
    }
  }

  void _navigateToResults() {
    if (mounted) {
      _timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            quizTitle: widget.quizTitle, 
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
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
            _buildLetterGrid(),
            _buildInputArea(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      color: Colors.white,
      child: Column(
        children: [
          Text(widget.quizTitle, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'serif')),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // FIXED: Changed Icon and removed the 'const' from the list children
              _Stat(Icons.star_border, "30 points"),
              _Stat(Icons.assignment_outlined, "20 questions"),
              _Stat(Icons.access_time, "1 minute"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
          const SizedBox(height: 8),
          Text("$_secondsLeft Second", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "An algorithm that explores all nodes at the present depth level before moving deeper",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, fontFamily: 'serif', height: 1.4),
      ),
    );
  }

  Widget _buildLetterGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tileGroup("RB_H_E_D_A_T"),
              const SizedBox(width: 15),
              _tileGroup("T_R_F_S_I"),
            ],
          ),
          const SizedBox(height: 10),
          _tileGroup("E_R_S_A_H_C"),
        ],
      ),
    );
  }

  Widget _tileGroup(String letters) {
    List<String> list = letters.split('');
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black45, width: 0.5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: list.map((char) {
          if (char == "_") return Container(width: 1, height: 25, color: Colors.black45);
          return Container(
            width: 25, height: 25, alignment: Alignment.center,
            child: Text(char, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: _isCorrect ? const Color(0xFFD4EDDA) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _isCorrect ? Colors.green : Colors.black26, width: 1.5),
        ),
        child: TextField(
          controller: _controller,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: "Type Answer",
            border: InputBorder.none,
            suffixIcon: _isCorrect ? const Icon(Icons.check_box, color: Colors.green) : null,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    );
  }
}

// --- UPDATED STAT HELPER ---
class _Stat extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Stat(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}