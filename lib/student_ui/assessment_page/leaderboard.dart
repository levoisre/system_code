import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/quiz_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const Color darkNavy = Color(0xFF00084D);
  static const Color stiGold = Color(0xFFFFD100);
  static const Color lightBlueBg = Color(0xFFF0F5FF);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  final String currentSubject = "CPE 401";
  final String myName = "Claire"; 

  @override
  Widget build(BuildContext context) {
    // Determine if we are on a large screen
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 800;

    return Scaffold(
      backgroundColor: darkNavy,
      body: Center( // Centers the entire layout on Desktop
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 600 : double.infinity, // Max width for Desktop
          ),
          child: FutureBuilder<List<dynamic>>(
            future: QuizService.getQuizLeaderboard(currentSubject),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: stiGold));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(context);
              }

              final rawData = snapshot.data!;
              List<Map<String, dynamic>> sortedList = rawData.map((e) => Map<String, dynamic>.from(e)).toList();
              
              // Sort using the Quicksort logic provided previously
              _quicksort(sortedList, 0, sortedList.length - 1);

              final topThree = sortedList.take(3).toList();
              final theRest = sortedList.skip(3).toList();
              
              final myData = sortedList.firstWhere(
                (s) => s['name'].toString().contains(myName), 
                orElse: () => {"name": myName, "total_points": 0}
              );
              final myRank = sortedList.indexOf(myData) + 1;

              return Column(
                children: [
                  _buildCustomAppBar(context),
                  _buildUserPerformanceSummary(myRank, myData['total_points']),
                  const SizedBox(height: 10),
                  _buildPodium(context, topThree, screenWidth),
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
                        itemCount: theRest.length,
                        itemBuilder: (context, index) {
                          final student = theRest[index];
                          final globalIndex = index + 4;
                          return _buildRankRow(student, globalIndex, topThree[0]['total_points']);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Quicksort Logic ---
  void _quicksort(List<Map<String, dynamic>> list, int low, int high) {
    if (low < high) {
      int pivotIndex = _partition(list, low, high);
      _quicksort(list, low, pivotIndex - 1);
      _quicksort(list, pivotIndex + 1, high);
    }
  }

  int _partition(List<Map<String, dynamic>> list, int low, int high) {
    num pivot = list[high]['total_points'] ?? 0;
    int i = low - 1;
    for (int j = low; j < high; j++) {
      if ((list[j]['total_points'] ?? 0) >= pivot) {
        i++;
        var temp = list[i];
        list[i] = list[j];
        list[j] = temp;
      }
    }
    var temp = list[i + 1];
    list[i + 1] = list[high];
    list[high] = temp;
    return i + 1;
  }

  // --- Dynamic UI Helpers ---

  Widget _buildUserPerformanceSummary(int rank, dynamic xp) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _summaryItem("RANK", "#$rank", Icons.emoji_events_outlined),
          _divider(),
          _summaryItem("TOTAL PTS", "$xp", Icons.bolt_rounded),
          _divider(),
          _summaryItem("STATUS", "Active", Icons.auto_graph_rounded),
        ],
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<dynamic> topThree, double width) {
    String n1 = topThree.isNotEmpty ? topThree[0]['name'] : "TBD";
    String p1 = topThree.isNotEmpty ? topThree[0]['total_points'].toString() : "0";
    String n2 = topThree.length > 1 ? topThree[1]['name'] : "TBD";
    String p2 = topThree.length > 1 ? topThree[1]['total_points'].toString() : "0";
    String n3 = topThree.length > 2 ? topThree[2]['name'] : "TBD";
    String p3 = topThree.length > 2 ? topThree[2]['total_points'].toString() : "0";

    return Container(
      height: 240,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _podiumPillar("2", n2, p2, 110, silver),
          const SizedBox(width: 12),
          _podiumPillar("1", n1, p1, 150, stiGold),
          const SizedBox(width: 12),
          _podiumPillar("3", n3, p3, 90, bronze),
        ],
      ),
    );
  }

  Widget _podiumPillar(String rank, String name, String pts, double height, Color color) {
    bool isFirst = rank == "1";
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 100, // Fixed width for pillar to ensure consistent look on all screens
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withAlpha(100), color.withAlpha(15)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: color.withAlpha(120), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(rank, style: TextStyle(fontSize: isFirst ? 40 : 32, fontWeight: FontWeight.w900, color: color)),
                  Padding(padding: const EdgeInsets.only(bottom: 15), child: Text("$pts PTS", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white70))),
                ],
              ),
            ),
            Positioned(top: -50, child: CircleAvatar(radius: isFirst ? 32 : 28, backgroundColor: color, child: CircleAvatar(radius: isFirst ? 29 : 25, backgroundColor: darkNavy, child: Icon(Icons.person_rounded, color: color, size: isFirst ? 35 : 30)))),
          ],
        ),
        const SizedBox(height: 10),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildRankRow(Map<String, dynamic> student, int rank, dynamic topScore) {
    String name = student['name'] ?? "Unknown";
    bool isMe = name.contains(myName);
    int points = student['total_points'] ?? 0;
    double progress = topScore > 0 ? (points / topScore).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isMe ? stiGold : Colors.transparent, width: 2),
        boxShadow: [BoxShadow(color: darkNavy.withAlpha(15), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("$rank", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: darkNavy), textAlign: TextAlign.center)),
          const SizedBox(width: 10),
          CircleAvatar(radius: 20, backgroundColor: isMe ? stiGold.withAlpha(50) : lightBlueBg, child: Icon(Icons.person_rounded, color: isMe ? darkNavy : Colors.blueGrey, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isMe ? darkNavy : Colors.black87)),
                const SizedBox(height: 4),
                ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.black12, color: isMe ? stiGold : const Color(0xFF4A90E2), minHeight: 4)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Text("$points", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: darkNavy)),
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
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
            const Text('ARENA RANKINGS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 3, fontFamily: 'serif')),
            const SizedBox(width: 48), // Placeholder to center text
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: stiGold, size: 16),
        const SizedBox(height: 6),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _divider() => Container(height: 35, width: 1, color: Colors.white12);

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.leaderboard_outlined, color: Colors.white24, size: 80),
          const SizedBox(height: 20),
          const Text("No rankings found.", style: TextStyle(color: Colors.white70)),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Go Back", style: TextStyle(color: stiGold)))
        ],
      ),
    );
  }
}