import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/student_ui/attendance_page/request_form.dart';
// 1. IMPORT YOUR NOTIFICATIONS PAGE
import 'package:smart_classroom_facilitator_project/student_ui/notification_page/notification.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  static const Color darkNavy = Color(0xFF0C1446);
  String selectedMonth = "March 2026";

  // 1. DATA: List of submitted requests
  final List<Map<String, String>> _submittedRequests = [
    {"date": "03/09/2026", "reason": "Forgot to Clock In", "status": "Pending"},
    {"date": "03/02/2026", "reason": "Technical Issue", "status": "Approved"},
  ];

  // 2. DATA: Monthly Stats
  final Map<String, Map<String, String>> monthlyStats = {
    "March 2026": {"early": "2", "absent": "3", "late": "0", "req": "2"},
    "February 2026": {"early": "1", "absent": "1", "late": "2", "req": "1"},
    "January 2026": {"early": "0", "absent": "0", "late": "0", "req": "0"},
  };

  // 3. DATA: Monthly Logs
  final Map<String, List<Map<String, dynamic>>> monthlyData = {
    "March 2026": [
      {
        "week": "Week 2", "dates": "08 - 14",
        "logs": [
          _LogData('09', 'Tues', '1:30 PM', '7:00 PM', '05:30'),
          _LogData('08', 'Mon', '3:30 PM', '9:00 PM', '06:30')
        ]
      },
    ],
    "February 2026": [
      {
        "week": "Week 4", "dates": "22 - 28",
        "logs": [
          _LogData('24', 'Tues', '1:00 PM', '6:00 PM', '05:00'),
          _LogData('23', 'Mon', '2:00 PM', '8:00 PM', '06:00')
        ]
      },
      {
        "week": "Week 3", "dates": "15 - 21",
        "logs": [
          _LogData('17', 'Tues', '1:45 PM', '6:30 PM', '04:45'),
        ]
      },
    ],
    "January 2026": [
      {
        "week": "Week 1", "dates": "01 - 07",
        "logs": [
          _LogData('06', 'Tues', '9:00 AM', '4:00 PM', '07:00'),
          _LogData('05', 'Mon', '9:15 AM', '4:30 PM', '07:15')
        ]
      },
    ],
  };

  // Logic to navigate and receive new requests from the form
  Future<void> _navigateToForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RequestFormPage()),
    );

    // FIX: Guard against async gaps
    if (!mounted) return;

    if (result != null && result is Map<String, String>) {
      setState(() {
        _submittedRequests.insert(0, result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request added to your history")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthRecords = monthlyData[selectedMonth] ?? [];
    final stats = monthlyStats[selectedMonth] ?? {"early": "0", "absent": "0", "late": "0", "req": "0"};

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('ATTENDANCE HISTORY', 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        // 2. UPDATED ACTIONS: BELL IS NOW CLICKABLE
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(onTap: _showMonthPicker, child: _buildMonthSelector()),
            const SizedBox(height: 20),
            _buildStatsGrid(stats),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("RECENT REQUESTS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54, fontFamily: 'serif')),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyRequestsPage(requests: _submittedRequests))),
                  child: const Text("View All", style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            _buildRequestListPreview(),
            const SizedBox(height: 25),

            const Text("WEEKLY LOGS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54, fontFamily: 'serif')),
            const SizedBox(height: 10),
            
            if (currentMonthRecords.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.only(top: 20), child: Text("No records found for this month.")))
            else
              ...currentMonthRecords.map((weekData) => _buildWeeklyLog(week: weekData['week'], dates: weekData['dates'], logs: weekData['logs'])),
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildRequestListPreview() {
    if (_submittedRequests.isEmpty) return const Text("No active requests.");
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _submittedRequests.length,
        itemBuilder: (context, index) {
          final req = _submittedRequests[index];
          Color statusCol = req['status'] == 'Pending' ? Colors.orange : Colors.green;
          return Container(
            width: 180, margin: const EdgeInsets.only(right: 15), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black12)),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(req['date']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(req['reason']!, style: const TextStyle(fontSize: 11, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Text(req['status']!, style: TextStyle(color: statusCol, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                Positioned(top: -10, right: -10, child: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _submittedRequests.removeAt(index)))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyLog({required String week, required String dates, required List<_LogData> logs}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(color: Color(0xFFE3F2FD), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(week, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(dates, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          ...logs.map((log) => _logRow(log)),
        ],
      ),
    );
  }

  Widget _logRow(_LogData d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 45,
            child: Column(
              children: [
                Text(d.dateNum, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
                Text(d.dayName, style: const TextStyle(fontSize: 11, color: Colors.black54))
              ],
            ),
          ),
          _timeItem(Icons.south_west, d.checkIn, 'In'),
          _timeItem(Icons.north_east, d.checkOut, 'Out'),
          _timeItem(Icons.access_time, d.totalHrs, 'Total'),
          
          IconButton(
            icon: const Icon(Icons.edit_note, size: 28, color: Colors.black87),
            onPressed: _navigateToForm,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [const Icon(Icons.calendar_month, size: 20, color: Colors.black54), const SizedBox(width: 10), Text(selectedMonth, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif'))]),
          const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        ],
      ),
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        List<String> months = monthlyStats.keys.toList();
        return Container(
          padding: const EdgeInsets.all(20), height: 300,
          child: ListView.builder(
            itemCount: months.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(months[i], style: const TextStyle(fontFamily: 'serif')),
              onTap: () { setState(() => selectedMonth = months[i]); Navigator.pop(context); },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(Map<String, String> stats) {
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2,
      children: [
        _statCard(const Color(0xFFE3F2FD), stats['early']!, 'Early Leave', Colors.blue),
        _statCard(const Color(0xFFF3E5F5), stats['absent']!, 'Absents', Colors.purple),
        _statCard(const Color(0xFFFFEBEE), stats['late']!, 'Late In', Colors.red),
        _statCard(const Color(0xFFFFFDE7), stats['req']!, 'Requests', Colors.orange),
      ],
    );
  }

  Widget _statCard(Color bg, String val, String label, Color textCol) {
    return Container(
      padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textCol)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'serif')),
      ]),
    );
  }

  Widget _timeItem(IconData i, String t, String l) {
    return Column(
      children: [
        Icon(i, size: 18), 
        Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), 
        Text(l, style: const TextStyle(fontSize: 9, color: Colors.black54))
      ]
    );
  }
}

// --- VIEW ALL REQUESTS PAGE ---
class MyRequestsPage extends StatefulWidget {
  final List<Map<String, String>> requests;
  const MyRequestsPage({super.key, required this.requests});
  @override State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1446), 
        iconTheme: const IconThemeData(color: Colors.white), 
        title: const Text("MY REQUESTS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
      ),
      body: widget.requests.isEmpty 
        ? const Center(child: Text("No requests found.")) 
        : ListView.builder(
            padding: const EdgeInsets.all(15), 
            itemCount: widget.requests.length,
            itemBuilder: (context, index) {
              final req = widget.requests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
                child: ListTile(
                  leading: const Icon(Icons.description, color: Color(0xFF0C1446)),
                  title: Text(req['date']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${req['reason']} - ${req['status']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() => widget.requests.removeAt(index));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request deleted")));
                    },
                  ),
                ),
              );
            },
          ),
    );
  }
}

class _LogData {
  final String dateNum, dayName, checkIn, checkOut, totalHrs;
  _LogData(this.dateNum, this.dayName, this.checkIn, this.checkOut, this.totalHrs);
}