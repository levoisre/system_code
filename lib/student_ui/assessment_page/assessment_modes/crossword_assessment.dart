import 'package:flutter/material.dart';

// --- THEME COLORS ---
const Color darkNavy = Color(0xFF0C1446);
const Color stiGold = Color(0xFFFFD100);
const Color accentBlue = Color(0xFF4A90E2);
const Color emptyCell = Color(0xFFD1D9E6); // Slightly darker for better contrast

class CrosswordAssessment extends StatefulWidget {
  const CrosswordAssessment({super.key});

  @override
  State<CrosswordAssessment> createState() => _CrosswordAssessmentState();
}

class _CrosswordAssessmentState extends State<CrosswordAssessment> {
  final int gridSize = 10;
  late List<List<String>> gridData;
  late List<List<TextEditingController>> controllers;
  late List<List<FocusNode>> focusNodes;

  bool hasSubmitted = false;
  bool showSuccessOverlay = false;
  int score = 0;

  // Track the currently focused cell for highlighting
  int activeRow = -1;
  int activeCol = -1;

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
    controllers = List.generate(gridSize, (_) => List.generate(gridSize, (_) => TextEditingController()));
    focusNodes = List.generate(gridSize, (_) => List.generate(gridSize, (_) => FocusNode()));
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
        }
      }
    }
  }

  void _handleSubmit() {
    int currentScore = 0;
    int totalCells = 0;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (gridData[r][c].isNotEmpty) {
          totalCells++;
          if (controllers[r][c].text.toUpperCase() == gridData[r][c]) {
            currentScore++;
          }
        }
      }
    }
    setState(() {
      score = totalCells > 0 ? ((currentScore / totalCells) * 100).toInt() : 0;
      hasSubmitted = true;
      showSuccessOverlay = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('CROSSWORD CHALLENGE',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
      ),
      body: Column(
        children: [
          _buildGameHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text("Pinch to zoom • Tap boxes to type", 
              style: TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 2.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: darkNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _headerBadge(Icons.grid_on_rounded, "10x10 Arena"),
          _headerBadge(Icons.stars_rounded, "300 Points", isGold: true),
        ],
      ),
    );
  }

  Widget _headerBadge(IconData icon, String label, {bool isGold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isGold ? stiGold : Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: isGold ? stiGold : Colors.white, size: 12),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPlayableBoard() {
    // We set a fixed size for the board to ensure cells are large enough
    const double cellSize = 45.0; 
    const double boardPadding = 20.0;
    final double totalBoardWidth = (cellSize * gridSize) + (gridSize * 2) + boardPadding;

    return Center(
      child: Container(
        width: totalBoardWidth,
        height: totalBoardWidth,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: darkNavy, // Dark background makes the boxes pop
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15)],
        ),
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
              return Container(decoration: BoxDecoration(color: darkNavy.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2)));
            }
            return _buildInputCell(r, c);
          },
        ),
      ),
    );
  }

  Widget _buildInputCell(int r, int c) {
    bool isCorrect = controllers[r][c].text.toUpperCase() == gridData[r][c];
    bool isActive = activeRow == r && activeCol == c;

    return GestureDetector(
      onTap: () => focusNodes[r][c].requestFocus(),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? stiGold.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: hasSubmitted 
                ? (isCorrect ? Colors.green : Colors.red) 
                : (isActive ? stiGold : Colors.black12),
            width: isActive || hasSubmitted ? 2.0 : 0.5,
          ),
        ),
        child: Center(
          child: TextField(
            controller: controllers[r][c],
            focusNode: focusNodes[r][c],
            enabled: !hasSubmitted,
            textAlign: TextAlign.center,
            maxLength: 1,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: hasSubmitted ? (isCorrect ? Colors.green : Colors.red) : darkNavy,
            ),
            decoration: const InputDecoration(counterText: "", border: InputBorder.none, isDense: true),
            onTap: () => setState(() { activeRow = r; activeCol = c; }),
            onChanged: (val) {
              if (val.isNotEmpty) _moveFocus(r, c);
            },
          ),
        ),
      ),
    );
  }

  void _moveFocus(int r, int c) {
    // Logic: Look for the next playable cell in the same word
    if (c + 1 < gridSize && gridData[r][c + 1].isNotEmpty) {
      focusNodes[r][c + 1].requestFocus();
      setState(() { activeRow = r; activeCol = c + 1; });
    } else if (r + 1 < gridSize && gridData[r + 1][c].isNotEmpty) {
      focusNodes[r + 1][c].requestFocus();
      setState(() { activeRow = r + 1; activeCol = c; });
    }
  }

  Widget _buildClueSection() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
            child: Text("HINTS / CLUES", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black26, letterSpacing: 1)),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: wordsData.length,
              itemBuilder: (context, index) => _clueCard(wordsData[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clueCard(Map<String, dynamic> w) {
    return GestureDetector(
      onTap: () {
        focusNodes[w['row']][w['col']].requestFocus();
        setState(() { activeRow = w['row']; activeCol = w['col']; });
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12, bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: darkNavy.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(w['dir'] == "H" ? Icons.swap_horiz : Icons.swap_vert, size: 12, color: accentBlue),
                const SizedBox(width: 4),
                Text(w['dir'] == "H" ? "ACROSS" : "DOWN", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: accentBlue)),
              ],
            ),
            const SizedBox(height: 4),
            Text(w['clue'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: darkNavy), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: hasSubmitted ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
        child: Text(hasSubmitted ? "ASSESSMENT RECORDED" : "SUBMIT PUZZLE", style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  @override
  void dispose() {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        controllers[r][c].dispose();
        focusNodes[r][c].dispose();
      }
    }
    super.dispose();
  }
}