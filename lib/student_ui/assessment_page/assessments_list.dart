import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/quiz_service.dart'; 
import 'instructions.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  static const Color darkNavy = Color(0xFF0C1446);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color bgGrey = Color(0xFFF8FAFF);

  String selectedFilter = "All";
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _liveQuizzes = [];
  bool _isLoading = true;
  
  // SYNCED CONTEXT: Matches your updated database seed
  final String currentSubjectCode = "DATA STRUCTURES";
  final String currentStudentName = "Claire Anne"; 

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchLiveQuizzes();
    
    // Check for new quizzes every 10 seconds automatically
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchLiveQuizzes(isAuto: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // --- API SYNC LOGIC ---
  Future<void> _fetchLiveQuizzes({bool isAuto = false}) async {
    if (!isAuto) setState(() => _isLoading = true);
    
    try {
      final data = await QuizService.getLiveQuizzes(currentSubjectCode);
      List<Map<String, dynamic>> temp = [];

      for (var q in data) {
        // Calls the backend check route we added to server.js
        final res = await QuizService.checkCompletion(q['id'], currentStudentName);
        
        temp.add({
          "id": q['id'], 
          "title": q['title'] ?? "UNTITLED QUIZ",
          "points": "10", // Default display points
          "questions": "5", // Static items display
          "time": "30",
          "status": res['completed'] ? "Completed" : "Due",
          "type": q['type']?.toString().toUpperCase() ?? "MC",
          "score": res['completed'] ? res['data']['score'].toString() : null,
        });
      }

      if (!mounted) return;

      // Notify user if a new quiz was published by the instructor
      if (isAuto && temp.length > _liveQuizzes.length && _liveQuizzes.isNotEmpty) {
        _triggerPushNotification();
      }

      setState(() {
        _liveQuizzes = temp;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Student Hub Sync Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _triggerPushNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🔔 NEW ASSESSMENT PUBLISHED!", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredQuizzes {
    return _liveQuizzes.where((quiz) {
      final matchesSearch = quiz['title']!
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final matchesFilter = (selectedFilter == "All") || (quiz['status'] == selectedFilter);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF000040),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            const Text('ASSESSMENT HUB',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(currentSubjectCode, 
                style: const TextStyle(color: stiGold, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white), 
            onPressed: () => _fetchLiveQuizzes()
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchLiveQuizzes(),
        color: darkNavy,
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterTabs(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: darkNavy))
                : _filteredQuizzes.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _filteredQuizzes.length,
                      itemBuilder: (context, index) => _buildQuizCard(_filteredQuizzes[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Search assessments...",
          prefixIcon: const Icon(Icons.search, color: Colors.black26),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: ["All", "Due", "Completed"].map((label) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _filterTab(label),
        )).toList(),
      ),
    );
  }

  Widget _filterTab(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? darkNavy : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? darkNavy : Colors.black12),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black38)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 60, color: Colors.black.withAlpha(20)),
          const SizedBox(height: 15),
          const Text("No live assessments found", style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold)),
          const Text("Instructor hasn't published anything yet.", style: TextStyle(color: Colors.black26, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    bool isDone = quiz['status'] == "Completed";
    Color statusColor = isDone ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: darkNavy.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                      child: Text(quiz['type'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: darkNavy)),
                    ),
                    Row(
                      children: [
                        CircleAvatar(radius: 4, backgroundColor: statusColor),
                        const SizedBox(width: 8),
                        Text(
                          isDone ? "SCORE: ${quiz['score']}" : "DUE SOON", 
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 11)
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(quiz['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkNavy)),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => QuizInstructionScreen(
                    quizId: quiz['id'], 
                    quizTitle: quiz['title'], 
                    points: quiz['points'], 
                    questions: quiz['questions'],
                    duration: quiz['time'], 
                    quizType: quiz['type'],
                  ),
                ),
              ).then((_) => _fetchLiveQuizzes());
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: isDone ? Colors.grey[100] : stiGold,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  isDone ? "REVIEW PERFORMANCE" : "START ASSESSMENT", 
                  style: const TextStyle(fontWeight: FontWeight.w900, color: darkNavy, fontSize: 13)
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}