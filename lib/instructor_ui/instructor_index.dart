import 'package:flutter/material.dart';
import 'sidebar.dart';

// --- MAPPED IMPORTS ---
import 'home_page/dashboard.dart'; 
import 'attendance_page/attendance_shell.dart'; 
import 'recitation_page/recitation_facilitator.dart'; 
import 'grades_page/grade_history.dart'; 
import 'assessment_page/assessment_list.dart'; 
import 'profile_page/profile.dart'; 

class InstructorIndex extends StatefulWidget {
  final String selectedSubjectCode;
  final String selectedSubjectName;

  const InstructorIndex({
    super.key,
    required this.selectedSubjectCode,
    required this.selectedSubjectName,
  });

  @override
  State<InstructorIndex> createState() => _InstructorIndexState();
}

class _InstructorIndexState extends State<InstructorIndex> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onPageChanged(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 850;

    final List<Widget> pages = [
      InstructorDashboard(
        subjectCode: widget.selectedSubjectCode,
        subjectName: widget.selectedSubjectName,
        courseData: const {}, 
      ),
      InstructorAttendanceHistory(
        subjectCode: widget.selectedSubjectCode,
        subjectName: widget.selectedSubjectName,
      ),
      RecitationFacilitatorPage(
        subjectCode: widget.selectedSubjectCode,
        subjectName: widget.selectedSubjectName,
      ),
      GradesManagementPage(
        subjectCode: widget.selectedSubjectCode,
        subjectName: widget.selectedSubjectName,
      ),
      const AssessmentHubPage(), 
      InstructorProfilePage(
        currentCode: widget.selectedSubjectCode,
        currentName: widget.selectedSubjectName,
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      // --- MOBILE HEADER REMOVED ---
      appBar: null, 
      drawer: isMobile
          ? Drawer(
              width: 110,
              backgroundColor: const Color(0xFF0D125A),
              child: InstructorSidebar(
                selectedIndex: _selectedIndex,
                onPageChanged: _onPageChanged,
                isMobile: true,
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            InstructorSidebar(
              selectedIndex: _selectedIndex,
              onPageChanged: _onPageChanged,
              isMobile: false,
            ),
          
          Expanded(
            child: Column(
              children: [
                // --- DESKTOP HEADER REMOVED ---
                
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: pages.map((page) => _contentWrapper(page)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Action Button to open drawer on mobile since AppBar is gone
      floatingActionButton: isMobile 
        ? FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF0D125A),
            child: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          )
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  Widget _contentWrapper(Widget child) {
    return Container(
      // Adjusted padding to look better without a header
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: child,
        ), 
      ),
    );
  }
}