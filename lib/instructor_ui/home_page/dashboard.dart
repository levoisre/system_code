import 'package:flutter/material.dart';
import '../notification_page/notification.dart'; 

// Note: attendance_shell.dart and recitation_facilitator.dart imports removed 
// because navigation is now handled globally by InstructorIndex.

class InstructorDashboard extends StatefulWidget {
  final String subjectCode;
  final String subjectName;
  final Map<String, dynamic> courseData;

  const InstructorDashboard({
    super.key, 
    required this.subjectCode, 
    required this.subjectName,
    required this.courseData,
  });

  @override
  State<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends State<InstructorDashboard> {
  static const Color darkNavy = Color(0xFF0D125A);
  static const Color bgColor = Color(0xFFF8FAFC); 
  static const Color accentGreen = Color(0xFF43A047);
  static const Color accentRed = Color(0xFFE53935);

  bool _isActivated = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredStudents = []; 
  
  final String _attendancePercentage = "75%";
  final String _presentCount = "15/20 Present";
  final double _classAverage = 88.5; 

  @override
  void initState() {
    super.initState();
    _filteredStudents = widget.courseData['students'] ?? [];
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredStudents = (widget.courseData['students'] as List<dynamic>)
          .where((student) => student.toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      child: Column(
        children: [
          _buildMinimalHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  // --- TOP STAT CARDS ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildPopStatCard(
                          "Total Attendance", 
                          _attendancePercentage, 
                          _presentCount, 
                          accentGreen,
                          () { /* Logic handled by sidebar navigation */ },
                        )
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildPopStatCard(
                          "Class Average Score", 
                          "${_classAverage.toInt()}%", 
                          "Grade: A-", 
                          Colors.purple,
                          () { /* Logic handled by sidebar navigation */ },
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // --- ROSTER AND ACTIVATION ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildPopRosterCard()),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildPopActivationCard()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // --- SYSTEM ACTION BUTTONS ---
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text("Courses", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ),
              Text(
                widget.subjectName.toUpperCase(),
                style: const TextStyle(color: darkNavy, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'serif'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: darkNavy, size: 24),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildPopStatCard(String title, String value, String subtitle, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: darkNavy, fontWeight: FontWeight.w800)),
              ])),
              Container(
                height: 52, width: 52, 
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), 
                child: Center(child: Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 14)))
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildPopRosterCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15)]
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("CLASS ROSTER", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: darkNavy)),
          Container(
            width: 180, height: 40,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _searchController, 
              onChanged: _onSearchChanged, 
              decoration: const InputDecoration(
                hintText: "Search...", 
                prefixIcon: Icon(Icons.search, size: 18), 
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 8)
              )
            ),
          ),
        ]),
        const Divider(height: 40),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filteredStudents.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 20),
            itemBuilder: (ctx, i) => Column(children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFF1F5F9), 
                child: Icon(Icons.person, color: darkNavy)
              ),
              const SizedBox(height: 8),
              Text(
                _filteredStudents[i].toString().split(' ')[0], 
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildPopActivationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15)],
        border: Border.all(color: _isActivated ? accentGreen : Colors.transparent, width: 2),
      ),
      child: Column(children: [
        const Text("HOTSPOT STATUS", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: darkNavy)),
        const SizedBox(height: 20),
        Icon(Icons.wifi_tethering_rounded, color: _isActivated ? accentGreen : Colors.grey[300], size: 60),
        const SizedBox(height: 10),
        Text(
          _isActivated ? "SYSTEM LIVE" : "SYSTEM IDLE", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: _isActivated ? accentGreen : Colors.grey)
        ),
      ]),
    );
  }

  Widget _buildBottomActions() {
    return Row(children: [
      Expanded(child: _actionBtn("ACTIVATE", Icons.bolt_rounded, _isActivated ? Colors.grey : accentGreen, () => setState(() => _isActivated = true))),
      const SizedBox(width: 24),
      Expanded(child: _actionBtn("INACTIVATE", Icons.power_settings_new_rounded, !_isActivated ? Colors.grey : accentRed, () => setState(() => _isActivated = false))),
    ]);
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback tap) {
    return SizedBox(
      height: 56, 
      child: ElevatedButton.icon(
        onPressed: tap, 
        icon: Icon(icon, color: Colors.white), 
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        style: ElevatedButton.styleFrom(
          backgroundColor: color, 
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
        )
      )
    );
  }
}