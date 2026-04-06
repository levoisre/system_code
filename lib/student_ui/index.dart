import 'package:flutter/material.dart';

// 1. IMPORT SECTION
import 'home_page/home.dart';
import 'attendance_page/attendance_history.dart';
import 'grade_page/grade_history.dart'; 
import 'assessment_page/assessments_list.dart'; 
import 'profile_page/profile.dart';

class StudentIndex extends StatefulWidget {
  // FIXED: Added initialIndex to allow routing from Assessment Results
  final int initialIndex;

  const StudentIndex({
    super.key,
    this.initialIndex = 0, // Defaults to Home
  });

  @override
  State<StudentIndex> createState() => _StudentIndexState();
}

class _StudentIndexState extends State<StudentIndex> {
  static const Color originalNavy = Color(0xFF000051); 
  
  // FIXED: Using 'late' to initialize with the passed index
  late int _selectedIndex;

  // 2. PAGE LIST - Preserved your class names
  final List<Widget> _pages = [
    const StudentHome(),               
    const StudentAttendanceHistory(),  
    const GradesHistoryPage(), 
    const AssessmentPage(),    
    const ProfilePage(),       
  ];

  @override
  void initState() {
    super.initState();
    // FIXED: This ensures the app opens the tab requested by the previous screen
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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