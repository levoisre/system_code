import 'package:flutter/material.dart';
import '../notification_page/notification.dart';
import 'quiz_service.dart';
import 'edit_assessment.dart'; 
import 'create_assessment.dart'; 

class AssessmentHubPage extends StatefulWidget {
  const AssessmentHubPage({super.key});

  @override
  State<AssessmentHubPage> createState() => _AssessmentHubPageState();
}

class _AssessmentHubPageState extends State<AssessmentHubPage> {
  static const Color stiNavy = Color(0xFF0D125A);
  final TextEditingController _searchController = TextEditingController();
  
  // 1 = Active (Tasks), 2 = Completed, 0 = Archived
  int selectedStatus = 1; 
  bool _isLoading = true; 
  String _searchQuery = "";
  final String currentSubjectCode = "CPE 401";

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
            "title": quiz['title']?.toString().toUpperCase() ?? "UNTITLED",
            "duration": quiz['description'] ?? "30 min", 
            "questions": "5", 
            "points": "50",
            "due": "Just Now",
            "status": quiz['is_active'], 
            "isGiven": false, 
          }));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Fetch Error: $e");
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

  // Moves an archived quiz back to the Active (Tasks) list
  Future<void> _unarchiveQuiz(Map<String, dynamic> quiz) async {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (c) => const Center(child: CircularProgressIndicator(color: stiNavy))
    );

    bool success = await QuizService.updateAssessmentStatus(quiz['id'], 1);

    if (!mounted) return;
    Navigator.pop(context); // Close loading spinner

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Assessment moved back to Tasks"), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        )
      );
      _fetchQuizzes(); // Refresh list to reflect changes
    }
  }

  void _toggleQuizStatus(Map<String, dynamic> quiz) {
    setState(() => quiz['isGiven'] = !quiz['isGiven']);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(quiz['isGiven'] ? "Quiz Published!" : "Quiz Retracted"),
        backgroundColor: quiz['isGiven'] ? Colors.green : stiNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _navigateAndAddAssessment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateAssessmentPage(subjectCode: currentSubjectCode)),
    );
    if (result == true) _fetchQuizzes(); 
  }

  Future<void> _navigateAndEditAssessment(Map<String, dynamic> quiz) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAssessmentPage(quizData: quiz)),
    );
    if (result == "DELETE_SIGNAL" || result != null) _fetchQuizzes(); 
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  // --- UI COMPONENTS ---

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20, left: 20, right: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("ASSESSMENT HUB", 
            style: TextStyle(fontSize: isMobile ? 18 : 24, fontWeight: FontWeight.bold, color: stiNavy)),
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
                    hintText: "Search...", 
                    prefixIcon: const Icon(Icons.search), 
                    filled: true, 
                    fillColor: Colors.white, 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _navigateAndAddAssessment, 
                style: ElevatedButton.styleFrom(backgroundColor: stiNavy, foregroundColor: Colors.white),
                child: const Text("NEW"),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statusChip("TASKS", 1),
                const SizedBox(width: 8),
                _statusChip("COMPLETED", 2),
                const SizedBox(width: 8),
                _statusChip("ARCHIVED", 0),
              ],
            ),
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
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.black.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text("No assessments found.", style: TextStyle(color: Colors.black.withValues(alpha: 0.4))),
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
        crossAxisCount: 2, 
        crossAxisSpacing: 15, 
        mainAxisSpacing: 15, 
        childAspectRatio: 1.4
      ),
      itemCount: _filteredQuizzes.length,
      itemBuilder: (context, index) => _buildQuizCard(_filteredQuizzes[index]),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final bool isGiven = quiz['isGiven'] ?? false;
    final int status = quiz['status'] ?? 1;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: isGiven ? Colors.green : Colors.black.withValues(alpha: 0.05))
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(quiz['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: stiNavy))),
                IconButton(icon: const Icon(Icons.edit_note, color: Colors.grey), onPressed: () => _navigateAndEditAssessment(quiz)),
              ],
            ),
            Text("${quiz['duration']} • ${quiz['questions']} Qs", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Spacer(),
            
            if (status == 1) // ACTIVE TASKS
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _toggleQuizStatus(quiz),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGiven ? Colors.redAccent : stiNavy, 
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Text(isGiven ? "UNGIVE QUIZ" : "GIVE QUIZ"),
                ),
              )
            else if (status == 0) // ARCHIVED
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _unarchiveQuiz(quiz),
                  icon: const Icon(Icons.unarchive_outlined, size: 16),
                  label: const Text("UNARCHIVE"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, 
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              )
            else // COMPLETED
              const Center(child: Text("Read-only Mode", style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}