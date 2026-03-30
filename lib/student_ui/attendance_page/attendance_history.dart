import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'request_form.dart';

class StudentAttendanceHistory extends StatefulWidget {
  const StudentAttendanceHistory({super.key});

  @override
  State<StudentAttendanceHistory> createState() => _StudentAttendanceHistoryState();
}

class _StudentAttendanceHistoryState extends State<StudentAttendanceHistory> with SingleTickerProviderStateMixin {
  static const Color darkNavy = Color(0xFF000051);
  static const Color bgColor = Color(0xFFE8E8E8);
  
  late TabController _tabController;
  late Timer _timer;
  
  DateTime _viewingDate = DateTime.now(); // The month the student is currently viewing
  String _liveTime = "";

  // 1. DATA SOURCE: All historical logs
  final List<Map<String, dynamic>> _allAttendanceLogs = [
    {"date": DateTime(2026, 3, 09), "in": "1:30 PM", "out": "7:00 PM", "hours": "05:30"},
    {"date": DateTime(2026, 3, 08), "in": "3:30 PM", "out": "9:00 PM", "hours": "06:30"},
    {"date": DateTime(2026, 2, 14), "in": "08:00 AM", "out": "05:00 PM", "hours": "09:00"},
    {"date": DateTime(2026, 2, 12), "in": "09:15 AM", "out": "04:30 PM", "hours": "07:15"},
  ];

  final List<Map<String, dynamic>> _submittedRequests = [
    {"date": "03/10/2026", "reason": "Medical", "status": "Approved", "type": "Absence"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _updateLiveTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateLiveTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _updateLiveTime() {
    if (mounted) {
      setState(() {
        _liveTime = DateFormat('hh:mm:ss a').format(DateTime.now());
      });
    }
  }

  // --- LOGIC: SELECT PREVIOUS DATES ---
  Future<void> _changeViewDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _viewingDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _viewingDate = picked);
    }
  }

  void _openRequestForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RequestFormPage()),
    );
    if (result != null && mounted) {
      setState(() {
        _submittedRequests.insert(0, result as Map<String, dynamic>);
        _tabController.animateTo(1); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ATTENDANCE HISTORY", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'serif')),
            Text("Live: $_liveTime", style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: "LOGS"), Tab(text: "MY REQUESTS")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildLogsTab(), _buildRequestsTab()],
      ),
    );
  }

  Widget _buildLogsTab() {
    // FILTER LOGS based on the month and year selected in _viewingDate
    final filteredLogs = _allAttendanceLogs.where((log) => 
      log['date'].month == _viewingDate.month && 
      log['date'].year == _viewingDate.year
    ).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMonthSelector(),
          _buildStatGrid(filteredLogs.length),
          const SizedBox(height: 10),
          if (filteredLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Text("No logs found for this period.", style: TextStyle(color: Colors.grey)),
            )
          else
            _buildWeeklyCard("Records Found", DateFormat('MMMM yyyy').format(_viewingDate), filteredLogs),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return InkWell(
      onTap: _changeViewDate, // Opens the date picker to view previous dates
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
        child: Row(
          children: [
            const Icon(Icons.history, color: darkNavy, size: 20),
            const SizedBox(width: 12),
            Text("Viewing: ${DateFormat('MMMM yyyy').format(_viewingDate)}", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: darkNavy)),
            const Spacer(),
            const Text("CHANGE", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // --- SHARED UI HELPERS ---

  Widget _buildStatGrid(int totalLogs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.3,
        children: [
          _statTile(totalLogs.toString(), "Present Days", const Color(0xFFF0F7FF)),
          _statTile("0", "Absents", const Color(0xFFF5EEFF)),
          _statTile("0", "Late In", const Color(0xFFFFEBF0)),
          _statTile(_submittedRequests.length.toString(), "Requests", const Color(0xFFFFF8E1)),
        ],
      ),
    );
  }

  Widget _statTile(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54, fontFamily: 'serif')),
        ],
      ),
    );
  }

  Widget _buildWeeklyCard(String title, String range, List<Map<String, dynamic>> logs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: darkNavy, fontSize: 12)),
              const Spacer(),
              Text(range, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const Divider(),
          ...logs.map((l) => _buildLogItem(l)),
        ],
      ),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(DateFormat('dd').format(log['date']), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(DateFormat('E').format(log['date']), style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          _timeDetail(Icons.login, log['in']!, "In"),
          _timeDetail(Icons.logout, log['out']!, "Out"),
          _timeDetail(Icons.timer_outlined, log['hours']!, "Total"),
          IconButton(onPressed: _openRequestForm, icon: const Icon(Icons.edit_note, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _timeDetail(IconData icon, String time, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: darkNavy),
        Text(time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRequestsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _submittedRequests.length,
      itemBuilder: (context, index) {
        final req = _submittedRequests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black12)),
          child: Row(
            children: [
              const Icon(Icons.history_edu, color: Colors.orange),
              const SizedBox(width: 15),
              Expanded(child: Text(req['reason']!, style: const TextStyle(fontWeight: FontWeight.bold))),
              Text(req['status'], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}