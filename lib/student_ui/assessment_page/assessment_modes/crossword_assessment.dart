import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/quiz_service.dart';
import '../assessment_result.dart';

class CrosswordAssessment extends StatefulWidget {
  final int quizId;
  final String quizTitle;

  const CrosswordAssessment({
    super.key, 
    required this.quizId, 
    required this.quizTitle
  });

  @override
  State<CrosswordAssessment> createState() => _CrosswordAssessmentState();
}

class _CrosswordAssessmentState extends State<CrosswordAssessment> {
  static const Color darkNavy = Color(0xFF0C1446);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color accentBlue = Color(0xFF4A90E2);

  final int gridSize = 10;
  // gridData stores the CORRECT letters to check against
  late List<List<String>> gridData; 
  late List<List<TextEditingController>> controllers;
  late List<List<FocusNode>> focusNodes;

  bool _isLoading = true;
  bool hasSubmitted = false;
  List<Map<String, dynamic>> wordsData = [];
  
  int activeRow = -1;
  int activeCol = -1;

  @override
  void initState() {
    super.initState();
    _setupGrid();
    _loadCrosswordData();
  }

  void _setupGrid() {
    gridData = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
    controllers = List.generate(gridSize, (_) => List.generate(gridSize, (_) => TextEditingController()));
    focusNodes = List.generate(gridSize, (_) => List.generate(gridSize, (_) => FocusNode()));
  }

  Future<void> _loadCrosswordData() async {
    final data = await QuizService.getQuizDetails(widget.quizId);
    if (mounted) {
      setState(() {
        wordsData = data;
        _placeWords(); // This maps the database row/col to our UI grid
        _isLoading = false;
      });
    }
  }

  void _placeWords() {
    for (var item in wordsData) {
      String word = item['answer'].toString().toUpperCase();
      // Ensure we use the exact keys from the QuizService mapping
      int rStart = item['row'] ?? 0;
      int cStart = item['col'] ?? 0;
      String dir = item['dir'] ?? "H";

      for (int i = 0; i < word.length; i++) {
        int r = (dir == "H") ? rStart : rStart + i;
        int c = (dir == "H") ? cStart + i : cStart;
        
        if (r < gridSize && c < gridSize) {
          gridData[r][c] = word[i]; // Marks this cell as 'playable'
        }
      }
    }
  }

  void _handleSubmit() async {
    int currentScore = 0;
    int totalCells = 0;

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (gridData[r][c].isNotEmpty) {
          totalCells++;
          String userChar = controllers[r][c].text.trim().toUpperCase();
          if (userChar == gridData[r][c]) {
            currentScore++;
          }
        }
      }
    }

    setState(() => hasSubmitted = true);

    // Sync with Quicksort Leaderboard
    await QuizService.submitQuizResult(
      quizId: widget.quizId, 
      studentName: "Claire Anne", 
      score: currentScore, 
      totalQuestions: totalCells, 
      quizTitle: widget.quizTitle,
      answers: [], 
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            quizId: widget.quizId,
            quizTitle: widget.quizTitle,
            score: currentScore,
            totalQuestions: totalCells,
            studentAnswers: [], 
          ),
        ),
      );
    }
  }

  void _moveFocus(int r, int c) {
    // Basic auto-advance logic
    if (c + 1 < gridSize && gridData[r][c + 1].isNotEmpty) {
      focusNodes[r][c + 1].requestFocus();
      setState(() { activeRow = r; activeCol = c + 1; });
    } else if (r + 1 < gridSize && gridData[r + 1][c].isNotEmpty) {
      focusNodes[r + 1][c].requestFocus();
      setState(() { activeRow = r + 1; activeCol = c; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: darkNavy)));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        title: Text(widget.quizTitle.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
      ),
      body: Column(
        children: [
          _buildGameHeader(),
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.8,
              maxScale: 2.0,
              child: _buildPlayableBoard(),
            ),
          ),
          _buildClueSection(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: darkNavy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _badge(Icons.grid_on, "$gridSize x $gridSize"),
          _badge(Icons.lightbulb_outline, "${wordsData.length} Clues"),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: stiGold, size: 16),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildPlayableBoard() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        width: 350, height: 350,
        color: darkNavy.withAlpha(200),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: gridSize * gridSize,
          itemBuilder: (context, index) {
            int r = index ~/ gridSize;
            int c = index % gridSize;
            if (gridData[r][c].isEmpty) {
              return Container(color: Colors.black);
            }
            return _buildInputCell(r, c);
          },
        ),
      ),
    );
  }

  Widget _buildInputCell(int r, int c) {
    bool isActive = activeRow == r && activeCol == c;
    return Container(
      color: isActive ? stiGold : Colors.white,
      child: TextField(
        controller: controllers[r][c],
        focusNode: focusNodes[r][c],
        textAlign: TextAlign.center,
        maxLength: 1,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : darkNavy,
        ),
        decoration: const InputDecoration(counterText: "", border: InputBorder.none),
        onTap: () => setState(() { activeRow = r; activeCol = c; }),
        onChanged: (val) {
          if (val.isNotEmpty) _moveFocus(r, c);
        },
      ),
    );
  }

  Widget _buildClueSection() {
    return Container(
      height: 120,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(15),
        itemCount: wordsData.length,
        itemBuilder: (context, index) {
          var w = wordsData[index];
          return GestureDetector(
            onTap: () {
              focusNodes[w['row']][w['col']].requestFocus();
              setState(() { activeRow = w['row']; activeCol = w['col']; });
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: darkNavy.withAlpha(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w['dir'] == "H" ? "ACROSS" : "DOWN", 
                       style: const TextStyle(fontSize: 10, color: accentBlue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(w['text'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: hasSubmitted ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkNavy,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("SUBMIT PUZZLE", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  void dispose() {
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}