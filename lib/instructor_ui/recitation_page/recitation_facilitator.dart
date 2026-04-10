import 'package:flutter/material.dart';
import 'dart:math';
import '../notification_page/notification.dart';

class RecitationFacilitatorPage extends StatefulWidget {
  final String subjectCode;
  final String subjectName;

  const RecitationFacilitatorPage({
    super.key,
    required this.subjectCode,
    required this.subjectName,
  });

  @override
  State<RecitationFacilitatorPage> createState() => _RecitationFacilitatorPageState();
}

class _RecitationFacilitatorPageState extends State<RecitationFacilitatorPage> {
  // Branded Colors
  static const Color stiNavy = Color(0xFF000080);
  static const Color stiGold = Color(0xFFFFC72C);
  static const Color bgColor = Color(0xFFF8FAFC);

  // Subject-Specific Rosters
  final Map<String, List<String>> _subjectRosters = {
    "CPE 401": ["Alex Johnson", "Maria Garcia", "Tony Hugh", "Jet Hinks", "Samuel Pru"],
    "AI 302": ["Andrea Sy", "Pacita Labrusco", "Kevin Lee", "Cynthia Villar", "Robert Fox"],
  };

  List<String> get _currentStudents => _subjectRosters[widget.subjectCode] ?? [];

  final Map<String, int> _sessionGrades = {};
  String? _selectedStudent;
  bool _isSpinning = false;

  double get _sessionAverage {
    if (_sessionGrades.isEmpty) return 0.0;
    int total = _sessionGrades.values.reduce((a, b) => a + b);
    return total / _sessionGrades.length;
  }

  void _pickRandomStudent() async {
    if (_currentStudents.isEmpty) return;

    setState(() {
      _isSpinning = true;
      _selectedStudent = null;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _selectedStudent = _currentStudents[Random().nextInt(_currentStudents.length)];
      _isSpinning = false;
    });

    if (_selectedStudent != null) {
      _showGradingDialog(_selectedStudent!);
    }
  }

  void _showGradingDialog(String studentName) {
    int selectedStars = _sessionGrades[studentName] ?? 0;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Container(
                padding: const EdgeInsets.all(32),
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: stiGold, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "RECITATION PERFORMANCE: ${widget.subjectCode}",
                      style: TextStyle(
                        color: stiNavy.withValues(alpha: 0.5),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      studentName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: stiNavy),
                    ),
                    const Divider(height: 40),
                    const Text("Assign Points", style: TextStyle(fontWeight: FontWeight.bold, color: stiNavy)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () => setDialogState(() => selectedStars = index + 1),
                          icon: Icon(
                            index < selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: index < selectedStars ? stiGold : Colors.grey[300],
                            size: 42,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: commentController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Add a quick note...",
                        hintStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: bgColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedStars == 0 ? null : () {
                              setState(() => _sessionGrades[studentName] = selectedStars);
                              Navigator.pop(context);
                              _showSuccessMessage(studentName, selectedStars);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: stiNavy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                            ),
                            child: const Text("SUBMIT GRADE", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessMessage(String name, int grade) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: stiNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(24),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: stiGold, size: 20),
            const SizedBox(width: 12),
            Text("Grade of $grade stars recorded for $name", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Wrapped in Material to fix text styling errors (Red/Underlined text)
    return Material(
      color: bgColor,
      child: Column(
        children: [
          _buildStandardHeader("${widget.subjectCode} Recitation"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(),
            style: const TextStyle(color: stiNavy, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'serif')),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: stiNavy),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage())),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: stiNavy.withValues(alpha: 0.05), blurRadius: 30)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSpinning)
                  const CircularProgressIndicator(color: stiNavy, strokeWidth: 5)
                else if (_selectedStudent != null) ...[
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: stiNavy,
                    child: Icon(Icons.person, color: Colors.white, size: 50),
                  ),
                  const SizedBox(height: 24),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(_selectedStudent!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: stiNavy)),
                    ),
                  ),
                  const Text("IS UP NEXT!", style: TextStyle(letterSpacing: 2, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => _showGradingDialog(_selectedStudent!),
                    icon: const Icon(Icons.star_outline_rounded, size: 18, color: stiNavy),
                    label: const Text("UPDATE GRADE", style: TextStyle(color: stiNavy, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
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
        SizedBox(
          width: 300,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _isSpinning ? null : _pickRandomStudent,
            icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            label: const Text("RANDOM SELECTION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: stiNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: stiNavy, borderRadius: BorderRadius.circular(20)),
                child: Text("AVG: ${_sessionAverage.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const Divider(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _currentStudents.length,
              itemBuilder: (context, i) {
                String name = _currentStudents[i];
                bool isPicked = _selectedStudent == name;
                bool hasGrade = _sessionGrades.containsKey(name);
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
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: isPicked ? stiNavy : Colors.grey[300],
                        child: Text("${i + 1}", style: const TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      // Text color added specifically to student name to ensure visibility
                      Text(name, style: TextStyle(fontWeight: isPicked ? FontWeight.bold : FontWeight.normal, color: isPicked ? stiNavy : Colors.black87)),
                      const Spacer(),
                      if (hasGrade) 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: stiGold, borderRadius: BorderRadius.circular(8)),
                          child: Text("★ ${_sessionGrades[name]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stiNavy)),
                        )
                      else if (isPicked) 
                        const Icon(Icons.check_circle, color: stiNavy, size: 18),
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