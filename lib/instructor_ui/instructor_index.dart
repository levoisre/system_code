import 'package:flutter/material.dart';

// --- IMPORTS ---
import 'sidebar.dart';
import 'home_page/dashboard.dart';
import 'profile_page/profile.dart';

class InstructorIndex extends StatefulWidget {
  const InstructorIndex({super.key});

  @override
  State<InstructorIndex> createState() => _InstructorIndexState();
}

class _InstructorIndexState extends State<InstructorIndex> {
  // 0 = Home/Dashboard, 1 = Profile
  int _selectedIndex = 0;

  // --- PERSISTENT APP STATE ---
  String _subjectCode = "CPE 401";
  String _subjectName = "System Simulation";

  // Data for the student roster (Passed to Dashboard)
  final Map<String, dynamic> _rosterData = const {
    'students': [
      'Alex Johnson', 
      'Maria Garcia', 
      'Tony Hugh', 
      'Jet Hinks', 
      'Samuel Pru'
    ],
  };

  /// Switches between Home (Index 0) and Profile (Index 1) tabs
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Updates subject context from the Profile page and routes back Home
  void _handleSubjectSwitch(String code, String name) {
    setState(() {
      _subjectCode = code;
      _subjectName = name;
      // Automatically return to Dashboard after changing subject context
      _selectedIndex = 0; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevents UI from squishing/overflowing when the keyboard appears
      resizeToAvoidBottomInset: false, 
      body: Row(
        children: [
          // --- PERSISTENT SIDEBAR ---
          InstructorSidebar(
            // Tells the sidebar which icon to highlight (Yellow Indicator)
            currentPage: _selectedIndex == 0 ? "Home" : "Profiles",
            onPageChanged: _onPageChanged,
          ),

          // --- MAIN CONTENT AREA ---
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                // INDEX 0: THE DASHBOARD (The "Home" destination)
                InstructorDashboard(
                  // THE KEY: ValueKey forces the dashboard to refresh 
                  // its internal state if the subject code changes or when 
                  // clicking 'Home' to reset the view.
                  key: ValueKey('Dash_$_subjectCode'), 
                  subjectCode: _subjectCode,
                  subjectName: _subjectName,
                  courseData: _rosterData,
                ),

                // INDEX 1: THE PROFILE PAGE
                InstructorProfilePage(
                  key: const ValueKey('ProfileTab'),
                  currentCode: _subjectCode,
                  currentName: _subjectName,
                  onSubjectChanged: _handleSubjectSwitch,
                  // Allows buttons inside the Profile page to switch tabs
                  onPageChanged: _onPageChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}