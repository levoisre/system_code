import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/quiz_service.dart';
import '../assessment_result.dart';

class IdentificationQuizScreen extends StatefulWidget {
  final int quizId; 
  final String quizTitle;
  
  const IdentificationQuizScreen({
    super.key, 
    required this.quizId, 
    required this.quizTitle
  });

  @override
  State<IdentificationQuizScreen> createState() => _IdentificationQuizScreenState();
}

class _IdentificationQuizScreenState extends State<IdentificationQuizScreen> {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color timerBlue = Color(0xFF8BAAFF);

  // --- LOGIC STATE ---
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _studentSessionAnswers = [];
  List<String> _currentLetterBank = [];

  final TextEditingController _controller = TextEditingController();
  double _progressValue = 1.0;
  int _secondsLeft = 60;
  Timer? _timer;
  bool _isCorrect = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
    _controller.addListener(_checkAnswer);
  }

  Future<void> _loadQuizData() async {
    final data = await QuizService.getQuizDetails(widget.quizId);
    if (mounted) {
      setState(() {
        _questions = data;
        _isLoading = false;
        if (_questions.isNotEmpty) {
          _setupCurrentQuestion();
          _startTimer();
        }
      });
    }
  }

  void _setupCurrentQuestion() {
    _controller.clear();
    _isCorrect = false;
    _secondsLeft = 60; 
    
    String answer = _questions[_currentIndex]['answer'].toString().toUpperCase();
    List<String> letters = answer.replaceAll(' ', '').split('');
    
    List<String> fillers = ["X", "Z", "Y", "Q", "J", "K", "V"];
    letters.addAll(fillers.take(4));
    letters.shuffle();
    
    setState(() => _currentLetterBank = letters);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
          _progressValue = _secondsLeft / 60;
        });
      } else {
        _timer?.cancel();
        _moveToNextQuestion(timedOut: true);
      }
    });
  }

  void _checkAnswer() {
    if (_questions.isEmpty) return;
    String currentAnswer = _questions[_currentIndex]['answer'].toString().toUpperCase();
    if (_controller.text.toUpperCase() == currentAnswer && !_isCorrect) {
      setState(() => _isCorrect = true);
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 1000), _moveToNextQuestion);
    }
  }

  void _moveToNextQuestion({bool timedOut = false}) async {
    if (_isNavigating) return;

    String correctAns = _questions[_currentIndex]['answer'].toString();
    bool correct = _controller.text.toUpperCase() == correctAns.toUpperCase();
    
    if (correct) _score++;

    _studentSessionAnswers.add({
      "question_id": _questions[_currentIndex]['id'],
      "selected_answer": timedOut ? "Timed Out" : _controller.text,
      "is_correct": correct
    });

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isCorrect = false;
      });
      _setupCurrentQuestion();
      _startTimer();
    } else {
      _finalizeQuiz();
    }
  }

  void _finalizeQuiz() async {
    if (_isNavigating) return;
    _isNavigating = true;
    _timer?.cancel();

    // --- FIXED: Using Named Parameters to match updated QuizService ---
    // This triggers the Quicksort algorithm on the backend
    await QuizService.submitQuizResult(
      quizId: widget.quizId, 
      studentName: "Claire Anne", // Should be dynamic based on login
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: darkNavy)));

    final currentQuestion = _questions[_currentIndex];

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
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500), 
          child: Column(
            children: [
              _buildPulsingTimerBar(),
              _buildGameHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      _buildQuestionCard(currentQuestion['text']),
                      const SizedBox(height: 35),
                      _buildAnswerSlots(currentQuestion['answer'].toString().toUpperCase()),
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
        ),
      ),
    );
  }

  Widget _buildPulsingTimerBar() {
    return Container(
      height: 8, width: double.infinity, color: Colors.black12,
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
          _badge(Icons.psychology, "Question ${_currentIndex + 1}/${_questions.length}"),
          _badge(Icons.bolt, "Score: $_score", isGold: true),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String text, {bool isGold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
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

  Widget _buildQuestionCard(String text) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(30),
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

  Widget _buildAnswerSlots(String fullAnswer) {
    String currentText = _controller.text.toUpperCase();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6, runSpacing: 10,
      children: List.generate(fullAnswer.length, (index) {
        String char = fullAnswer[index];
        if (char == ' ') return const SizedBox(width: 15);
        
        int letterIndex = fullAnswer.substring(0, index).replaceAll(' ', '').length;
        String displayChar = "";
        if (currentText.length > letterIndex) {
          displayChar = currentText[letterIndex];
        }

        return Container(
          width: 22, height: 35,
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: darkNavy, width: 2.5))),
          child: Center(
            child: Text(displayChar, style: const TextStyle(fontWeight: FontWeight.w900, color: darkNavy, fontSize: 18)),
          ),
        );
      }),
    );
  }

  Widget _buildInteractiveInput() {
    return Container(
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.withAlpha(25) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10)],
      ),
      child: TextField(
        controller: _controller,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: darkNavy),
        decoration: InputDecoration(
          hintText: "TAP LETTERS OR TYPE",
          hintStyle: TextStyle(fontSize: 12, color: Colors.black.withAlpha(75), letterSpacing: 1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.keyboard_alt_outlined, color: darkNavy, size: 18),
          suffixIcon: _isCorrect 
            ? const Icon(Icons.check_circle, color: Colors.green) 
            : IconButton(
                icon: const Icon(Icons.backspace_outlined, size: 18, color: Colors.redAccent),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    setState(() {
                      _controller.text = _controller.text.substring(0, _controller.text.length - 1);
                    });
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
          spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
          children: _currentLetterBank.map((letter) => _buildLetterTile(letter)).toList(),
        ),
      ],
    );
  }

  Widget _buildLetterTile(String letter) {
    return GestureDetector(
      onTap: () {
        String answer = _questions[_currentIndex]['answer'].toString();
        if (!_isCorrect && _controller.text.length < answer.replaceAll(' ', '').length) {
          setState(() {
            _controller.text += letter;
          });
        }
      },
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15),
          border: Border.all(color: darkNavy.withAlpha(25), width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Text(letter, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkNavy)),
        ),
      ),
    );
  }
}