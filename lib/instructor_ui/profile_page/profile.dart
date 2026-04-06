import 'package:flutter/material.dart';
import '../notification_page/notification.dart';
import '../login_page/login.dart'; 
import '../sidebar.dart'; 

class InstructorProfilePage extends StatelessWidget {
  // --- STATE PARAMETERS ---
  final String currentCode;
  final String currentName;
  final Function(String, String) onSubjectChanged;
  final Function(int)? onPageChanged; 

  const InstructorProfilePage({
    super.key,
    required this.currentCode,
    required this.currentName,
    required this.onSubjectChanged,
    this.onPageChanged,
  });

  // --- BRANDED PALETTE ---
  static const Color stiNavy = Color(0xFF000080);
  static const Color stiGold = Color(0xFFFFC72C);
  static const Color bgColor = Color(0xFFF8FAFC);

  // --- DATA SOURCES ---
  final List<Map<String, String>> _subjects = const [
    {"code": "CPE 401", "name": "System Simulation"},
    {"code": "ITE 302", "name": "Database Management"},
    {"code": "CS 101", "name": "Intro to Computing"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          // --- SIDEBAR INTEGRATION ---
          // This ensures the sidebar is visible and functional on the Profile page
          InstructorSidebar(
            currentPage: "Profiles", 
            onPageChanged: (index) {
              if (onPageChanged != null) {
                onPageChanged!(index);
              }
            },
          ),
          
          // --- MAIN CONTENT AREA ---
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        _buildHero(),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT COLUMN: Account Details
                            Expanded(
                              flex: 2,
                              child: _buildAccountCard(context),
                            ),
                            const SizedBox(width: 32),
                            // RIGHT COLUMN: Subject Switcher
                            Expanded(
                              flex: 1,
                              child: _buildSubjectSwitcher(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "INSTRUCTOR PROFILE", 
            style: TextStyle(
              color: stiNavy, 
              fontWeight: FontWeight.w900, 
              fontSize: 14, 
              fontFamily: 'serif'
            )
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: stiNavy),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const NotificationsPage())
            ),
          ),
        ],
      ),
    );
  }

  // --- HERO SECTION ---
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: stiNavy, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: stiNavy.withValues(alpha: 0.2), 
            blurRadius: 20
          )
        ]
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 45, 
            backgroundColor: Colors.white, 
            child: Icon(Icons.person, size: 40, color: stiNavy)
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Prof. Claire Reyes", 
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  fontFamily: 'serif'
                )
              ),
              const SizedBox(height: 8),
              Text(
                "ACTIVE CONTEXT: $currentCode", 
                style: const TextStyle(
                  color: stiGold, 
                  fontWeight: FontWeight.w600, 
                  letterSpacing: 1.2
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ACCOUNT CARD ---
  Widget _buildAccountCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 15
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ACCOUNT INFORMATION", 
            style: TextStyle(fontWeight: FontWeight.bold, color: stiNavy, fontFamily: 'serif')
          ),
          const Divider(height: 40),
          _infoRow("Employee ID", "STI-2026-0412"),
          _infoRow("Department", "College of Information Technology"),
          _infoRow("Email", "claire.reyes@sti.edu.ph"),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const InstructorLoginPage()), 
                (route) => false,
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text("SIGN OUT OF SYSTEM", style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUBJECT SWITCHER ---
  Widget _buildSubjectSwitcher() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 15
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SWITCH DASHBOARD", 
            style: TextStyle(fontWeight: FontWeight.bold, color: stiNavy, fontFamily: 'serif')
          ),
          const SizedBox(height: 20),
          for (var s in _subjects)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () => onSubjectChanged(s['code']!, s['name']!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: currentCode == s['code'] ? stiNavy : bgColor,
                leading: Icon(
                  currentCode == s['code'] ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: currentCode == s['code'] ? stiGold : stiNavy,
                ),
                title: Text(
                  s['code']!, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: currentCode == s['code'] ? Colors.white : stiNavy
                  )
                ),
                subtitle: Text(
                  s['name']!, 
                  style: TextStyle(
                    fontSize: 11, 
                    color: currentCode == s['code'] ? Colors.white70 : Colors.grey
                  )
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(
            child: Text(
              value, 
              style: const TextStyle(color: stiNavy, fontWeight: FontWeight.bold, fontSize: 14)
            )
          ),
        ],
      ),
    );
  }
}