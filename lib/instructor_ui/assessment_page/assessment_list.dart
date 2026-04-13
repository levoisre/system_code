import 'package:flutter/material.dart';
import '../notification_page/notification.dart';

// --- IMPORTS ---
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
  
  bool isTasksSelected = true;
  String _searchQuery = "";

  final List<Map<String, dynamic>> _allQuizzes = [
    {"title": "QUIZ 3: GRAPH ALGORITHMS", "duration": "15 min", "questions": "20", "points": "40", "due": "03/09/26", "isArchived": false, "isGiven": false},
    {"title": "QUIZ 4: RECURSION", "duration": "30 min", "questions": "15", "points": "25", "due": "03/11/26", "isArchived": false, "isGiven": true},
    {"title": "QUIZ 2: BINARY TREES", "duration": "45 min", "questions": "35", "points": "50", "due": "03/08/26", "isArchived": false, "isGiven": false},
    {"title": "QUIZ 1: ALGO TYPES", "duration": "10 min", "questions": "10", "points": "15", "due": "03/08/26", "isArchived": true, "isGiven": false},
  ];

  List<Map<String, dynamic>> get _filteredQuizzes {
    return _allQuizzes.where((quiz) {
      bool matchesStatus = quiz['isArchived'] == !isTasksSelected;
      bool matchesSearch = quiz['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  void _toggleQuizStatus(Map<String, dynamic> quiz) {
    setState(() {
      quiz['isGiven'] = !quiz['isGiven'];
    });

    final String message = quiz['isGiven'] 
        ? "Quiz published to students." 
        : "Quiz retracted successfully.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: quiz['isGiven'] ? Colors.green : stiNavy,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _navigateAndAddAssessment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateAssessmentPage()),
    );

    if (!mounted) return;

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        result['isGiven'] = false;
        _allQuizzes.insert(0, result);
      });
    }
  }

  Future<void> _navigateAndEditAssessment(Map<String, dynamic> quiz) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAssessmentPage(quizData: quiz)),
    );

    if (!mounted) return;

    if (result == "DELETE_SIGNAL") {
      setState(() {
        _allQuizzes.remove(quiz);
      });
    } 
    else if (result != null) {
      setState(() {
        int index = _allQuizzes.indexOf(quiz);
        if (index != -1) {
          _allQuizzes[index] = result;
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detect Screen Size
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Material(
      color: const Color(0xFFF1F5F9),
      child: Column(
        children: [
          _buildHeader(isMobile),
          _buildActionBar(isMobile),
          Expanded(
            child: _filteredQuizzes.isEmpty 
              ? const Center(child: Text("No assessments found.", style: TextStyle(color: Colors.grey)))
              : isMobile 
                ? _buildListView() 
                : _buildGridView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("ASSESSMENT HUB", 
            style: TextStyle(
              fontSize: isMobile ? 18 : 24, 
              fontWeight: FontWeight.w900, 
              fontFamily: 'serif', 
              color: stiNavy
            )),
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
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 35, vertical: 20),
      child: Column(
        children: [
          // Layout Search and Add Button based on screen width
          isMobile 
            ? Column(
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: _buildAddButton()),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildSearchField()),
                  const SizedBox(width: 15),
                  _buildAddButton(),
                ],
              ),
          const SizedBox(height: 15),
          Row(
            children: [
              _toggleBtn("TASKS", isTasksSelected, () => setState(() => isTasksSelected = true)),
              const SizedBox(width: 10),
              _toggleBtn("ARCHIVED", !isTasksSelected, () => setState(() => isTasksSelected = false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => _searchQuery = val),
      decoration: InputDecoration(
        hintText: "Search assessments...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _navigateAndAddAssessment,
      icon: const Icon(Icons.add),
      label: const Text("NEW ASSESSMENT"),
      style: ElevatedButton.styleFrom(
        backgroundColor: stiNavy, 
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.5,
      ),
      itemCount: _filteredQuizzes.length,
      itemBuilder: (context, index) => _buildQuizCard(_filteredQuizzes[index], false),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _filteredQuizzes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) => _buildQuizCard(_filteredQuizzes[index], true),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback tap) {
    return OutlinedButton(
      onPressed: tap,
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? stiNavy : Colors.white,
        foregroundColor: active ? Colors.white : stiNavy,
        side: const BorderSide(color: stiNavy),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz, bool isMobile) {
    final bool isGiven = quiz['isGiven'] ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      constraints: isMobile ? null : const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isGiven ? Colors.green.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05), 
          width: isGiven ? 2 : 1
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quiz['title'], 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'serif', color: stiNavy)
                )
              ),
              IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.black38),
                onPressed: () => _navigateAndEditAssessment(quiz),
              ),
            ],
          ),
          const Divider(),
          _statRow(Icons.timer_outlined, quiz['duration'], Icons.help_outline, "${quiz['questions']} Qs"),
          const SizedBox(height: 15),
          _actionBtn(
            isGiven ? "UNGIVE QUIZ" : "GIVE QUIZ", 
            isGiven ? Colors.redAccent : stiNavy, 
            () => _toggleQuizStatus(quiz)
          ),
        ],
      ),
    );
  }

  Widget _statRow(IconData i1, String t1, IconData i2, String t2) {
    return Row(
      children: [
        Icon(i1, size: 14, color: Colors.black38),
        const SizedBox(width: 4),
        Text(t1, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(width: 15),
        Icon(i2, size: 14, color: Colors.black38),
        const SizedBox(width: 4),
        Text(t2, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback tap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: tap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, 
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}