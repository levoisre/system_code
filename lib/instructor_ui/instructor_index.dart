import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'home_page/dashboard.dart';
import 'profile_page/profile.dart';
import 'attendance_page/attendance_shell.dart';
import 'recitation_page/recitation_facilitator.dart';
import 'grades_page/grade_history.dart';
import 'assessment_page/assessment_list.dart';

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

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // This is the ONLY sidebar in the whole session
          InstructorSidebar(
            selectedIndex: _selectedIndex,
            onPageChanged: _onPageChanged,
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                InstructorDashboard(
                  subjectCode: widget.selectedSubjectCode,
                  subjectName: widget.selectedSubjectName,
                  courseData: const {'students': ['Alex Johnson', 'Maria Garcia', 'Tony Hugh', 'Jet Hinks', 'Samuel Pru']},
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}