import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const Color darkNavy = Color(0xFF00084D);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color lightBlueBg = Color(0xFFF0F5FF);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color glassWhite = Color(0x1AFFFFFF);

  final List<Map<String, dynamic>> leaderboardData = const [
    {"rank": "4", "name": "Dianne Russell", "points": 1250, "isMe": false, "trend": "up"},
    {"rank": "5", "name": "Guy Hawkins", "points": 1100, "isMe": false, "trend": "down"},
    {"rank": "6", "name": "Courtney Henry", "points": 1050, "isMe": false, "trend": "steady"},
    {"rank": "7", "name": "Claire (You)", "points": 950, "isMe": true, "trend": "up"},
    {"rank": "8", "name": "Arlene McCoy", "points": 900, "isMe": false, "trend": "steady"},
    {"rank": "9", "name": "Eleanor Pena", "points": 850, "isMe": false, "trend": "down"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkNavy,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          _buildUserPerformanceSummary(),
          const SizedBox(height: 10),
          _buildPodium(context),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                itemCount: leaderboardData.length,
                itemBuilder: (context, index) => _buildRankRow(leaderboardData[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              'ARENA RANKINGS',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 3, fontFamily: 'serif'),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: stiGold, size: 24),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPerformanceSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _summaryItem("GLOBAL RANK", "#7", Icons.emoji_events_outlined),
          _divider(),
          _summaryItem("TOTAL XP", "15,400", Icons.bolt_rounded),
          _divider(),
          _summaryItem("WIN RATE", "82%", Icons.auto_graph_rounded),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: stiGold, size: 16),
        const SizedBox(height: 6),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _divider() => Container(height: 35, width: 1, color: Colors.white.withValues(alpha: 0.1));

  Widget _buildPodium(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 240,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _podiumPillar("2", "Brooklyn", "1,450", 110, silver, screenWidth),
          const SizedBox(width: 12),
          _podiumPillar("1", "Claire", "1,500", 150, stiGold, screenWidth),
          const SizedBox(width: 12),
          _podiumPillar("3", "Jerome", "1,320", 90, bronze, screenWidth),
        ],
      ),
    );
  }

  Widget _podiumPillar(String rank, String name, String pts, double height, Color color, double screenWidth) {
    bool isFirst = rank == "1";
    double pillarWidth = (screenWidth - 80) / 3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: pillarWidth,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.05)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(rank, style: TextStyle(fontSize: isFirst ? 40 : 32, fontWeight: FontWeight.w900, color: color)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text("$pts XP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.7))),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -50,
              child: Column(
                children: [
                  if (isFirst) const Icon(Icons.workspace_premium_rounded, color: stiGold, size: 24),
                  const SizedBox(height: 4),
                  CircleAvatar(
                    radius: isFirst ? 32 : 28,
                    backgroundColor: color,
                    child: CircleAvatar(
                      radius: isFirst ? 29 : 25,
                      backgroundColor: darkNavy,
                      child: Icon(Icons.person_rounded, color: color, size: isFirst ? 35 : 30),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildRankRow(Map<String, dynamic> student) {
    bool isMe = student['isMe'];
    int points = student['points'];
    double progress = (points / 1500).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isMe ? stiGold : Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(color: darkNavy.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              student['rank'],
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: darkNavy),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: isMe ? stiGold.withValues(alpha: 0.2) : lightBlueBg,
            child: Icon(Icons.person_rounded, color: isMe ? darkNavy : Colors.blueGrey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'],
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isMe ? darkNavy : Colors.black87),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black.withValues(alpha: 0.05),
                    color: isMe ? stiGold : const Color(0xFF4A90E2),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${student['points']}",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: darkNavy)),
              _buildTrendText(student['trend']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendText(String trend) {
    Color color;
    String text;
    if (trend == "up") {
      color = Colors.green;
      text = "▲ UP";
    } else if (trend == "down") {
      color = Colors.red;
      text = "▼ DOWN";
    } else {
      color = Colors.grey;
      text = "● STEADY";
    }
    return Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color));
  }
}