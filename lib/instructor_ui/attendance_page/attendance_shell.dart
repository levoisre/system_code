import 'package:flutter/material.dart';
// Ensure these paths match your actual project structure
import '../notification_page/notification.dart'; 
import 'attendance_history.dart';

class InstructorAttendanceHistory extends StatelessWidget {
  const InstructorAttendanceHistory({super.key});

  // Theme Colors - Unified with Dashboard
  static const Color darkNavy = Color(0xFF000080);
  static const Color bgColor = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          // --- PART 1: FIXED SIDEBAR ---
          _buildSidebar(context),
          
          Expanded(
            child: Column(
              children: [
                // --- PART 2: MINIMALIST HEADER ---
                _buildShellHeader(context),
                
                // --- PART 3: DYNAMIC CONTENT (HISTORY TABLE) ---
                const Expanded(
                  child: AttendanceHistoryPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShellHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text("Attendance", 
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ),
              const Text(
                "HISTORY LOGS",
                style: TextStyle(
                  color: darkNavy, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 14, 
                  fontFamily: 'serif',
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          // Consistent Notification Bell
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: darkNavy, size: 24),
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const NotificationsPage())
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 90,
      color: darkNavy,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          _navItem(context, Icons.grid_view_rounded, "Home", false, isHome: true),
          _navItem(context, Icons.calendar_today_rounded, "Attendance", true),
          _navItem(context, Icons.emoji_events_outlined, "Recitation", false),
          _navItem(context, Icons.analytics_outlined, "Grades", false),
          _navItem(context, Icons.assignment_outlined, "Assessment", false), 
          const Spacer(),
          _navItem(context, Icons.account_circle_outlined, "Profile", false),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool isSelected, {bool isHome = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isHome) {
              Navigator.pop(context); // Returns to Dashboard
            }
          },
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.white38, size: 24),
              const SizedBox(height: 8),
              Text(
                label, 
                style: TextStyle(
                  fontSize: 9, 
                  color: isSelected ? Colors.white : Colors.white38,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}