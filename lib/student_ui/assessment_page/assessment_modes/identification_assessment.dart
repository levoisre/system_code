import 'dart:async';
import 'package:flutter/material.dart';
// Ensure this path matches your results screen exactly
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/assessment_result.dart';

class IdentificationQuizScreen extends StatefulWidget {
  final String quizTitle;
  const IdentificationQuizScreen({super.key, required this.quizTitle});

  @override
  State<IdentificationQuizScreen> createState() => _IdentificationQuizScreenState();
}

class _IdentificationQuizScreenState extends State<IdentificationQuizScreen> {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color timerBlue = Color(0xFF8BAAFF);

  final TextEditingController _controller = TextEditingController();
  double _progressValue = 1.0;
  int _secondsLeft = 60;
  Timer? _timer;
  bool _isCorrect = false;

  final String correctAnswer = "BREADTH FIRST SEARCH";
  
  // Scrambled bank with required letters + fillers
  final List<String> letterBank = ["B", "R", "E", "A", "D", "T", "H", "F", "I", "S", "C", "H", "U", "N"];

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
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 1000), _navigateToResults);
    }
  }

  void _navigateToResults() {
    if (mounted) {
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
    _controller.dispose();
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
        title: Text(widget.quizTitle.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPulsingTimerBar(),
          _buildGameHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  _buildQuestionCard(),
                  const SizedBox(height: 35),
                  _buildAnswerSlots(),
                  const SizedBox(height: 35),
                  _buildInteractiveInput(),
                  const SizedBox(height: 30),
                  _buildLetterBank(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingTimerBar() {
    return Container(
      height: 8,
      width: double.infinity,
      color: Colors.black12,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _progressValue,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_secondsLeft < 15 ? Colors.red : timerBlue, Colors.cyanAccent],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: darkNavy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _badge(Icons.psychology, "Level: Hard"),
          _badge(Icons.bolt, "Earn 100 XP", isGold: true),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String text, {bool isGold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1), // Updated withValues
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: isGold ? stiGold : Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Updated withValues
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: const Text(
        "An algorithm that explores all nodes at the present depth level before moving deeper.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'serif', height: 1.4, color: darkNavy),
      ),
    );
  }

  Widget _buildAnswerSlots() {
    String currentText = _controller.text.toUpperCase();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 10,
      children: List.generate(correctAnswer.length, (index) {
        String char = correctAnswer[index];
        if (char == ' ') return const SizedBox(width: 15);
        
        String displayChar = "";
        int letterIndex = correctAnswer.substring(0, index).replaceAll(' ', '').length;
        if (currentText.length > letterIndex) {
          displayChar = currentText[letterIndex];
        }

        return Container(
          width: 22,
          height: 35,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: darkNavy, width: 2.5)),
          ),
          child: Center(
            child: Text(
              displayChar,
              style: const TextStyle(fontWeight: FontWeight.w900, color: darkNavy, fontSize: 18),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInteractiveInput() {
    return Container(
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.withValues(alpha: 0.1) : Colors.white, // Updated withValues
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)], // Updated withValues
      ),
      child: TextField(
        controller: _controller,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: darkNavy),
        decoration: InputDecoration(
          hintText: "TAP LETTERS OR TYPE",
          hintStyle: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.3), letterSpacing: 1), // Updated withValues
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.keyboard_alt_outlined, color: darkNavy, size: 18),
          suffixIcon: _isCorrect 
            ? const Icon(Icons.check_circle, color: Colors.green) 
            : IconButton(
                icon: const Icon(Icons.backspace_outlined, size: 18, color: Colors.redAccent),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    _controller.text = _controller.text.substring(0, _controller.text.length - 1);
                  }
                },
              ),
        ),
      ),
    );
  }

  Widget _buildLetterBank() {
    return Column(
      children: [
        const Text("LETTER BANK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black38, letterSpacing: 2)),
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: letterBank.map((letter) => _buildLetterTile(letter)).toList(),
        ),
      ],
    );
  }

  Widget _buildLetterTile(String letter) {
    return GestureDetector(
      onTap: () {
        if (!_isCorrect && _controller.text.length < correctAnswer.replaceAll(' ', '').length) {
          setState(() {
            _controller.text += letter;
          });
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: darkNavy.withValues(alpha: 0.1), width: 2), // Updated withValues
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), // Updated withValues
              blurRadius: 8, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Center(
          child: Text(letter, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkNavy)),
        ),
      ),
    );
  }
}