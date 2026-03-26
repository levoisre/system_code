import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const Color darkNavy = Color(0xFF00084D);
  static const Color lightBlueBg = Color(0xFFD0E0FF);

  // --- MOCK STUDENT DATA ---
  final List<Map<String, dynamic>> leaderboardData = const [
    {"rank": "4", "name": "Dianne Russell", "points": "12 pts", "isMe": false},
    {"rank": "5", "name": "Guy Hawkins", "points": "11 pts", "isMe": false},
    {"rank": "6", "name": "Courtney Henry", "points": "10 pts", "isMe": false},
    {"rank": "7", "name": "Claire (You)", "points": "15 pts", "isMe": true},
    {"rank": "8", "name": "Arlene McCoy", "points": "9 pts", "isMe": false},
    {"rank": "9", "name": "Eleanor Pena", "points": "8 pts", "isMe": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueBg,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'LEADERBOARD',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // --- 1. THE TOP 3 PODIUM ---
          _buildPodium(),

          const SizedBox(height: 30),

          // --- 2. SCROLLABLE RANKING LIST ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                itemCount: leaderboardData.length,
                itemBuilder: (context, index) {
                  final student = leaderboardData[index];
                  return _buildRankRow(student);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _podiumPillar("2", "Brooklyn", "14 pts", 110, Colors.white.withValues(alpha: 0.7)),
        _podiumPillar("1", "Claire", "15 pts", 150, Colors.white),
        _podiumPillar("3", "Jerome", "13 pts", 90, Colors.white.withValues(alpha: 0.5)),
      ],
    );
  }

  Widget _podiumPillar(String rank, String name, String pts, double height, Color color) {
    return Column(
      children: [
        const Icon(Icons.person_pin, size: 40, color: darkNavy),
        const SizedBox(height: 5),
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkNavy)),
        const SizedBox(height: 8),
        Container(
          width: 90,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(rank, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: darkNavy)),
              Text(pts, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkNavy)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankRow(Map<String, dynamic> student) {
    bool isMe = student['isMe'];
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isMe ? darkNavy.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isMe ? Border.all(color: darkNavy, width: 1) : null,
      ),
      child: Row(
        children: [
          Text(
            student['rank'],
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black45),
          ),
          const SizedBox(width: 20),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              student['name'],
              style: TextStyle(
                fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                color: isMe ? darkNavy : Colors.black87,
              ),
            ),
          ),
          Text(
            student['points'],
            style: const TextStyle(fontWeight: FontWeight.bold, color: darkNavy),
          ),
        ],
      ),
    );
  }
}