import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/quiz_service.dart';

class AssessmentReviewScreen extends StatefulWidget {
  final int quizId;
  final String quizTitle;
  final List<Map<String, dynamic>> studentAnswers;
  final int totalScore;

  const AssessmentReviewScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.studentAnswers,
    required this.totalScore,
  });

  @override
  State<AssessmentReviewScreen> createState() => _AssessmentReviewScreenState();
}

class _AssessmentReviewScreenState extends State<AssessmentReviewScreen> {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color stiGold = Color(0xFFFFD100);

  List<Map<String, dynamic>> _answerKey = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviewData();
  }

  Future<void> _loadReviewData() async {
    // Fetches the full question data from the backend to compare against student input
    final data = await QuizService.getQuizDetails(widget.quizId);
    if (mounted) {
      setState(() {
        _answerKey = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        title: const Text("ASSESSMENT REVIEW", 
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: darkNavy))
          : Column(
              children: [
                _buildSummaryHeader(),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    itemCount: _answerKey.length,
                    itemBuilder: (context, index) {
                      final question = _answerKey[index];
                      
                      // Match student answer to question ID accurately
                      final studentAnsEntry = widget.studentAnswers.firstWhere(
                        (ans) => ans['question_id'] == question['id'],
                        orElse: () => {"selected_answer": "No Answer"},
                      );

                      final String studentAns = studentAnsEntry['selected_answer'].toString();
                      final String correctAns = question['answer'] ?? question['correct_answer'] ?? "N/A";
                      
                      // Handles "Data Structures" style verification (Case & Trim)
                      final bool isCorrect = studentAns.toLowerCase().trim() == correctAns.toLowerCase().trim();
                      final bool isTimedOut = studentAns == "Timed Out" || studentAns == "No Answer";

                      return _buildReviewCard(index, question, studentAns, correctAns, isCorrect, isTimedOut);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader() {
    double percentage = (_answerKey.isEmpty) ? 0 : (widget.totalScore / _answerKey.length) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: darkNavy,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
            child: Text(widget.quizTitle.toUpperCase(), 
                style: const TextStyle(color: stiGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 15),
          Text("${widget.totalScore} / ${_answerKey.length}", 
              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
          Text("${percentage.toStringAsFixed(0)}% ACCURACY", 
              style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(int index, Map<String, dynamic> question, String studentAns, String correctAns, bool isCorrect, bool isTimedOut) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              color: isTimedOut ? Colors.orange.withAlpha(20) : (isCorrect ? Colors.green.withAlpha(20) : Colors.red.withAlpha(20)),
              child: Row(
                children: [
                  Icon(
                    isTimedOut ? Icons.timer_off : (isCorrect ? Icons.check_circle : Icons.cancel), 
                    color: isTimedOut ? Colors.orange : (isCorrect ? Colors.green : Colors.red), 
                    size: 14
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTimedOut ? "TIMED OUT" : (isCorrect ? "CORRECT" : "INCORRECT"), 
                    style: TextStyle(
                      fontWeight: FontWeight.w900, 
                      fontSize: 10, 
                      color: isTimedOut ? Colors.orange : (isCorrect ? Colors.green : Colors.red)
                    )
                  ),
                  const Spacer(),
                  Text("Q${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black12, fontSize: 12)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['text'] ?? question['question_text'] ?? "Loading...", 
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkNavy, height: 1.4)
                  ),
                  const SizedBox(height: 20),
                  _answerRow("Your Answer", studentAns, isCorrect ? Colors.green : Colors.red),
                  if (!isCorrect) ...[
                    const SizedBox(height: 10),
                    _answerRow("Correct Answer", correctAns, Colors.green),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor)),
        ),
      ],
    );
  }
}