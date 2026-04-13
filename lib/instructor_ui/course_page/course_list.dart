import 'package:flutter/material.dart';
import 'new_course.dart';
import 'edit_course.dart';
import '../instructor_index.dart';

class InstructorCourseList extends StatefulWidget {
  const InstructorCourseList({super.key});

  @override
  State<InstructorCourseList> createState() => _InstructorCourseListState();
}

class _InstructorCourseListState extends State<InstructorCourseList> {
  static const Color darkNavy = Color(0xFF000080);
  static const Color bgColor = Color(0xFFF0F2F5);
  static const Color cardBorder = Color(0xFFD1D9E6);

  final List<Map<String, dynamic>> _allCourses = [
    {
      "title": "DATA STRUCTURES",
      "sched": "MonWed 7:30 AM - 9:30 AM",
      "code": "CPE 401", 
      "room": "Lab 402",
      "desc": "Focuses on the efficient organization and storage of data.",
      "color": const Color(0xFFC8E6C9),
      "category": "Core",
      "students": ["Amigo, Raphael", "Brusco, Hannah", "Fabrino, Valerie", "Dela Cruz, Juan"]
    },
    {
      "title": "ARTIFICIAL INTELLIGENCE",
      "sched": "TueThu 10:00 AM - 12:00 PM",
      "code": "AI 302",
      "room": "Room 305",
      "desc": "Introduction to heuristic search and machine learning models.",
      "color": const Color(0xFFF8BBD0),
      "category": "AI",
      "students": ["Garcia, Maria", "Johnson, Alex", "Lopez, Chris", "Tan, Kevin", "Reyes, Mika"]
    },
  ];

  List<Map<String, dynamic>> _filteredCourses = [];
  String _selectedCategory = "All"; 
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCourses = List.from(_allCourses);
  }

  void _applyFilters() {
    String search = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        bool matchesSearch = (course["title"] ?? "").toLowerCase().contains(search) || 
                             (course["code"] ?? "").toLowerCase().contains(search);
        bool matchesCategory = (_selectedCategory == "All") || (course["category"] == _selectedCategory);
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _handleEditCourse(Map<String, dynamic> course) async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => EditCoursePage(courseData: course))
    );

    if (!mounted) return;

    if (result == "DELETE") {
      setState(() {
        _allCourses.removeWhere((item) => item['code'] == course['code']);
        _applyFilters();
      });
      _showSnack("Subject removed from records.");
    } else if (result != null && result is Map<String, dynamic>) {
      setState(() {
        int index = _allCourses.indexWhere((item) => item['code'] == course['code']);
        if (index != -1) {
          _allCourses[index] = result;
          _applyFilters();
        }
      });
      _showSnack("Changes saved successfully.");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: darkNavy,
        behavior: SnackBarBehavior.floating,
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        title: const Text('MY COURSES', 
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          
          return Column(
            children: [
              _buildTopActionArea(isMobile),
              Expanded(
                child: _filteredCourses.isNotEmpty
                    ? GridView.builder(
                        padding: EdgeInsets.all(isMobile ? 15 : 20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 1 : 2,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: isMobile ? 1.8 : 1.1, 
                        ),
                        itemCount: _filteredCourses.length,
                        itemBuilder: (context, index) => _courseCard(context, _filteredCourses[index], isMobile),
                      )
                    : const Center(child: Text("No courses found.", style: TextStyle(color: Colors.black45))),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildTopActionArea(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => _applyFilters(),
                    decoration: const InputDecoration(
                      hintText: "Search course...",
                      prefixIcon: Icon(Icons.search, color: darkNavy, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterPopup(),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const NewCoursePage()));
                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _allCourses.insert(0, result);
                    _applyFilters();
                  });
                }
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text("CREATE NEW COURSE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkNavy, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPopup() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF0F4F8), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.filter_list_rounded, color: darkNavy),
      ),
      onSelected: (val) { setState(() { _selectedCategory = val; _applyFilters(); }); },
      itemBuilder: (context) => [
        const PopupMenuItem(value: "All", child: Text("All Categories")),
        const PopupMenuItem(value: "Core", child: Text("Core Subjects")),
        const PopupMenuItem(value: "AI", child: Text("AI Modules")),
      ],
    );
  }

  Widget _courseCard(BuildContext context, Map<String, dynamic> course, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 6, decoration: BoxDecoration(color: course['color'] ?? darkNavy, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(course['title'] ?? "Untitled", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: darkNavy), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      GestureDetector(
                        onTap: () => _handleEditCourse(course),
                        child: const Icon(Icons.edit_note_rounded, color: darkNavy, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _cardDetailRow(Icons.tag_rounded, course['code'] ?? "N/A"),
                  _cardDetailRow(Icons.schedule_rounded, course['sched'] ?? "N/A"),
                  const SizedBox(height: 4),
                  if(!isMobile) // Hide description on small mobile aspect ratios if needed, or keep for list view
                  Text(course['desc'] ?? "", style: const TextStyle(fontSize: 9, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InstructorIndex(
                              selectedSubjectCode: course['code'] ?? "N/A",
                              selectedSubjectName: course['title'] ?? "N/A",
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 0,
                      ),
                      child: const Text("MANAGE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 10, color: Color(0xFF636366)), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}