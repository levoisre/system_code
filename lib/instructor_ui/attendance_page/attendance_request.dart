import 'package:flutter/material.dart';

class AttendanceRequestsPage extends StatefulWidget {
  const AttendanceRequestsPage({super.key});

  @override
  State<AttendanceRequestsPage> createState() => _AttendanceRequestsPageState();
}

class _AttendanceRequestsPageState extends State<AttendanceRequestsPage> {
  static const Color darkNavy = Color(0xFF000080);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color accentGreen = Color(0xFF43A047);
  static const Color accentRed = Color(0xFFE53935);

  String _selectedTab = "Pending";

  final List<Map<String, dynamic>> _requests = [
    {
      "id": 1, 
      "name": "Andrea Sy", 
      "date": "03/09/2026", 
      "category": "Medical", 
      "reason": "Severe flu and fever. Physician advised 3 days of rest to recover fully.", 
      "status": "Pending", 
      "doc": "medical_certificate_sy.jpg"
    },
    {
      "id": 2, 
      "name": "Tony Hugh", 
      "date": "03/10/2026", 
      "category": "Personal", 
      "reason": "Emergency family matter requiring immediate travel.", 
      "status": "Pending", 
      "doc": "excuse_letter_hugh.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Detect screen width
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 800;

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
          _buildFilterTabs(isDesktop),
          Expanded(
            child: filteredList.isEmpty 
              ? _buildEmptyState()
              : Center(
                  child: Container(
                    // Constrain width on desktop to prevent stretched cards
                    constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
                    child: ListView.builder(
                      padding: EdgeInsets.all(isDesktop ? 30 : 15),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) => _buildRequestCard(filteredList[index], isDesktop),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDesktop) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
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
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(isDesktop ? 25 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(request['name'], style: const TextStyle(fontWeight: FontWeight.w900, color: darkNavy, fontSize: 14))),
              Text(request['date'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text("Category: ${request['category']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 15),
          
          // Use Wrap instead of Row to handle small screens gracefully
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              InkWell(
                onTap: () => _showDigitalFormViewer(request, isDesktop),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_outlined, color: Colors.blue, size: 18),
                    SizedBox(width: 6),
                    Text("View Full Details", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.underline)),
                  ],
                ),
              ),
              if (_selectedTab == "Pending")
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionBtn("Reject", accentRed, () => _updateStatus(request['id'], "Rejected")),
                    const SizedBox(width: 10),
                    _actionBtn("Approve", accentGreen, () => _updateStatus(request['id'], "Approved")),
                  ],
                )
            ],
          ),
        ],
      ),
    );
  }

  void _showDigitalFormViewer(Map<String, dynamic> request, bool isDesktop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: darkNavy, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("STUDENT SUBMISSION FORM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.1)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 20), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
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
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                        child: Text(request['reason'], style: const TextStyle(fontSize: 13, height: 1.5)),
                      ),
                      const SizedBox(height: 20),
                      const Text("ATTACHED EVIDENCE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      _buildEvidenceBox(request['doc']),
                    ],
                  ),
                ),
              ),
              _buildDialogFooter(ctx, request, !isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceBox(String fileName) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withValues(alpha: 0.1))),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(fileName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkNavy))),
          const Icon(Icons.file_download_outlined, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDialogFooter(BuildContext ctx, Map<String, dynamic> request, bool stackButtons) {
    // Stack buttons on mobile to avoid overflow
    return Padding(
      padding: const EdgeInsets.all(20),
      child: stackButtons 
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: double.infinity, child: _dialogActionBtn("APPROVE", accentGreen, () { _updateStatus(request['id'], "Approved"); Navigator.pop(ctx); })),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: _dialogActionBtn("CLOSE", Colors.grey, () => Navigator.pop(ctx))),
            ],
          )
        : Row(
            children: [
              Expanded(child: _dialogActionBtn("CLOSE", Colors.grey, () => Navigator.pop(ctx))),
              const SizedBox(width: 12),
              Expanded(child: _dialogActionBtn("APPROVE", accentGreen, () { _updateStatus(request['id'], "Approved"); Navigator.pop(ctx); })),
            ],
          ),
    );
  }

  Widget _dialogActionBtn(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

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
      style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  void _updateStatus(int id, String newStatus) {
    setState(() {
      _requests.firstWhere((r) => r['id'] == id)['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request marked as $newStatus"), behavior: SnackBarBehavior.floating)
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