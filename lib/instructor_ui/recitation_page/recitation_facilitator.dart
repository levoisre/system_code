import 'package:flutter/material.dart';
import 'recitation_service.dart';
import '../notification_page/notification.dart';

class RecitationFacilitatorPage extends StatefulWidget {
  final String subjectCode;
  final String subjectName;

  const RecitationFacilitatorPage({super.key, required this.subjectCode, required this.subjectName});

  @override
  State<RecitationFacilitatorPage> createState() => _RecitationFacilitatorPageState();
}

class _RecitationFacilitatorPageState extends State<RecitationFacilitatorPage> {
  static const Color stiNavy = Color(0xFF000080);
  static const Color stiGold = Color(0xFFFFC72C);
  static const Color bgColor = Color(0xFFF8FAFC);

  String? _selectedStudent;
  bool _isSpinning = false;
  List<dynamic> _currentStats = [];

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  Future<void> _refreshStats() async {
    final stats = await RecitationService.getSessionStats(widget.subjectCode);
    if (!mounted) return;
    setState(() => _currentStats = stats);
  }

  void _pickRandomStudent() async {
    if (_currentStats.isEmpty) return;
    setState(() { _isSpinning = true; _selectedStudent = null; });

    List<String> present = _currentStats.map((e) => e['name'].toString()).toList();
    String? result = await RecitationService.pickStudent(widget.subjectCode, present);

    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (!mounted) return;
    
    setState(() { 
      _selectedStudent = result; 
      _isSpinning = false; 
    });
    
    if (_selectedStudent != null) _showGradingDialog(_selectedStudent!);
  }

  void _showGradingDialog(String studentName) {
    int selectedStars = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            padding: const EdgeInsets.all(32),
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: stiGold, size: 48),
                const SizedBox(height: 12),
                Text(studentName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: stiNavy)),
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => IconButton(
                    onPressed: () => setDialogState(() => selectedStars = index + 1),
                    icon: Icon(index < selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: index < selectedStars ? stiGold : Colors.grey[300], size: 42),
                  )),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: selectedStars == 0 ? null : () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    final bool ok = await RecitationService.submitGrade(studentName, widget.subjectCode, selectedStars);
                    
                    if (!mounted) return;

                    if (ok) {
                      navigator.pop(); 
                      _refreshStats();
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Submission failed. Please try again.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: stiNavy, 
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("SUBMIT GRADE"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Session?"),
        content: const Text("This will clear all points and stars for this class session. This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () async {
              // Capture navigation and messenger before the async call
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              bool ok = await RecitationService.resetSession(widget.subjectCode);
              
              if (!mounted) return;

              if (ok) {
                navigator.pop(); // Close the dialog
                await _refreshStats(); // Wait for data to update
                setState(() { 
                  _selectedStudent = null; // Clear the spotlight
                });
                messenger.showSnackBar(
                  const SnackBar(content: Text("Session reset successfully.")),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text("Reset failed. Check server connection.")),
                );
              }
            },
            child: const Text("RESET", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildStandardHeader("${widget.subjectCode} Recitation"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _buildSpotlightSection()),
                  const SizedBox(width: 32),
                  Expanded(flex: 2, child: _buildRosterPanel()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardHeader(String title) {
    return Container(
      height: 80, padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: stiNavy, fontWeight: FontWeight.w900, fontSize: 14)),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: stiNavy), 
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
            }
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightSection() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: stiNavy.withValues(alpha: 0.05), blurRadius: 30)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSpinning) const CircularProgressIndicator(color: stiNavy, strokeWidth: 5)
                else if (_selectedStudent != null) ...[
                  const CircleAvatar(radius: 50, backgroundColor: stiNavy, child: Icon(Icons.person, color: Colors.white, size: 50)),
                  const SizedBox(height: 24),
                  Text(_selectedStudent!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: stiNavy)),
                  const Text("IS UP NEXT!", style: TextStyle(letterSpacing: 2, color: Colors.grey, fontWeight: FontWeight.bold)),
                ] else ...[
                  const Icon(Icons.casino_outlined, color: stiNavy, size: 80),
                  const SizedBox(height: 16),
                  const Text("READY TO ROLL?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.grey)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(width: 300, height: 54,
          child: ElevatedButton.icon(
            onPressed: _isSpinning ? null : _pickRandomStudent,
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            label: const Text("RANDOM SELECTION"),
            style: ElevatedButton.styleFrom(backgroundColor: stiNavy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          ),
        ),
      ],
    );
  }

  Widget _buildRosterPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("SESSION STATS", style: TextStyle(fontWeight: FontWeight.bold, color: stiNavy, fontSize: 12)),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.grey),
                tooltip: "Reset Session",
                onPressed: _confirmReset,
              ),
            ],
          ),
          const Divider(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _currentStats.length,
              itemBuilder: (context, i) {
                var data = _currentStats[i];
                bool isPicked = _selectedStudent == data['name'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPicked ? stiNavy.withValues(alpha: 0.1) : bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isPicked ? stiNavy : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 15, backgroundColor: isPicked ? stiNavy : Colors.grey[300], child: Text("${i + 1}", style: const TextStyle(fontSize: 10, color: Colors.white))),
                      const SizedBox(width: 12),
                      Text(data['name'], style: TextStyle(color: isPicked ? stiNavy : Colors.black87, fontWeight: isPicked ? FontWeight.bold : FontWeight.normal)),
                      const Spacer(),
                      if (data['total_points'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: stiGold, borderRadius: BorderRadius.circular(8)),
                          child: Text("★ ${data['total_points'] ~/ 10}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stiNavy)),
                        )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}