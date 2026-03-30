import 'package:flutter/material.dart';

// 1. IMPORT SECTION
import 'home_page/home.dart';
import 'attendance_page/attendance_history.dart';
import 'grade_page/grade_history.dart'; 
import 'assessment_page/assessments_list.dart'; 
import 'profile_page/profile.dart';

class StudentIndex extends StatefulWidget {
  const StudentIndex({super.key});

  @override
  State<StudentIndex> createState() => _StudentIndexState();
}

class _StudentIndexState extends State<StudentIndex> {
  // Original Navy Blue Theme
  static const Color originalNavy = Color(0xFF000051); 
  int _selectedIndex = 0;

  // 2. PAGE LIST - Updated with exact class names from your screenshots
  final List<Widget> _pages = [
    const StudentHome(),               
    const StudentAttendanceHistory(),  
    const GradesHistoryPage(), // Matches class in grade_history.dart
    const AssessmentPage(),    // Matches class in assessments_list.dart
    const ProfilePage(),       // Matches class in profile.dart
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves the state of each tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: originalNavy),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white, width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: originalNavy,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withValues(alpha: 0.5),
            // Serif font style for the original high-fidelity design
            selectedLabelStyle: const TextStyle(
              fontFamily: 'serif', 
              fontSize: 11, 
              fontWeight: FontWeight.bold
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'serif', 
              fontSize: 11
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), 
                activeIcon: Icon(Icons.home),
                label: 'Home'
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined), 
                activeIcon: Icon(Icons.calendar_month),
                label: 'Attendance'
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.spellcheck_rounded), 
                activeIcon: Icon(Icons.spellcheck_rounded),
                label: 'Grades'
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books_outlined), 
                activeIcon: Icon(Icons.library_books),
                label: 'Assessment'
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined), 
                activeIcon: Icon(Icons.account_circle),
                label: 'Profiles'
              ),
            ],
          ),
        ),
      ),
    );
  }
}