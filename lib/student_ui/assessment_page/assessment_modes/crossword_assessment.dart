import 'package:flutter/material.dart';

class CrosswordAssessment extends StatefulWidget {
  const CrosswordAssessment({super.key});

  @override
  State<CrosswordAssessment> createState() => _CrosswordAssessmentState();
}

class _CrosswordAssessmentState extends State<CrosswordAssessment> {
  // 1. CONFIGURATION
  final int gridSize = 10;
  late List<List<String>> gridData;
  late List<List<TextEditingController>> controllers;
  
  bool hasSubmitted = false;
  bool showSuccessOverlay = false;
  int score = 0;

  static const Color navy = Color(0xFF0C1446);
  static const Color cellBg = Color(0xFF2D3E50);

  // 2. MOCK DATA
  final List<Map<String, dynamic>> wordsData = [
    {"word": "STACK", "clue": "LIFO Data Structure", "row": 2, "col": 1, "dir": "H"},
    {"word": "QUICKSORT", "clue": "Efficient sorting algorithm", "row": 0, "col": 4, "dir": "V"},
    {"word": "ARRAY", "clue": "Fixed-size collection of items", "row": 5, "col": 2, "dir": "H"},
    {"word": "NODE", "clue": "Element in a linked list", "row": 8, "col": 5, "dir": "H"},
  ];

  @override
  void initState() {
    super.initState();
    _setupGrid();
    _placeWords();
  }

  void _setupGrid() {
    gridData = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
    controllers = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => TextEditingController()),
    );
  }

  void _placeWords() {
    for (var item in wordsData) {
      String word = item['word'];
      int rStart = item['row'];
      int cStart = item['col'];
      String dir = item['dir'];

      for (int i = 0; i < word.length; i++) {
        int r = (dir == "H") ? rStart : rStart + i;
        int c = (dir == "H") ? cStart + i : cStart;

        if (r >= 0 && r < gridSize && c >= 0 && c < gridSize) {
          gridData[r][c] = word[i];
        } else {
          break; 
        }
      }
    }
  }

  void _handleSubmit() {
    int currentScore = 0;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (gridData[r][c].isNotEmpty) {
          if (controllers[r][c].text.toUpperCase() == gridData[r][c]) {
            currentScore++;
          }
        }
      }
    }

    setState(() {
      score = currentScore;
      hasSubmitted = true; 
      showSuccessOverlay = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('CROSSWORD ASSESSMENT', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'serif')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: hasSubmitted ? null : _handleSubmit,
        backgroundColor: hasSubmitted ? Colors.grey : navy,
        label: Text(hasSubmitted ? "SUBMITTED" : "SUBMIT", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ),
      body: Stack(
        children: [
          _buildMainGrid(),
          if (showSuccessOverlay) _buildResultOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainGrid() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildTimerHeader(),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
                  ],
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    childAspectRatio: 1.0, 
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    int r = index ~/ gridSize;
                    int c = index % gridSize;
                    if (gridData[r][c].isEmpty) return Container(color: cellBg);
                    return _buildInputCell(r, c);
                  },
                ),
              ),
            ),
          ),
        ),
        _buildClueSection(),
      ],
    );
  }

  Widget _buildInputCell(int r, int c) {
    Color textColor = Colors.black87;
    if (hasSubmitted) {
      bool isCorrect = controllers[r][c].text.toUpperCase() == gridData[r][c];
      textColor = isCorrect ? Colors.green : Colors.red;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border.all(
          color: hasSubmitted ? textColor.withValues(alpha: 0.5) : Colors.black12, 
          width: hasSubmitted ? 2 : 1
        )
      ),
      child: TextField(
        controller: controllers[r][c],
        enabled: !hasSubmitted,
        textAlign: TextAlign.center,
        maxLength: 1,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
        decoration: const InputDecoration(counterText: "", border: InputBorder.none, contentPadding: EdgeInsets.zero),
        onChanged: (val) {
          if (val.isNotEmpty) FocusScope.of(context).nextFocus();
        },
      ),
    );
  }

  Widget _buildResultOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 70),
              const SizedBox(height: 15),
              const Text("SCORE REPORT", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Score: $score Correct Cells", style: const TextStyle(fontSize: 17)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => setState(() => showSuccessOverlay = false),
                style: ElevatedButton.styleFrom(backgroundColor: navy, minimumSize: const Size(220, 45)),
                child: const Text("REVIEW ANSWERS", style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("EXIT TO MENU", style: TextStyle(color: Colors.black54)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: hasSubmitted ? Colors.grey : Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Text(hasSubmitted ? "FINISHED" : "29:45", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildClueSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CLUES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: navy)),
          const Divider(),
          SizedBox(
            height: 80,
            child: ListView(
              children: wordsData.map((w) => Text("${w['dir'] == "H" ? "Across" : "Down"}: ${w['clue']}", 
                style: const TextStyle(fontSize: 12, color: Colors.black54))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Nested loop to properly dispose of the 2D list of controllers
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}