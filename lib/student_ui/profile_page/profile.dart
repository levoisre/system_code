import 'package:flutter/material.dart';
import '../login_page/login.dart'; 

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // --- SYNCED THEME COLORS ---
  static const Color darkNavy = Color(0xFF0C1446);
  static const Color accentBlue = Color(0xFF4A90E2);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color bgGrey = Color(0xFFF8FAFF); // Matching Home background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF000040), // Matching Home header
        elevation: 4,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'STUDENT PROFILE',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w600, 
            fontSize: 16, 
            letterSpacing: 2.0,
            fontFamily: 'serif'
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- HEADER PROFILE SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  _buildHeroAvatar(),
                  const SizedBox(height: 20),
                  const Text(
                    'KRISTINA DELA CRUZ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: darkNavy, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'SILVER TIER STUDENT',
                      style: TextStyle(fontSize: 11, color: accentBlue, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildSectionLabel("ACADEMIC STATS"),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildStatBox("02", "QUESTS", Icons.auto_awesome),
                      const SizedBox(width: 15),
                      _buildStatBox("120", "POINTS", Icons.stars_rounded),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  _buildSectionLabel("RECENT ACHIEVEMENTS"),
                  const SizedBox(height: 15),
                  _buildAchievementRow(),
                  
                  const SizedBox(height: 30),
                  _buildGamifiedCard(
                    title: "EXPERIENCE PROGRESS",
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Level 07", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                            Text("76%", style: TextStyle(color: stiGold, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _customProgressBar(0.76),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- LOGOUT BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                      label: const Text(
                        "LOG OUT ACCOUNT",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroAvatar() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Outer pulse ring to match Home design
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accentBlue.withValues(alpha: 0.2), width: 2),
          ),
          child: const CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFFF0F4F8),
            child: Icon(Icons.person_rounded, size: 70, color: darkNavy),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: darkNavy,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: stiGold, width: 2),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]
            ),
            child: const Text("LVL 07", style: TextStyle(color: stiGold, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementRow() {
    final List<Map<String, dynamic>> achievements = [
      {"icon": Icons.speed, "title": "Speedster"},
      {"icon": Icons.military_tech, "title": "Perfect"},
      {"icon": Icons.verified_user, "title": "Reliable"},
      {"icon": Icons.workspace_premium, "title": "Elite"},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: achievements.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: darkNavy.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Icon(item['icon'], color: accentBlue, size: 24),
                const SizedBox(height: 8),
                Text(item['title'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: darkNavy)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatBox(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: darkNavy.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentBlue, size: 22),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: darkNavy)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: darkNavy.withValues(alpha: 0.4), letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildGamifiedCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: darkNavy,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: darkNavy.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1.5)),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _customProgressBar(double value) {
    return Stack(
      children: [
        Container(height: 10, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            height: 10,
            width: constraints.maxWidth * value,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [accentBlue, stiGold]),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold, color: darkNavy)),
        content: const Text('Are you sure you want to end your session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('STAY', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}