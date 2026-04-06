import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../notification_page/notification.dart'; 
import '../sidebar.dart'; 
import 'attendance_request.dart'; 

class InstructorAttendanceHistory extends StatefulWidget {
  final String subjectCode;
  final String subjectName;

  const InstructorAttendanceHistory({
    super.key, 
    required this.subjectCode, 
    required this.subjectName
  });

  @override
  State<InstructorAttendanceHistory> createState() => _InstructorAttendanceHistoryState();
}

class _InstructorAttendanceHistoryState extends State<InstructorAttendanceHistory> {
  static const Color stiNavy = Color(0xFF000080);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color tableHeaderColor = Color(0xFFF1F5F9);
  static const Color statusGreen = Color(0xFF43A047);
  static const Color statusRed = Color(0xFFE53935);
  static const Color statusOrange = Color(0xFFFB8C00);

  final TextEditingController _searchController = TextEditingController();
  String _currentSearch = "";
  String _currentDateFilter = "2026-03-09"; 

  final List<Map<String, String>> _allLogs = [
    {"date": "2026-03-09", "name": "Alex Johnson", "id": "020004567992", "status": "Present", "in": "1:30 pm", "out": "7:00 pm"},
    {"date": "2026-03-09", "name": "Maria Garcia", "id": "02000874933", "status": "Present", "in": "1:30 pm", "out": "7:00 pm"},
    {"date": "2026-03-10", "name": "Tony Hugh", "id": "02000983643", "status": "Absent", "in": " - ", "out": " - "},
    {"date": "2026-03-11", "name": "Jet Hinks", "id": "02000327643", "status": "Late", "in": "3:30 pm", "out": "7:00 pm"},
  ];

  List<Map<String, String>> _filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        bool matchesSearch = log["name"]!.toLowerCase().contains(_currentSearch.toLowerCase()) || 
                             log["id"]!.contains(_currentSearch);
        bool matchesDate = log["date"] == _currentDateFilter;
        return matchesSearch && matchesDate;
      }).toList();
    });
  }

  // --- ADDED: EXPORT LOGIC ---
  void _handleExport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 2000)), // Simulate file generation
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(color: stiNavy, strokeWidth: 3),
                    const SizedBox(height: 30),
                    const Text("EXPORTING LOGS", style: TextStyle(fontWeight: FontWeight.w900, color: stiNavy, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    Text("Compiling ${widget.subjectCode} data...", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 80),
                    const SizedBox(height: 20),
                    const Text("EXPORT SUCCESSFUL", style: TextStyle(fontWeight: FontWeight.bold, color: stiNavy)),
                    const SizedBox(height: 10),
                    const Text("Attendance report saved to downloads.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: stiNavy,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          InstructorSidebar(
            currentPage: "Attendance",
            onPageChanged: (index) => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                _buildStandardHeader("${widget.subjectCode} Attendance Logs"),
                _buildFilterHeader(),
                _buildActionRow(),
                Expanded(child: _buildTableCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardHeader(String title) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white, 
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(), 
            style: const TextStyle(color: stiNavy, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'serif'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: stiNavy),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Class: ${widget.subjectName}", 
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) { _currentSearch = v; _applyFilters(); },
                  decoration: const InputDecoration(
                    hintText: "Search student name...",
                    prefixIcon: Icon(Icons.search, size: 20, color: stiNavy),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 10)
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentDateFilter,
                    icon: const Icon(Icons.calendar_today_outlined, size: 18, color: stiNavy),
                    items: ["2026-03-09", "2026-03-10", "2026-03-11"].map((date) => DropdownMenuItem(
                      value: date, 
                      child: Text(DateFormat('MM/dd/yy').format(DateTime.parse(date)), style: const TextStyle(fontSize: 13))
                    )).toList(),
                    onChanged: (v) { setState(() { _currentDateFilter = v!; _applyFilters(); }); },
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildActionButton("VIEW REQUESTS", Icons.mail_outline_rounded, false),
          const SizedBox(width: 16),
          _buildActionButton("EXPORT REPORT", Icons.file_download_outlined, true),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, bool isPrimary) {
    return ElevatedButton.icon(
      onPressed: () {
        if (label == "VIEW REQUESTS") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceRequestsPage()));
        } else {
          // FIXED: Calls the handleExport function
          _handleExport();
        }
      },
      icon: Icon(icon, size: 18, color: isPrimary ? Colors.white : stiNavy),
      label: Text(label, style: TextStyle(color: isPrimary ? Colors.white : stiNavy, fontWeight: FontWeight.bold, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? stiNavy : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), 
          side: BorderSide(color: isPrimary ? Colors.transparent : stiNavy.withValues(alpha: 0.2))
        ),
      ),
    );
  }

  Widget _buildTableCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(32, 10, 32, 32),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: Column(children: [
        Container(
          height: 50,
          decoration: const BoxDecoration(
            color: tableHeaderColor, 
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            _cell("DATE", flex: 2, isHeader: true), 
            _cell("NAME", flex: 3, isHeader: true),
            _cell("STATUS", flex: 2, isHeader: true), 
            _cell("IN/OUT", flex: 2, isHeader: true),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _filteredLogs.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (ctx, i) => SizedBox(
              height: 60,
              child: Row(children: [
                _cell(DateFormat('MM/dd/yy').format(DateTime.parse(_filteredLogs[i]["date"]!)), flex: 2),
                _cell(_filteredLogs[i]["name"]!, flex: 3, isBold: true),
                _statusBadge(_filteredLogs[i]["status"]!, flex: 2),
                _cell("${_filteredLogs[i]["in"]} / ${_filteredLogs[i]["out"]}", flex: 2),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _cell(String text, {required int flex, bool isHeader = false, bool isBold = false}) {
    return Expanded(flex: flex, child: Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(
      fontSize: isHeader ? 10 : 12,
      fontWeight: (isHeader || isBold) ? FontWeight.w900 : FontWeight.normal,
      color: isHeader ? stiNavy : Colors.black87,
    ))));
  }

  Widget _statusBadge(String status, {required int flex}) {
    Color color = status == "Present" ? statusGreen : (status == "Absent" ? statusRed : statusOrange);
    return Expanded(flex: flex, child: Center(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 9)),
    )));
  }
}