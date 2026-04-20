import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/quiz_service.dart';
import '../assessment_result.dart';

class TrueFalseQuizScreen extends StatefulWidget {
  final int quizId; 
  final String quizTitle;
  
  const TrueFalseQuizScreen({
    super.key, 
    required this.quizId, 
    required this.quizTitle
  });

  @override
  State<TrueFalseQuizScreen> createState() => _TrueFalseQuizScreenState();
}

class _TrueFalseQuizScreenState extends State<TrueFalseQuizScreen> {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color accentGold = Color(0xFFFFD100);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color errorRed = Color(0xFFC0392B);

  // --- LOGIC STATE ---
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  final List<Map<String, dynamic>> _studentSessionAnswers = [];

  // --- TIMER STATE ---
  double _progressValue = 1.0;
  int _secondsLeft = 30;
  final int _totalTimePerQuestion = 30; 
  Timer? _timer;
  bool? _selectedAnswer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    final data = await QuizService.getQuizDetails(widget.quizId);
    if (mounted) {
      setState(() {
        _questions = data;
        _isLoading = false;
        if (_questions.isNotEmpty) _startTimer();
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _totalTimePerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
          _progressValue = _secondsLeft / _totalTimePerQuestion;
        });
      } else {
        _timer?.cancel();
        _handleAnswer(null); 
      }
    });
  }

  void _handleAnswer(bool? answer) async {
    if (_isNavigating || _selectedAnswer != null) return;

    String correctAnswer = _questions[_currentIndex]['answer'].toString();
    // Handles case-insensitive comparison (e.g., "True" vs "true")
    bool isCorrect = answer != null && answer.toString().toLowerCase() == correctAnswer.toLowerCase();
    
    if (isCorrect) _score++;

    _studentSessionAnswers.add({
      "question_id": _questions[_currentIndex]['id'],
      "selected_answer": answer == null ? "Timed Out" : (answer ? "True" : "False"),
      "is_correct": isCorrect
    });

    setState(() => _selectedAnswer = answer);

    _timer?.cancel();
    // Short delay so the student sees their choice highlighted
    await Future.delayed(const Duration(milliseconds: 600));

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
      });
      _startTimer();
    } else {
      _submitAndFinish();
    }
  }

  void _submitAndFinish() async {
    if (_isNavigating) return;
    _isNavigating = true;
    _timer?.cancel();
    
    // API SYNC: Sends data to Node.js backend for Quicksort processing
    await QuizService.submitQuizResult(
      quizId: widget.quizId, 
      studentName: "Claire Anne", 
      score: _score,
      totalQuestions: _questions.length,
      answers: _studentSessionAnswers,
      quizTitle: widget.quizTitle,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            quizId: widget.quizId,
            quizTitle: widget.quizTitle,
            score: _score,
            totalQuestions: _questions.length,
            studentAnswers: _studentSessionAnswers,
          )
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: darkNavy)));
    }

    final currentQuestion = _questions[_currentIndex];

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
                  _buildQuestionCard(currentQuestion['text']),
                  const SizedBox(height: 40),
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

  // --- UI COMPONENTS ---

  Widget _buildTimerBar() {
    return Container(
      height: 6, width: double.infinity, color: Colors.black12,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _progressValue,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_secondsLeft < 10 ? errorRed : successGreen, Colors.greenAccent]
            ),
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
          _badge(Icons.help_center_outlined, "Item ${_currentIndex + 1}/${_questions.length}"),
          _badge(Icons.stars_rounded, "Score: $_score"),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25), 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        children: [
          Icon(icon, color: accentGold, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'serif', height: 1.4, color: darkNavy),
      ),
    );
  }

  Widget _buildGamifiedChoice(bool isTrue) {
    bool isSelected = _selectedAnswer == isTrue;
    Color baseColor = isTrue ? successGreen : errorRed;

    return GestureDetector(
      onTap: () => _handleAnswer(isTrue),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: isSelected ? baseColor : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? baseColor : Colors.black12, width: 3),
          boxShadow: isSelected ? [BoxShadow(color: baseColor.withAlpha(50), blurRadius: 15)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTrue ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 50, color: isSelected ? Colors.white : baseColor,
            ),
            const SizedBox(height: 10),
            Text(isTrue ? "TRUE" : "FALSE",
              style: TextStyle(
                color: isSelected ? Colors.white : darkNavy, 
                fontWeight: FontWeight.w900, 
                fontSize: 16, 
                letterSpacing: 1.5
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStatus() {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 25, 30, 40),
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _secondsLeft < 10 ? errorRed.withAlpha(30) : Colors.blue.withAlpha(30),
            child: Text("$_secondsLeft", 
              style: TextStyle(fontWeight: FontWeight.w900, color: _secondsLeft < 10 ? errorRed : Colors.blue)),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Text("Double check your logic! Once you select True or False, the system moves to the next item.", 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}