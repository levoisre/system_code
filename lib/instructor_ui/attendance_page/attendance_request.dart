import 'package:flutter/material.dart';

class AttendanceRequestsPage extends StatefulWidget {
  const AttendanceRequestsPage({super.key});

  @override
  State<AttendanceRequestsPage> createState() => _AttendanceRequestsPageState();
}

class _AttendanceRequestsPageState extends State<AttendanceRequestsPage> {
  // Theme Colors - Unified with Dashboard
  static const Color darkNavy = Color(0xFF000080);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color accentGreen = Color(0xFF43A047);
  static const Color accentRed = Color(0xFFE53935);

  String _selectedTab = "Pending";

  // Mock Data: This simulates what students have submitted via their interface
  final List<Map<String, dynamic>> _requests = [
    {
      "id": 1, 
      "name": "Andrea Sy", 
      "date": "03/09/2026", 
      "category": "Medical", 
      "reason": "Severe flu and fever. Physician advised 3 days of rest to recover fully and avoid spreading the illness.", 
      "status": "Pending", 
      "doc": "medical_certificate_sy.jpg"
    },
    {
      "id": 2, 
      "name": "Tony Hugh", 
      "date": "03/10/2026", 
      "category": "Personal", 
      "reason": "Emergency family matter requiring immediate travel. I will catch up on missed laboratory activities.", 
      "status": "Pending", 
      "doc": "excuse_letter_hugh.png"
    },
    {
      "id": 3, 
      "name": "Alex Johnson", 
      "date": "03/05/2026", 
      "category": "School Event", 
      "reason": "Representing the college in the Inter-school IT Olympics. Required to be on-site for the competition.", 
      "status": "Approved", 
      "doc": "event_permit.pdf"
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredList = 
        _requests.where((r) => r['status'] == _selectedTab).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("EXCUSE REQUESTS", 
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'serif')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: filteredList.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(25),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) => _buildRequestCard(filteredList[index]),
                ),
          ),
        ],
      ),
    );
  }

  // --- UI: TOP TABS ---
  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ["Pending", "Approved", "Rejected"].map((tab) {
          bool isSelected = _selectedTab == tab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = tab),
            child: Column(
              children: [
                Text(tab, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? darkNavy : Colors.grey, fontSize: 13)),
                const SizedBox(height: 5),
                Container(height: 3, width: 40, color: isSelected ? darkNavy : Colors.transparent),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- UI: REQUEST LIST CARD ---
  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(request['name'], style: const TextStyle(fontWeight: FontWeight.w900, color: darkNavy, fontSize: 14)),
              Text(request['date'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text("Category: ${request['category']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 15),
          Row(
            children: [
              InkWell(
                onTap: () => _showDigitalFormViewer(request),
                child: const Row(
                  children: [
                    Icon(Icons.visibility_outlined, color: Colors.blue, size: 18),
                    SizedBox(width: 6),
                    Text("View Full Details", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.underline)),
                  ],
                ),
              ),
              const Spacer(),
              if (_selectedTab == "Pending") ...[
                _actionBtn("Reject", accentRed, () => _updateStatus(request['id'], "Rejected")),
                const SizedBox(width: 10),
                _actionBtn("Approve", accentGreen, () => _updateStatus(request['id'], "Approved")),
              ]
            ],
          ),
        ],
      ),
    );
  }

  // --- UI: DIGITAL FORM OVERLAY (FIXED OVERFLOW) ---
  void _showDigitalFormViewer(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 500,
          // Constrain height to 80% of screen to prevent overflows
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FIXED HEADER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: darkNavy, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("STUDENT SUBMISSION FORM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 20), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),

              // SCROLLABLE BODY
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormRow("Student", request['name']),
                      _buildFormRow("Date Requested", request['date']),
                      _buildFormRow("Excuse Category", request['category']),
                      const Divider(height: 32),
                      const Text("EXPLANATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
                        child: Text(request['reason'], style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
                      ),
                      const SizedBox(height: 20),
                      const Text("ATTACHED EVIDENCE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: bgColor, 
                          borderRadius: BorderRadius.circular(12), 
                          border: Border.all(color: darkNavy.withValues(alpha: 0.1))
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_outlined, color: Colors.blue, size: 30),
                            const SizedBox(height: 8),
                            Text(request['doc'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: darkNavy)),
                            const Text("Evidence verified by student", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // FIXED FOOTER
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("CLOSE", style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () { _updateStatus(request['id'], "Approved"); Navigator.pop(ctx); },
                        style: ElevatedButton.styleFrom(backgroundColor: accentGreen, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("APPROVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildFormRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkNavy)),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  void _updateStatus(int id, String newStatus) {
    setState(() {
      _requests.firstWhere((r) => r['id'] == id)['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excuse request has been $newStatus"), behavior: SnackBarBehavior.floating)
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          Text("No $_selectedTab requests found.", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}