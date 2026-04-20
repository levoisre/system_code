import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/quiz_service.dart';
import '../assessment_result.dart';

class MultipleChoiceQuizScreen extends StatefulWidget {
  final int quizId; 
  final String quizTitle;
  
  const MultipleChoiceQuizScreen({
    super.key, 
    required this.quizId, 
    required this.quizTitle
  });

  @override
  State<MultipleChoiceQuizScreen> createState() => _MultipleChoiceQuizScreenState();
}

class _MultipleChoiceQuizScreenState extends State<MultipleChoiceQuizScreen> {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color errorRed = Color(0xFFC0392B);

  final List<Map<String, dynamic>> _studentSessionAnswers = [];
  List<Map<String, dynamic>> _questions = [];
  
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;

  int _secondsLeft = 30;
  final int _totalTime = 30;
  double _progressValue = 1.0;
  Timer? _timer;
  String? _selectedOption;
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
    _secondsLeft = _totalTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
          _progressValue = _secondsLeft / _totalTime;
        });
      } else {
        _timer?.cancel();
        _handleAnswerSelection(null); 
      }
    });
  }

  void _handleAnswerSelection(String? option) async {
    if (_isNavigating || _selectedOption != null) return;

    String correctAnswer = _questions[_currentIndex]['answer'].toString();
    bool isCorrect = option != null && option.trim() == correctAnswer.trim();
    
    if (isCorrect) _score++;

    _studentSessionAnswers.add({
      "question_id": _questions[_currentIndex]['id'],
      "selected_answer": option ?? "Timed Out",
      "is_correct": isCorrect
    });

    setState(() => _selectedOption = option);

    _timer?.cancel();
    await Future.delayed(const Duration(milliseconds: 600));

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
      _startTimer();
    } else {
      _finalizeQuiz();
    }
  }

  void _finalizeQuiz() async {
    if (_isNavigating) return;
    _isNavigating = true;
    _timer?.cancel();

    // BACKEND SYNC: Triggers Quicksort logic
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
          ),
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
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: darkNavy)));

    final currentQuestion = _questions[_currentIndex];
    final List<dynamic> options = currentQuestion['options'] ?? [];

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  _buildQuestionCard(currentQuestion['text']),
                  const SizedBox(height: 30),
                  ...List.generate(options.length, (index) {
                    return _buildGamifiedOption(
                      options[index].toString(), 
                      options[index].toString(), 
                      _getOptionColor(index), 
                      _getOptionIcon(index)
                    );
                  }),
                ],
              ),
            ),
          ),
          _buildInteractiveFooter(),
        ],
      ),
    );
  }

  Color _getOptionColor(int index) {
    List<Color> colors = [const Color(0xFF3498DB), const Color(0xFF2ECC71), const Color(0xFFE67E22), const Color(0xFF9B59B6)];
    return colors[index % colors.length];
  }

  IconData _getOptionIcon(int index) {
    List<IconData> icons = [Icons.layers, Icons.account_tree_outlined, Icons.link, Icons.code];
    return icons[index % icons.length];
  }

  Widget _buildPulsingTimerProgress() {
    return Container(
      height: 8, width: double.infinity, color: Colors.black12,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _progressValue,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _progressValue < 0.3 ? errorRed : const Color(0xFF4A90E2),
                _progressValue < 0.3 ? errorRed : Colors.cyanAccent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImmersiveHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      color: darkNavy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _heroBadge(Icons.quiz_outlined, "ITEM ${_currentIndex + 1}/${_questions.length}"),
          _heroBadge(Icons.stars, "SCORE: $_score", isHighlighted: true),
        ],
      ),
    );
  }

  Widget _heroBadge(IconData icon, String text, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted ? stiGold.withAlpha(40) : Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isHighlighted ? stiGold : Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: isHighlighted ? stiGold : Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: isHighlighted ? stiGold : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 20)],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkNavy),
      ),
    );
  }

  Widget _buildGamifiedOption(String value, String text, Color color, IconData icon) {
    bool isSelected = _selectedOption == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _handleAnswerSelection(value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : Colors.black12, width: 2),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isSelected ? Colors.white.withAlpha(50) : color.withAlpha(30),
                child: Icon(icon, color: isSelected ? Colors.white : color, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(text, 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.timer_sharp, color: _secondsLeft < 10 ? errorRed : darkNavy),
              const SizedBox(width: 8),
              Text("$_secondsLeft", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _secondsLeft < 10 ? errorRed : darkNavy)),
              const Text(" s", style: TextStyle(color: Colors.black26, fontSize: 18)),
            ],
          ),
          const Text("THINK FAST!", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black12, letterSpacing: 2)),
        ],
      ),
    );
  }
}