import 'package:flutter/material.dart';
import '../notification_page/notification.dart'; 

class GradesManagementPage extends StatefulWidget {
  final String subjectCode;
  final String subjectName;

  const GradesManagementPage({
    super.key,
    required this.subjectCode,
    required this.subjectName,
  });

  @override
  State<GradesManagementPage> createState() => _GradesManagementPageState();
}

class _GradesManagementPageState extends State<GradesManagementPage> {
  static const Color stiNavy = Color(0xFF000080);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color tableHeaderColor = Color(0xFFF1F5F9);
  static const Color progressGreen = Color(0xFFE8F5E9);
  static const Color progressText = Color(0xFF2E7D32);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedDate = "03/09/26";

  final List<Map<String, dynamic>> _allGrades = [
    {"name": "Garcia, Maria", "q1": "20/20", "q2": "12/15", "q3": "24/25", "points": "6870 pts", "progress": "87%", "date": "03/09/26"},
    {"name": "Hinks, Jet", "q1": "14/20", "q2": "12/15", "q3": "15/25", "points": "5780 pts", "progress": "85%", "date": "03/09/26"},
    {"name": "Hugh, Tony", "q1": "16/20", "q2": "13/15", "q3": "16/25", "points": "5270 pts", "progress": "83%", "date": "03/10/26"},
    {"name": "Johnson, Alex", "q1": "19/20", "q2": "8/15", "q3": "7/25", "points": "8340 pts", "progress": "86%", "date": "03/09/26"},
    {"name": "Labrusco, Pacita", "q1": "12/20", "q2": "15/15", "q3": "25/25", "points": "2570 pts", "progress": "89%", "date": "03/11/26"},
    {"name": "Pru, Sam", "q1": "14/20", "q2": "15/15", "q3": "14/25", "points": "4790 pts", "progress": "84%", "date": "03/10/26"},
    {"name": "Sy, Andrea", "q1": "10/20", "q2": "10/15", "q3": "18/25", "points": "3840 pts", "progress": "81%", "date": "03/09/26"},
  ];

  List<Map<String, dynamic>> _filteredGrades = [];

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
      _filteredGrades = _allGrades.where((item) {
        final matchesName = item['name'].toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesDate = item['date'] == _selectedDate;
        return matchesName && matchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 750;

      return Material(
        color: bgColor,
        child: Column(
          children: [
            _buildStandardHeader("${widget.subjectCode} Grades", isMobile),
            _buildFilterHeader(isMobile),
            _buildActionRow(isMobile),
            Expanded(
              child: isMobile ? _buildMobileListView() : _buildTableCard(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStandardHeader(String title, bool isMobile) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: stiNavy,
                fontWeight: FontWeight.w900,
                fontSize: isMobile ? 12 : 14,
                fontFamily: 'serif',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: stiNavy),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, 24, isMobile ? 16 : 32, 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("CURRENT SUBJECT: ${widget.subjectName}", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1.1)),
          const SizedBox(height: 12),
          isMobile 
          ? Column(
              children: [
                _buildSearchBox(),
                const SizedBox(height: 12),
                _buildDatePicker(isMobile),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 3, child: _buildSearchBox()),
                const SizedBox(width: 20),
                const Text("Date Filter", style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 12),
                _buildDatePicker(isMobile),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 44,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _searchQuery = value;
          _applyFilters();
        },
        decoration: const InputDecoration(
          hintText: "Search Student Name...",
          prefixIcon: Icon(Icons.search, size: 20, color: stiNavy),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10)
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isMobile) {
    return Container(
      height: 44,
      width: isMobile ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: isMobile,
          value: _selectedDate,
          icon: const Icon(Icons.calendar_today_outlined, size: 16, color: stiNavy),
          items: ["03/09/26", "03/10/26", "03/11/26"].map((String date) {
            return DropdownMenuItem(value: date, child: Text(date, style: const TextStyle(fontSize: 13)));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedDate = newValue);
              _applyFilters();
            }
          },
        ),
      ),
    );
  }

  Widget _buildActionRow(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.end,
        children: [
          Expanded(
            flex: isMobile ? 1 : 0,
            child: ElevatedButton.icon(
              onPressed: () => _showExportDialog(),
              icon: const Icon(Icons.file_download_outlined, size: 18, color: Colors.white),
              label: const Text("EXPORT REPORT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: stiNavy,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileListView() {
    if (_filteredGrades.isEmpty) {
      return const Center(child: Text("No records found.", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredGrades.length,
      itemBuilder: (context, index) {
        final item = _filteredGrades[index];
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: stiNavy))),
                    _progressBadge(item['progress'], isCentered: false),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _mobileStat("Q1", item['q1']),
                    _mobileStat("Q2", item['q2']),
                    _mobileStat("Q3", item['q3']),
                    _mobileStat("TOTAL", item['points']),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mobileStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
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
            _cell("STUDENT NAME", flex: 3, isHeader: true),
            _cell("QUIZ 1", flex: 2, isHeader: true),
            _cell("QUIZ 2", flex: 2, isHeader: true),
            _cell("QUIZ 3", flex: 2, isHeader: true),
            _cell("POINTS", flex: 3, isHeader: true),
            _cell("PROGRESS", flex: 2, isHeader: true),
          ]),
        ),
        Expanded(
          child: _filteredGrades.isEmpty 
          ? const Center(child: Text("No records found.", style: TextStyle(color: Colors.grey)))
          : ListView.separated(
            itemCount: _filteredGrades.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (ctx, i) => SizedBox(
              height: 60,
              child: Row(children: [
                _cell(_filteredGrades[i]["name"], flex: 3),
                _cell(_filteredGrades[i]["q1"], flex: 2),
                _cell(_filteredGrades[i]["q2"], flex: 2),
                _cell(_filteredGrades[i]["q3"], flex: 2),
                _cell(_filteredGrades[i]["points"], flex: 3),
                _progressBadge(_filteredGrades[i]["progress"], isCentered: true, flex: 2),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _cell(String? text, {required int flex, bool isHeader = false}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isHeader ? 10 : 12,
            fontWeight: isHeader ? FontWeight.w900 : FontWeight.normal,
            color: isHeader ? stiNavy : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _progressBadge(String value, {bool isCentered = true, int flex = 1}) {
    Widget badge = Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: progressGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(color: progressText, fontWeight: FontWeight.w900, fontSize: 10),
      ),
    );

    if (isCentered) {
      return Expanded(flex: flex, child: Center(child: badge));
    }
    return badge;
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 2500)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(color: stiNavy, strokeWidth: 3),
                    const SizedBox(height: 30),
                    const Text("GENERATING REPORT", style: TextStyle(fontWeight: FontWeight.w900, color: stiNavy, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    const Text("Compiling grade history...", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                    const Text("DOWNLOAD COMPLETE", style: TextStyle(fontWeight: FontWeight.bold, color: stiNavy)),
                    const SizedBox(height: 10),
                    const Text("Grade report saved locally.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: stiNavy,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
}