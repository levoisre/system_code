import 'package:flutter/material.dart';

class InstructorSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onPageChanged;
  final bool isMobile;

  const InstructorSidebar({
    super.key,
    required this.selectedIndex,
    required this.onPageChanged,
    this.isMobile = false,
  });

  static const Color stiNavy = Color(0xFF0D125A);
  static const Color stiYellow = Color(0xFFFFD100);

  @override
  Widget build(BuildContext context) {
    return Container(
      // On Desktop we use 100, on Mobile Drawer we let it fill the drawer width
      width: isMobile ? null : 100,
      height: double.infinity,
      color: stiNavy,
      child: Column(
        children: [
          // Adaptive top padding
          SizedBox(height: isMobile ? MediaQuery.of(context).padding.top + 20 : 20),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _navItem(Icons.home_outlined, "Home", 0),
                  _navItem(Icons.calendar_month_outlined, "Attendance", 1),
                  _navItem(Icons.verified_outlined, "Recitation", 2),
                  _navItem(Icons.grade_outlined, "Grades", 3),
                  _navItem(Icons.quiz_outlined, "Assessments", 4),
                ],
              ),
            ),
          ),

          // Divider to separate settings/profile from main navigation
          Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
          
          _navItem(Icons.account_circle_outlined, "Profiles", 5),
          
          // Padding for mobile bottom navigation bars (Home Indicator)
          SizedBox(height: isMobile ? MediaQuery.of(context).padding.bottom + 10 : 10),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPageChanged(index),
        splashColor: Colors.white.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? stiYellow : Colors.transparent,
                width: 4,
              ),
            ),
            color: isSelected 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? stiYellow : Colors.white.withValues(alpha: 0.7),
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9, // Slightly larger for readability
                  color: isSelected ? stiYellow : Colors.white.withValues(alpha: 0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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