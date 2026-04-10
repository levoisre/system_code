import 'package:flutter/material.dart';
import 'instructions.dart'; 
// import '../notification_page/notification.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  // THEME COLORS
  static const Color darkNavy = Color(0xFF0C1446);
  static const Color stiGold = Color(0xFFFFD100); // Now being used
  static const Color bgGrey = Color(0xFFF8FAFF);

  String selectedFilter = "All";
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> filteredQuizzes = [];

  final List<Map<String, String>> allQuizzes = [
    {
      "title": "Crossword: Algorithm Architecture",
      "date": "2026-03-30",
      "points": "30",
      "questions": "6",
      "time": "1800",
      "status": "Due",
      "type": "crossword"
    },
    {
      "title": "Quiz 3: Graph Algorithms",
      "date": "2026-03-28",
      "points": "40",
      "questions": "20",
      "time": "30",
      "status": "Due",
      "type": "multiple_choice"
    },
    {
      "title": "Unit Test: Mobile Dev",
      "date": "2026-03-15",
      "points": "15",
      "questions": "10",
      "time": "30",
      "status": "Completed",
      "score": "14/15",
      "type": "multiple_choice"
    },
    {
      "title": "Logic Test: Stack & Queues",
      "date": "2026-04-05",
      "points": "20",
      "questions": "10",
      "time": "15",
      "status": "Due",
      "type": "true_false"
    },
  ];

  @override
  void initState() {
    super.initState();
    filteredQuizzes = allQuizzes;
  }

  void _performSearch() {
    setState(() {
      filteredQuizzes = allQuizzes.where((quiz) {
        final matchesSearch = quiz['title']!
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        final matchesFilter = (selectedFilter == "All") || (quiz['status'] == selectedFilter);
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF000040),
        elevation: 4,
        automaticallyImplyLeading: false,
        title: const Text('ASSESSMENTS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'serif')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterTabs(),
          const SizedBox(height: 10),
          Expanded(
            child: filteredQuizzes.isEmpty 
              ? const Center(child: Text("No assessments found", style: TextStyle(color: Colors.black45)))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: filteredQuizzes.length,
                  itemBuilder: (context, index) => _buildQuizCard(filteredQuizzes[index]),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _performSearch(),
        decoration: InputDecoration(
          hintText: "Search tasks...",
          prefixIcon: const Icon(Icons.search, color: Colors.black26),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _filterTab("All"),
          const SizedBox(width: 15),
          _filterTab("Due"),
          const SizedBox(width: 15),
          _filterTab("Completed"),
        ],
      ),
    );
  }

  Widget _filterTab(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () { setState(() { selectedFilter = label; _performSearch(); }); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? darkNavy : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? darkNavy : Colors.black12),
        ),
        child: Text(
          label, 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.bold, 
            color: isSelected ? Colors.white : Colors.black38
          )
        ),
      ),
    );
  }

  Widget _buildQuizCard(Map<String, String> quiz) {
    bool isDone = quiz['status'] == "Completed";
    IconData cardIcon;
    Color accentColor;

    switch (quiz['type']) {
      case 'crossword':
        cardIcon = Icons.grid_4x4_rounded;
        accentColor = Colors.orange;
        break;
      case 'identification':
        cardIcon = Icons.psychology_rounded;
        accentColor = Colors.purple;
        break;
      case 'true_false':
        cardIcon = Icons.rule_rounded;
        accentColor = Colors.green;
        break;
      default:
        cardIcon = Icons.list_alt_rounded;
        accentColor = const Color(0xFF4A90E2);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(quiz['type']!.replaceAll('_', ' ').toUpperCase(), 
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 0.5)),
              ),
              if (isDone)
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("SCORE: ${quiz['score']}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                )
              else
                const Text("PENDING", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: bgGrey,
                child: Icon(cardIcon, color: darkNavy, size: 18),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(quiz['title']!, 
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: darkNavy, fontFamily: 'serif')),
              ),
            ],
          ),
          const Divider(height: 30, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniDetail(Icons.event_note_rounded, isDone ? "Finished" : "Due Date", quiz['date']!),
              _miniDetail(Icons.timer_outlined, "Time", quiz['time'] == "1800" ? "30m" : "${quiz['time']}s"),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, 
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizInstructionScreen(
                      quizTitle: quiz['title']!,
                      points: quiz['points']!,
                      questions: quiz['questions']!,
                      duration: quiz['time']!,
                      quizType: quiz['type']!, 
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                // Use stiGold for the active button to fix the lint warning
                backgroundColor: isDone ? Colors.white : stiGold, 
                foregroundColor: darkNavy,
                side: isDone ? const BorderSide(color: Color(0xFFE0E0E0)) : BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: isDone ? 0 : 2,
              ),
              child: Text(isDone ? "REVIEW PERFORMANCE" : "OPEN ASSESSMENT", 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
            ),
          )
        ],
      ),
    );
  }

  Widget _miniDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black26),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.black26, fontSize: 9, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
          ],
        ),
      ],
    );
  }
}