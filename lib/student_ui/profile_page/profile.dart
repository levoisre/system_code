import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color darkNavy = Color(0xFF0C1446);
  static const Color neonBlue = Color(0xFF4D88FF);
  static const Color experiencePurple = Color(0xFF8E54E9);
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color bgGrey = Color(0xFFF1F4F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'STUDENT PROFILE',
          style: TextStyle(
            color: darkNavy, 
            fontWeight: FontWeight.w900, 
            fontSize: 16, 
            letterSpacing: 2.0,
            fontFamily: 'serif'
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildHeroAvatar(),
            const SizedBox(height: 15),
            const Text(
              'KRISTINA DELA CRUZ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkNavy, letterSpacing: -0.5),
            ),
            const Text(
              'SILVER TIER STUDENT',
              style: TextStyle(fontSize: 12, color: neonBlue, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 35),

            _buildSectionLabel("RECENT ACHIEVEMENTS"),
            const SizedBox(height: 15),
            _buildAchievementRow(),
            
            const SizedBox(height: 30),

            // STATS GRID: Uses Expanded to occupy all extra horizontal space
            Row(
              children: [
                _buildStatBox("02", "QUESTS", Icons.auto_awesome),
                const SizedBox(width: 15),
                _buildStatBox("120", "POINTS", Icons.stars),
              ],
            ),
            const SizedBox(height: 25),

            _buildGamifiedCard(
              title: "EXPERIENCE PROGRESS",
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Level 07", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      Text("76%", style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _customProgressBar(0.76),
                ],
              ),
            ),
            const SizedBox(height: 40),

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
    );
  }

  Widget _buildAchievementRow() {
    final List<Map<String, dynamic>> achievements = [
      {"icon": Icons.speed, "title": "Speedster", "desc": "Top 5 in Quiz"},
      {"icon": Icons.military_tech, "title": "First Class", "desc": "Perfect Lab"},
      {"icon": Icons.verified_user_outlined, "title": "Reliable", "desc": "10 Day Streak"},
      {"icon": Icons.workspace_premium, "title": "Elite", "desc": "Silver Tier"},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: achievements.map((item) {
        // Expanded ensures each card takes up equal portions of the Row's width
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _achievementCard(item['icon'], item['title'], item['desc']),
          ),
        );
      }).toList(),
    );
  }

  Widget _achievementCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: neonBlue, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: darkNavy),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(fontSize: 8, color: darkNavy.withValues(alpha: 0.5)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAvatar() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [neonBlue, experiencePurple]),
            boxShadow: [BoxShadow(color: neonBlue.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: const CircleAvatar(
            radius: 52,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_rounded, size: 60, color: darkNavy),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: darkNavy,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldAccent, width: 2),
          ),
          child: const Text("LVL 07", style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: neonBlue, size: 22),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: darkNavy)),
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
              gradient: const LinearGradient(colors: [neonBlue, experiencePurple]),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to end your session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('STAY')),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}