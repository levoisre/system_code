import 'package:flutter/material.dart';

class InstructorSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onPageChanged;

  const InstructorSidebar({
    super.key,
    required this.selectedIndex,
    required this.onPageChanged,
  });

  // STI Official Brand Palette
  static const Color stiNavy = Color(0xFF0D125A);
  static const Color stiYellow = Color(0xFFFFD100);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      color: stiNavy,
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // --- SCROLLABLE MAIN NAVIGATION ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _navItem(Icons.home_outlined, "Home", selectedIndex == 0, 0),
                  _navItem(Icons.calendar_month_outlined, "Attendance", selectedIndex == 1, 1),
                  _navItem(Icons.verified_outlined, "Recitation", selectedIndex == 2, 2),
                  _navItem(Icons.grade_outlined, "Grades", selectedIndex == 3, 3),
                  _navItem(Icons.quiz_outlined, "Assessments", selectedIndex == 4, 4),
                ],
              ),
            ),
          ),

          // --- FIXED PROFILE TAB AT BOTTOM ---
          _navItem(Icons.account_circle_outlined, "Profiles", selectedIndex == 5, 5),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isSelected, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // ONE-TAP: Notifies the Index shell to swap the view immediately
        onTap: () => onPageChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), // Adds a smooth fade transition
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            // The Yellow Indicator Line on the left
            border: Border(
              left: BorderSide(
                color: isSelected ? stiYellow : Colors.transparent,
                width: 4,
              ),
            ),
            // Subtle highlight background when active
            color: isSelected 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? stiYellow : Colors.white70,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  color: isSelected ? stiYellow : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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