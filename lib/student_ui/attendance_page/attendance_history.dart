import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'request_form.dart';
// Path connected to your central notification file
import '../notification_page/notification.dart'; 

// --- THEME COLORS ---
const Color stiNavy = Color(0xFF0C1446);
const Color darkNavy = Color(0xFF0C1446); 
const Color stiGold = Color(0xFFFFD100);
const Color accentBlue = Color(0xFF4A90E2);
const Color background = Color(0xFFF1F4F9);

class StudentAttendanceHistory extends StatefulWidget {
  const StudentAttendanceHistory({super.key});

  @override
  State<StudentAttendanceHistory> createState() => _StudentAttendanceHistoryState();
}

class _StudentAttendanceHistoryState extends State<StudentAttendanceHistory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Timer _timer;

  DateTime _viewingDate = DateTime.now();
  String _liveTime = "";

  // Notification State
  int unreadNotifications = 2;

  final List<Map<String, dynamic>> _allAttendanceLogs = [
    {"date": DateTime(2026, 4, 10), "in": "07:30 AM", "out": "09:30 AM", "hours": "02:00", "status": "Present"},
    {"date": DateTime(2026, 4, 09), "in": "07:55 AM", "out": "09:30 AM", "hours": "01:35", "status": "Late"},
    {"date": DateTime(2026, 4, 08), "in": "--:--", "out": "--:--", "hours": "00:00", "status": "Absent"},
    {"date": DateTime(2026, 4, 06), "in": "01:30 PM", "out": "05:30 PM", "hours": "04:00", "status": "Present"},
  ];

  final List<Map<String, dynamic>> _submittedRequests = [
    {"date": "04/08/2026", "reason": "System Log-in Error", "status": "Pending", "type": "Adjustment"},
    {"date": "03/18/2026", "reason": "Medical Certificate Provided", "status": "Approved", "type": "Absence"},
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

  // UPDATED: Now navigates to a full screen instead of a bottom sheet
  void _openNotificationSheet() {
    setState(() => unreadNotifications = 0);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
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

  Future<void> _changeViewDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _viewingDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: stiNavy)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _viewingDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF000040),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ATTENDANCE HISTORY",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'serif',
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "SYNCED AT: $_liveTime",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5
              ),
            ),
          ],
        ),
        actions: [
          _buildNotificationIcon(),
          const SizedBox(width: 15), 
        ],
      ),
      body: Column(
        children: [
          _buildSegmentControl(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildLogsTab(), _buildRequestsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none, 
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white, size: 28), 
          onPressed: _openNotificationSheet,
        ),
        if (unreadNotifications > 0)
          Positioned(
            right: 8, 
            top: 10,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF000040), width: 2), 
              ),
              constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
            ),
          )
      ],
    );
  }

  Widget _buildSegmentControl() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: TabBar(
        controller: _tabController,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicatorPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: stiGold.withValues(alpha: 0.15),
        ),
        dividerColor: Colors.transparent,
        labelColor: stiNavy,
        unselectedLabelColor: Colors.black26,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
        tabs: const [Tab(text: "LOGS"), Tab(text: "APPEALS")],
      ),
    );
  }

  Widget _buildLogsTab() {
    final filteredLogs = _allAttendanceLogs.where((log) => 
      log['date'].month == _viewingDate.month && log['date'].year == _viewingDate.year
    ).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 10),
        _buildMonthPickerTrigger(),
        const SizedBox(height: 20),
        _buildStatSummary(filteredLogs),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          child: Text("DAILY TIMELINE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black38, letterSpacing: 2)),
        ),
        if (filteredLogs.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: Text("No records found.")))
        else
          ...filteredLogs.map((log) => _buildHapticLogItem(log)),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildMonthPickerTrigger() {
    return GestureDetector(
      onTap: _changeViewDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: stiGold, size: 20),
            const SizedBox(width: 15),
            Text(DateFormat('MMMM yyyy').format(_viewingDate).toUpperCase(), 
              style: const TextStyle(fontWeight: FontWeight.w900, color: stiNavy, fontSize: 13)),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummary(List<Map<String, dynamic>> logs) {
    int present = logs.where((l) => l['status'] == "Present").length;
    int lateCount = logs.where((l) => l['status'] == "Late").length;
    int absent = logs.where((l) => l['status'] == "Absent").length;

    return Row(
      children: [
        _statBox("PRESENT", present.toString(), Colors.green),
        const SizedBox(width: 12),
        _statBox("LATE", lateCount.toString(), Colors.orange),
        const SizedBox(width: 12),
        _statBox("ABSENT", absent.toString(), Colors.red),
      ],
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black38)),
          ],
        ),
      ),
    );
  }

  Widget _buildHapticLogItem(Map<String, dynamic> log) {
    Color statusColor;
    switch(log['status']) {
      case "Late": statusColor = Colors.orange; break;
      case "Absent": statusColor = Colors.red; break;
      default: statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: stiNavy.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: statusColor),
              Container(
                width: 70,
                color: background.withValues(alpha: 0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('dd').format(log['date']), 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: log['status'] == "Absent" ? Colors.red.shade900 : stiNavy)),
                    Text(DateFormat('EEE').format(log['date']).toUpperCase(), 
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _timeBadge(log['in'], Icons.login_rounded, Colors.blue, isDisabled: log['status'] == "Absent"),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, size: 10, color: Colors.black12)),
                          _timeBadge(log['out'], Icons.logout_rounded, Colors.redAccent, isDisabled: log['status'] == "Absent"),
                          const Spacer(),
                          IconButton(
                            onPressed: _openRequestForm,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: const Icon(Icons.edit_calendar_rounded, color: stiNavy, size: 22),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(log['status'] == "Absent" ? "No session record" : "${log['hours']}h session", 
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black45)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(log['status'].toUpperCase(), 
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: statusColor)),
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
      ),
    );
  }

  Widget _timeBadge(String time, IconData icon, Color color, {bool isDisabled = false}) {
    return Row(
      children: [
        Icon(icon, size: 12, color: isDisabled ? Colors.black12 : color.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(time, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: isDisabled ? Colors.black26 : stiNavy)),
      ],
    );
  }

  Widget _buildRequestsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _submittedRequests.length,
      itemBuilder: (context, index) {
        final req = _submittedRequests[index];
        bool isApproved = req['status'] == "Approved";

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isApproved ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(req['type'].toUpperCase(), style: TextStyle(color: isApproved ? Colors.green : Colors.orange, fontWeight: FontWeight.w900, fontSize: 10)),
                  Text(req['date'], style: const TextStyle(color: Colors.black26, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 12),
              Text(req['reason'], style: const TextStyle(fontWeight: FontWeight.w900, color: stiNavy, fontSize: 15)),
              const Divider(height: 30),
              Row(
                children: [
                  Icon(isApproved ? Icons.check_circle_rounded : Icons.pending_actions_rounded, color: isApproved ? Colors.green : Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(req['status'], style: TextStyle(color: isApproved ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}