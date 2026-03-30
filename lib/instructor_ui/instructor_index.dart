import 'package:flutter/material.dart';
// FIXED IMPORT: No need for ../ because both files are under lib/instructor_ui/
import 'recitation_page/recitation_facilitator.dart';

class InstructorIndex extends StatefulWidget {
  const InstructorIndex({super.key});

  @override
  State<InstructorIndex> createState() => _InstructorIndexState();
}

class _InstructorIndexState extends State<InstructorIndex> {
  // FIXED: Changed to private _instructorNavy and used it in the UI to clear the warning
  static const Color _instructorNavy = Color(0xFF1B1E2F);
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text("Instructor Dashboard")), 
    const RecitationFacilitator(), 
    const Center(child: Text("Attendance Management")),
    const Center(child: Text("Instructor Profile")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("INSTRUCTOR PANEL", 
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        leading: const Icon(Icons.school_rounded, color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black, height: 1.0),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple,
        // Using the variable here to clear the "unused_field" warning
        unselectedItemColor: _instructorNavy.withValues(alpha: 0.5),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.casino_outlined), label: 'Recitation'),
          BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}