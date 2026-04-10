import 'package:flutter/material.dart';

// --- PAGE IMPORTS ---
import 'home_page/home.dart';
import 'attendance_page/attendance_history.dart';
import 'grade_page/grade_history.dart'; 
import 'assessment_page/assessments_list.dart'; 
import 'profile_page/profile.dart';

class StudentIndex extends StatefulWidget {
  final int initialIndex;

  const StudentIndex({
    super.key,
    this.initialIndex = 0, 
  });

  @override
  State<StudentIndex> createState() => _StudentIndexState();
}

class _StudentIndexState extends State<StudentIndex> {
  // Official Colors
  static const Color stiNavy = Color(0xFF0D125A);
  static const Color stiGold = Color(0xFFFFD100);
  
  late int _selectedIndex;

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
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // Body displays the active page
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      
      // --- UPDATED BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: stiNavy,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home_outlined, Icons.home, "Home", 0),
              _buildBottomNavItem(Icons.calendar_month_outlined, Icons.calendar_month, "Attendance", 1),
              _buildBottomNavItem(Icons.spellcheck_rounded, Icons.spellcheck_rounded, "Grades", 2),
              _buildBottomNavItem(Icons.library_books_outlined, Icons.library_books, "Assessment", 3),
              _buildBottomNavItem(Icons.account_circle_outlined, Icons.account_circle, "Profile", 4),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom Navigation Item Builder to include the Yellow Highlight
  Widget _buildBottomNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            // YELLOW HIGHLIGHT: Horizontal bar at the TOP of the selected tab
            border: Border(
              top: BorderSide(
                color: isSelected ? stiGold : Colors.transparent,
                width: 3,
              ),
            ),
            // Subtle glow effect
            color: isSelected ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? stiGold : Colors.white60,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? stiGold : Colors.white60,
                  fontFamily: 'serif',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}