import 'package:flutter/material.dart';
// Ensure these imports match your actual folder/file names
import 'package:smart_classroom_facilitator_project/student_ui/home_page/home.dart';
import 'package:smart_classroom_facilitator_project/student_ui/attendance_page/attendance_history.dart';
import 'package:smart_classroom_facilitator_project/student_ui/grade_page/grade_history.dart';
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/assessments_list.dart'; 
import 'package:smart_classroom_facilitator_project/student_ui/profile_page/profile.dart';

class StudentIndex extends StatefulWidget {
  const StudentIndex({super.key});

  @override
  State<StudentIndex> createState() => _StudentIndexState();
}

class _StudentIndexState extends State<StudentIndex> {
  int _selectedIndex = 0;

  // The list of pages for the bottom navigation
  final List<Widget> _pages = [
    const StudentHome(),       
    const AttendanceHistory(), 
    const GradesHistoryPage(), 
    const AssessmentPage(),    
    const ProfilePage(),       
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Brand Color
    const Color darkNavy = Color(0xFF00084D);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              // FIXED: Changed .withOpacity(0.1) to .withValues(alpha: 0.1)
              color: Colors.black.withValues(alpha: 0.1), 
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: darkNavy,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          // Added a modern touch with labels matching your design
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Attendance'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Grades'),
            BottomNavigationBarItem(icon: Icon(Icons.quiz_rounded), label: 'Assessment'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profiles'),
          ],
        ),
      ),
    );
  }
}