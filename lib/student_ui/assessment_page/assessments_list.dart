import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/instuctions.dart';
// 1. IMPORT YOUR NOTIFICATIONS PAGE
import 'package:smart_classroom_facilitator_project/student_ui/notification_page/notification.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color bgGrey = Color(0xFFE5E5E5);
  
  String selectedFilter = "All";

  // --- FULL MOCK DATABASE WITH 4 MODES ---
  final List<Map<String, String>> allQuizzes = [
    {
      "title": "Crossword: Algorithm Architecture", 
      "date": "2026-03-30", 
      "points": "30", 
      "questions": "6", 
      "time": "1800",
      "status": "Due"
    },
    {
      "title": "Quiz 3: Graph Algorithms", 
      "date": "2026-03-28", 
      "points": "40", 
      "questions": "20", 
      "time": "30",
      "status": "Due"
    },
    {
      "title": "Graph & Tree Traversal Identification", 
      "date": "2026-03-26", 
      "points": "30", 
      "questions": "20", 
      "time": "60",
      "status": "Due"
    },
    {
      "title": "Unit Test: Mobile Dev", 
      "date": "2026-03-15", 
      "points": "15", 
      "questions": "10", 
      "time": "30",
      "status": "Completed"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'ASSESSMENTS', 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            fontFamily: 'serif'
          )
        ),
        centerTitle: true,
        actions: [
          // 2. UPDATED NOTIFICATION BUTTON
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search assessments...",
                prefixIcon: const Icon(Icons.search, color: Colors.black45),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- FILTER TABS ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                _filterTab("All"),
                const SizedBox(width: 25),
                _filterTab("Due"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- SCROLLABLE LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: allQuizzes.length,
              itemBuilder: (context, index) {
                final quiz = allQuizzes[index];
                
                if (selectedFilter != "All" && quiz['status'] != selectedFilter) {
                  return const SizedBox.shrink();
                }

                return _buildQuizCard(
                  title: quiz['title']!,
                  dueDate: quiz['date']!,
                  points: quiz['points']!,
                  duration: quiz['time']!,
                  questions: quiz['questions']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterTab(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? darkNavy : Colors.black38,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              color: darkNavy,
            )
        ],
      ),
    );
  }

  Widget _buildQuizCard({
    required String title, 
    required String dueDate, 
    required String points, 
    required String duration,
    required String questions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            // Modern transparency method to avoid lint errors
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title, 
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    fontFamily: 'serif'
                  )
                )
              ),
            ],
          ),
          const Divider(height: 30, thickness: 1),
          _rowDetail(Icons.calendar_today, "Due Date", dueDate),
          _rowDetail(Icons.stars, "Points", "$points points"),
          _rowDetail(Icons.access_time, "Duration", 
            duration == "1800" ? "30 mins" : "$duration secs"),
          const SizedBox(height: 25),
          Center(
            child: SizedBox(
              width: 180, 
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizInstructionScreen(
                        quizTitle: title,
                        points: points,
                        questions: questions,
                        duration: duration,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkNavy, 
                  shape: const StadiumBorder()
                ),
                child: const Text(
                  "START QUIZ", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _rowDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          const Spacer(),
          Text(
            value, 
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)
          ),
        ],
      ),
    );
  }
}