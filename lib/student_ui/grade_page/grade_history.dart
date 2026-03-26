import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/student_ui/notification_page/notification.dart';
import 'package:smart_classroom_facilitator_project/student_ui/grade_page/assessment_history.dart';
import 'package:smart_classroom_facilitator_project/student_ui/grade_page/recitation_history.dart';

class GradesHistoryPage extends StatefulWidget {
  const GradesHistoryPage({super.key});

  @override
  State<GradesHistoryPage> createState() => _GradesHistoryPageState();
}

class _GradesHistoryPageState extends State<GradesHistoryPage> {
  static const Color darkNavy = Color(0xFF0C1446);
  static const Color bgLightGrey = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLightGrey,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'GRADES HISTORY',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 18, 
            fontFamily: 'serif'
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const _CircularPointHeader(totalPoints: 75, outOf: 100),
            const SizedBox(height: 25),
            const _AssessmentList(),
            const SizedBox(height: 25),
            const _RecitationList(),
            const SizedBox(height: 40), // Extra space for bottom navigation clearance
          ],
        ),
      ),
    );
  }
}

// --- WIDGET 1: TOTAL POINTS CIRCLE ---
class _CircularPointHeader extends StatelessWidget {
  final int totalPoints;
  final int outOf;
  const _CircularPointHeader({required this.totalPoints, required this.outOf});

  @override
  Widget build(BuildContext context) {
    const Color localAccent = Color(0xFF64B5F6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.black12)
      ),
      child: Column(
        children: [
          const Text('Overall Performance', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 130, height: 130,
                child: CircularProgressIndicator(
                  value: totalPoints / outOf,
                  strokeWidth: 12,
                  backgroundColor: Colors.black12,
                  color: localAccent,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$totalPoints', 
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text('out of $outOf', 
                    style: const TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- WIDGET 2: ASSESSMENT SECTION ---
class _AssessmentList extends StatelessWidget {
  const _AssessmentList();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> assessmentsData = [
      {
        "date": "March 9, 2026",
        "items": [
          {"title": "Unit Test: Mobile Dev", "score": "38/45"}, 
          {"title": "Laboratory Exercise 4", "score": "15/15"}
        ]
      },
      {
        "date": "March 8, 2026",
        "items": [
          {"title": "Quiz 1: Software Lifecycle", "score": "9/10"}
        ]
      },
    ];

    return _HistoryCard(
      title: 'Assessment History',
      onViewAll: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AssessmentHistoryPage())),
      children: [
        for (var data in assessmentsData) ...[
          _dateDivider(data['date']),
          for (var item in data['items'])
            _itemRow(item['title'], item['score'], Icons.assignment_outlined),
        ],
      ],
    );
  }
}

// --- WIDGET 3: RECITATION SECTION ---
class _RecitationList extends StatelessWidget {
  const _RecitationList();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recitationData = [
      {"date": "March 9, 2026", "items": ["10", "15"]},
    ];

    return _HistoryCard(
      title: 'Recitation History',
      onViewAll: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecitationHistoryPage())),
      children: [
        for (var data in recitationData) ...[
          _dateDivider(data['date']),
          for (var pts in data['items'])
            _itemRow("Participated in Class Discussion", "+$pts pts", Icons.stars_rounded),
        ],
      ],
    );
  }
}

// --- REUSABLE COMPONENTS ---

class _HistoryCard extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  final List<Widget> children;

  const _HistoryCard({required this.title, required this.onViewAll, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.black12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1446))),
          const SizedBox(height: 10),
          ...children,
          const SizedBox(height: 15),
          Center(
            child: TextButton(
              onPressed: onViewAll,
              child: const Text("VIEW ALL HISTORY", 
                style: TextStyle(color: Color(0xFF0C1446), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _itemRow(String title, String score, IconData icon) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB), 
      borderRadius: BorderRadius.circular(15), 
      border: Border.all(color: Colors.black12.withValues(alpha: 0.05))
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0C1446).withValues(alpha: 0.7)), 
        const SizedBox(width: 12), 
        Expanded(
          child: Text(
            title, 
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87), 
            overflow: TextOverflow.ellipsis,
          )
        ),
        const SizedBox(width: 10),
        Text(score, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0C1446))),
      ],
    ),
  );
}

Widget _dateDivider(String dateText) {
  return Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 8),
    child: Row(
      children: [
        const Expanded(child: Divider(color: Colors.black12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            dateText, 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black38, fontSize: 10)
          ),
        ),
        const Expanded(child: Divider(color: Colors.black12)),
      ],
    ),
  );
}