import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
// Ensure this import matches your actual file name: attendance_request.dart
import 'attendance_request.dart'; 

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  // Theme Colors
  static const Color darkNavy = Color(0xFF000080);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color tableHeaderColor = Color(0xFFF1F5F9);
  static const Color statusGreen = Color(0xFF43A047);
  static const Color statusRed = Color(0xFFE53935);
  static const Color statusOrange = Color(0xFFFB8C00);

  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, String>> _allLogs = [
    {"date": "2026-03-09", "name": "Alex Johnson", "id": "020004567992", "status": "Present", "in": "1:30 pm", "out": "7:00 pm"},
    {"date": "2026-03-09", "name": "Maria Garcia", "id": "02000874933", "status": "Present", "in": "1:30 pm", "out": "7:00 pm"},
    {"date": "2026-03-09", "name": "Andrea Sy", "id": "02000446739", "status": "Present", "in": "1:30 pm", "out": "7:00 pm"},
    {"date": "2026-03-10", "name": "Tony Hugh", "id": "02000983643", "status": "Absent", "in": " - ", "out": " - "},
    {"date": "2026-03-10", "name": "Jet Hinks", "id": "02000327643", "status": "Late", "in": "3:30 pm", "out": "7:00 pm"},
    {"date": "2026-03-11", "name": "Pacita Labrusco", "id": "020002786394", "status": "Late", "in": "1:50 pm", "out": "7:00 pm"},
    {"date": "2026-03-12", "name": "Sam Pru", "id": "02000397346", "status": "Absent", "in": " - ", "out": " - "},
  ];

  List<Map<String, String>> _filteredLogs = [];
  String _currentSearch = "";
  String _currentDateFilter = "2026-03-09"; 

  @override
  void initState() {
    super.initState();
    _applyFilters();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildFilterHeader(),
          _buildActionRow(),
          const SizedBox(height: 10),
          Expanded(child: _buildTableCard()),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 12),
      color: Colors.white,
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 44,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _searchController,
              onChanged: (v) { _currentSearch = v; _applyFilters(); },
              decoration: const InputDecoration(
                hintText: "Search student name or ID...",
                prefixIcon: Icon(Icons.search, size: 20, color: darkNavy),
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
                icon: const Icon(Icons.calendar_month_outlined, size: 18, color: darkNavy),
                items: ["2026-03-09", "2026-03-10", "2026-03-11", "2026-03-12"].map((date) {
                  return DropdownMenuItem(
                    value: date, 
                    child: Text(DateFormat('MM/dd/yy').format(DateTime.parse(date)), style: const TextStyle(fontSize: 13))
                  );
                }).toList(),
                onChanged: (v) { _currentDateFilter = v!; _applyFilters(); },
              ),
            ),
          ),
        ),
      ]),
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
      onPressed: () => _handleBtnPress(label),
      icon: Icon(icon, size: 18, color: isPrimary ? Colors.white : darkNavy),
      label: Text(label, style: TextStyle(color: isPrimary ? Colors.white : darkNavy, fontWeight: FontWeight.bold, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? darkNavy : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), 
          side: BorderSide(color: isPrimary ? Colors.transparent : darkNavy.withValues(alpha: 0.2))
        ),
      ),
    );
  }

  void _handleBtnPress(String action) {
    if (action == "VIEW REQUESTS") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AttendanceRequestsPage()),
      );
    } else if (action == "EXPORT REPORT") {
      _showExportDialog();
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              FutureBuilder(
                future: Future.delayed(const Duration(seconds: 2)),
                builder: (context, snapshot) {
                  bool isDone = snapshot.connectionState == ConnectionState.done;
                  return Column(
                    children: [
                      if (!isDone)
                        const CircularProgressIndicator(color: darkNavy, strokeWidth: 3)
                      else
                        const Icon(Icons.check_circle_outline_rounded, size: 60, color: statusGreen),
                      const SizedBox(height: 25),
                      Text(
                        isDone ? "DOWNLOAD COMPLETE" : "GENERATING REPORT",
                        style: const TextStyle(fontWeight: FontWeight.w900, color: darkNavy, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isDone 
                            ? "Attendance_Report_March.pdf saved." 
                            : "Compiling student logs for export...",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (isDone) ...[
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkNavy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ]
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(32, 10, 32, 32),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 20, offset: Offset(0, 5))]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: [
          Container(
            height: 50,
            color: tableHeaderColor,
            child: Row(children: [
              _cell("DATE", flex: 2, isHeader: true), _cell("STUDENT NAME", flex: 3, isHeader: true),
              _cell("STUDENT ID", flex: 2, isHeader: true), _cell("STATUS", flex: 2, isHeader: true),
              _cell("IN", flex: 1, isHeader: true), _cell("OUT", flex: 1, isHeader: true),
            ]),
          ),
          Expanded(
            child: _filteredLogs.isEmpty 
              ? const Center(child: Text("No records found.", style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  itemCount: _filteredLogs.length,
                  separatorBuilder: (ctx, i) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                  itemBuilder: (ctx, i) => _buildRow(_filteredLogs[i]),
                ),
          ),
        ]),
      ),
    );
  }

  Widget _buildRow(Map<String, String> log) {
    return SizedBox(
      height: 60,
      child: Row(children: [
        _cell(DateFormat('MM/dd/yy').format(DateTime.parse(log["date"]!)), flex: 2),
        _cell(log["name"]!, flex: 3, isBold: true),
        _cell(log["id"]!, flex: 2),
        _statusBadge(log["status"]!, flex: 2),
        _cell(log["in"]!, flex: 1),
        _cell(log["out"]!, flex: 1),
      ]),
    );
  }

  Widget _cell(String text, {required int flex, bool isHeader = false, bool isBold = false}) {
    return Expanded(flex: flex, child: Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(
      fontSize: isHeader ? 10 : 12,
      fontWeight: (isHeader || isBold) ? FontWeight.w900 : FontWeight.normal,
      color: isHeader ? darkNavy : Colors.black87,
      letterSpacing: isHeader ? 1.0 : 0
    ))));
  }

  Widget _statusBadge(String status, {required int flex}) {
    Color color = status == "Present" ? statusGreen : (status == "Absent" ? statusRed : statusOrange);
    return Expanded(flex: flex, child: Center(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 9)),
    )));
  }
}