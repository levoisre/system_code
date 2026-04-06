import 'package:flutter/material.dart';

// --- IMPORT YOUR TARGET PAGES ---
import 'assessment_page/assessment_list.dart';  // ← double-check this path matches your folder
import 'attendance_page/attendance_shell.dart';
import 'recitation_page/recitation_facilitator.dart';
import 'grades_page/grade_history.dart';

class InstructorSidebar extends StatelessWidget {
  final String currentPage;
  final Function(int)? onPageChanged;

  const InstructorSidebar({
    super.key,
    required this.currentPage,
    this.onPageChanged,
  });

  static const Color stiNavy = Color(0xFF0D125A);
  static const Color stiYellow = Color(0xFFFFD100);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      color: stiNavy,
      child: Column(
        children: [
          const SizedBox(height: 40),

          _navItem(
            context,
            Icons.home_outlined,
            "Home",
            currentPage == "Home" || currentPage == "Dashboard",
            indexTab: 0,
          ),

          _navItem(context, Icons.calendar_month_outlined, "Attendance",
              currentPage == "Attendance"),

          _navItem(context, Icons.verified_outlined, "Recitation",
              currentPage == "Recitation"),

          _navItem(context, Icons.grade_outlined, "Grades",
              currentPage == "Grades"),

          _navItem(context, Icons.quiz_outlined, "Assessments",
              currentPage == "Assessments"),

          const Expanded(child: SizedBox.shrink()),

          _navItem(
            context,
            Icons.account_circle_outlined,
            "Profiles",
            currentPage == "Profiles" || currentPage == "Profile",
            indexTab: 1,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isSelected, {
    int? indexTab,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (indexTab != null && onPageChanged != null) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            onPageChanged!(indexTab);
          } else {
            _handleDirectNavigation(context, label);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
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
            children: [
              Icon(
                icon,
                color: isSelected ? stiYellow : Colors.white70,
                size: 30,
              ),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? stiYellow : Colors.white70,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
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

  void _handleDirectNavigation(BuildContext context, String label) {
    Widget? target;
    final String normalizedLabel = label.toLowerCase();

    const String code = "CPE 401";
    const String name = "System Simulation";

    if (normalizedLabel.contains("assessment")) {
      target = AssessmentHubPage(); // ✅ No const — not a const constructor
    } else if (normalizedLabel.contains("attendance")) {
      target = const InstructorAttendanceHistory(
          subjectCode: code, subjectName: name);
    } else if (normalizedLabel.contains("recitation")) {
      target = const RecitationFacilitatorPage(
          subjectCode: code, subjectName: name);
    } else if (normalizedLabel.contains("grade")) {
      target = const GradesManagementPage(
          subjectCode: code, subjectName: name);
    }

    if (target != null && currentPage != label) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => target!),
      );
    }
  }
}