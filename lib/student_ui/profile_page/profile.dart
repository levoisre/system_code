import 'package:flutter/material.dart';
import '../login_page/login.dart'; 

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // --- SYNCED THEME COLORS ---
  static const Color darkNavy = Color(0xFF0C1446);
  static const Color accentBlue = Color(0xFF4A90E2);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color bgGrey = Color(0xFFF0F4F8); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF000040),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'STUDENT PORTFOLIO',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w700, 
            fontSize: 16, 
            letterSpacing: 1.5,
            fontFamily: 'serif'
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- TOP PROFILE HERO SECTION ---
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF000040),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
              ),
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  _buildHeroAvatar(),
                  const SizedBox(height: 20),
                  const Text(
                    'KRISTINA DELA CRUZ',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Text(
                      'SILVER TIER STUDENT',
                      style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -25),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // --- QUICK STATS ROW ---
                    Row(
                      children: [
                        _buildStatTile("02", "QUESTS", Icons.auto_awesome_rounded, accentBlue),
                        const SizedBox(width: 15),
                        _buildStatTile("120", "POINTS", Icons.stars_rounded, stiGold),
                      ],
                    ),
                    
                    const SizedBox(height: 35),
                    _buildSectionLabel("LEVEL & PROGRESS"),
                    const SizedBox(height: 15),
                    _buildGamifiedProgressCard(),
                    
                    const SizedBox(height: 35),
                    _buildSectionLabel("UNLOCKED ACHIEVEMENTS"),
                    const SizedBox(height: 15),
                    _buildAchievementGrid(),

                    const SizedBox(height: 45),

                    // --- LOGOUT ACTION ---
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: TextButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                        label: const Text(
                          "TERMINATE SESSION",
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 13),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: stiGold.withValues(alpha: 0.3), width: 2),
          ),
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, size: 75, color: darkNavy),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: stiGold,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
            ),
            child: const Text("LVL 07", style: TextStyle(color: darkNavy, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: darkNavy.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: darkNavy, letterSpacing: -1)),
            Text(label, style: TextStyle(fontSize: 10, color: darkNavy.withValues(alpha: 0.4), fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildGamifiedProgressCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: darkNavy,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: darkNavy.withValues(alpha: 0.2), blurRadius: 25, offset: const Offset(0, 15))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CURRENT EXPERIENCE", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  SizedBox(height: 4),
                  Text("7,640 XP", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.bolt_rounded, color: stiGold, size: 24),
              )
            ],
          ),
          const SizedBox(height: 25),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.76,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(accentBlue),
            ),
          ),
          const SizedBox(height: 15),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("LVL 07", style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
              Text("2,360 XP TO LEVEL UP", style: TextStyle(color: accentBlue, fontSize: 10, fontWeight: FontWeight.w900)),
              Text("LVL 08", style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAchievementGrid() {
    final List<Map<String, dynamic>> items = [
      {"icon": Icons.speed, "label": "Fastest"},
      {"icon": Icons.auto_graph, "label": "Streaker"},
      {"icon": Icons.shield_rounded, "label": "Perfect"},
      {"icon": Icons.emoji_events, "label": "Elite"},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((i) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: darkNavy.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 5))],
              border: Border.all(color: bgGrey, width: 2),
            ),
            child: Icon(i['icon'], color: accentBlue, size: 24),
          ),
          const SizedBox(height: 8),
          Text(i['label'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: darkNavy)),
        ],
      )).toList(),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: stiGold, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: darkNavy.withValues(alpha: 0.5), letterSpacing: 1.2),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Center(child: Text('Confirm Sign Out', style: TextStyle(fontWeight: FontWeight.w900, color: darkNavy))),
        content: const Text('Are you sure you want to end your academic session?', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}