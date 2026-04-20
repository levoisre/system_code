import 'package:flutter/material.dart';
import '../notification_page/notification.dart';
import 'package:smart_classroom_facilitator_project/quiz_service.dart';
import 'edit_assessment.dart'; 
import 'create_assessment.dart'; 

class AssessmentHubPage extends StatefulWidget {
  const AssessmentHubPage({super.key});

  @override
  State<AssessmentHubPage> createState() => _AssessmentHubPageState();
}

class _AssessmentHubPageState extends State<AssessmentHubPage> {
  static const Color stiNavy = Color(0xFF0D125A);
  
  // Status Filter: 1 = Active (Tasks), 2 = Completed
  int selectedStatus = 1; 
  bool _isLoading = true; 
  String _searchQuery = "";
  
  // UPDATED: Syncing with your Data Structures theme
  final String currentSubjectCode = "DATA STRUCTURES";

  List<Map<String, dynamic>> _allQuizzes = [];

  @override
  void initState() {
    super.initState();
    _fetchQuizzes(); 
  }

  Future<void> _fetchQuizzes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final data = await QuizService.getQuizList(currentSubjectCode);
      
      if (mounted) {
        setState(() {
          _allQuizzes = List<Map<String, dynamic>>.from(data.map((quiz) => {
            "id": quiz['id'],
            "subject_code": quiz['subject_code'],
            "title": quiz['title']?.toString().toUpperCase() ?? "UNTITLED",
            "description": quiz['description'] ?? "No description",
            "status": quiz['is_active'], // 1 for Active, 2 for Completed
            "isGiven": quiz['is_given'] == 1, 
            "type": quiz['type'] ?? "MC", // Matches database 'type' column
          }));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Instructor Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredQuizzes {
    return _allQuizzes.where((quiz) {
      bool matchesStatus = quiz['status'] == selectedStatus;
      bool matchesSearch = quiz['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  void _toggleQuizStatus(Map<String, dynamic> quiz) async {
    bool currentGiven = quiz['isGiven'] == true;
    bool newStatus = !currentGiven;

    // Connects to server.js: app.patch('/api/quiz/give/:quizId')
    bool success = await QuizService.toggleGiveQuiz(
      quiz['id'], 
      newStatus, 
      quiz['title']
    );

    if (success && mounted) {
      setState(() {
        int index = _allQuizzes.indexWhere((q) => q['id'] == quiz['id']);
        if (index != -1) {
          _allQuizzes[index]['isGiven'] = newStatus;
        }
      });

      _showSnackBar(
        newStatus ? "Quiz Published to Students!" : "Quiz Retracted",
        newStatus ? Colors.green : stiNavy,
      );
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildHeader(isMobile),
          _buildActionBar(isMobile),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: stiNavy))
              : _filteredQuizzes.isEmpty 
                ? _buildEmptyState()
                : isMobile ? _buildListView() : _buildGridView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20, left: 20, right: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ASSESSMENT HUB", 
                style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold, color: stiNavy)),
              Text(currentSubjectCode, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: stiNavy),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "Search quizzes...", 
                    prefixIcon: const Icon(Icons.search, size: 20), 
                    filled: true, 
                    fillColor: Colors.white, 
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () async {
                   final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAssessmentPage(subjectCode: currentSubjectCode)));
                   if (result == true) _fetchQuizzes();
                }, 
                icon: const Icon(Icons.add, size: 18),
                label: const Text("NEW"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: stiNavy, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _statusChip("TASKS", 1),
              const SizedBox(width: 8),
              _statusChip("COMPLETED", 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, int status) {
    final bool isSelected = selectedStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => selectedStatus = status),
      selectedColor: stiNavy,
      labelStyle: TextStyle(color: isSelected ? Colors.white : stiNavy, fontWeight: FontWeight.bold, fontSize: 11),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.black.withAlpha(30)),
          const SizedBox(height: 16),
          Text("No $currentSubjectCode quizzes found.", style: const TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredQuizzes.length,
      itemBuilder: (context, index) => _buildQuizCard(_filteredQuizzes[index]),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.6
      ),
      itemCount: _filteredQuizzes.length,
      itemBuilder: (context, index) => _buildQuizCard(_filteredQuizzes[index]),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final bool isGiven = quiz['isGiven'] == true;
    final int status = quiz['status'] ?? 1;
    final String type = quiz['type'] ?? "MC";

    return Card(
      elevation: isGiven ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isGiven ? Colors.green : Colors.black.withAlpha(20), 
          width: isGiven ? 2.0 : 1.0 
        )
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stiNavy.withAlpha(20),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(type, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: stiNavy)),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit_note, color: Colors.grey, size: 20), 
                  onPressed: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditAssessmentPage(quizData: quiz)));
                    if (result != null) _fetchQuizzes();
                  }
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              quiz['title'], 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 15,
                color: isGiven ? Colors.green[800] : stiNavy
              )
            ),
            const SizedBox(height: 4),
            Text(quiz['description'], 
              style: const TextStyle(fontSize: 11, color: Colors.grey), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
            ),
            const Spacer(),
            
            if (status == 1) 
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => _toggleQuizStatus(quiz),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGiven ? Colors.redAccent : stiNavy, 
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isGiven ? "RETRACT" : "GIVE QUIZ", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              )
            else 
              const Center(child: Text("ARCHIVED", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}