import 'dart:math';
import 'package:flutter/material.dart';

class RecitationFacilitator extends StatefulWidget {
  const RecitationFacilitator({super.key});

  @override
  State<RecitationFacilitator> createState() => _RecitationFacilitatorState();
}

class _RecitationFacilitatorState extends State<RecitationFacilitator> {
  static const Color darkNavy = Color(0xFF1B1E2F);
  static const Color lightGrey = Color(0xFFE8E8E8);

  double _recitationPoints = 70.0;
  String _selectedStudent = "Alex Johnson";
  String _studentLevel = "LEVEL 7";

  final List<Map<String, String>> _students = [
    {"name": "Alex Johnson", "level": "LEVEL 7"},
    {"name": "Maria Garcia", "level": "LEVEL 5"},
    {"name": "Tony Hugh", "level": "LEVEL 8"},
  ];

  void _rollDice() {
    final random = Random();
    setState(() {
      int index = random.nextInt(_students.length);
      _selectedStudent = _students[index]['name']!;
      _studentLevel = _students[index]['level']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            // LEFT PANEL - FIXED WITH SCROLL TO PREVENT OVERFLOW
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text("STUDENT SELECTED", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'serif')),
                      const SizedBox(height: 15),
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: lightGrey,
                        child: Icon(Icons.person_outline, size: 50, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Text(_selectedStudent, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(20)),
                        child: Text(_studentLevel, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                      _buildPointsScaler(),
                      const SizedBox(height: 20),
                      // DICE BUTTON
                      GestureDetector(
                        onTap: _rollDice,
                        child: Container(
                          height: 55, width: 120,
                          decoration: BoxDecoration(color: darkNavy, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.casino_outlined, color: Colors.white, size: 35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            // RIGHT PANEL
            Expanded(flex: 2, child: _buildLeaderboard()),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsScaler() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("RECITATION POINTS SCALER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          const Divider(color: Colors.black, height: 1),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Align(alignment: Alignment.centerRight, child: Text("${_recitationPoints.toInt()}/100", style: const TextStyle(fontSize: 12))),
                Slider(
                  value: _recitationPoints,
                  max: 100,
                  activeColor: Colors.red,
                  onChanged: (val) => setState(() => _recitationPoints = val),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: darkNavy, padding: const EdgeInsets.symmetric(horizontal: 30)),
                  child: const Text("CONFIRM GRADE", style: TextStyle(color: Colors.white, fontSize: 9)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black)),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.emoji_events_outlined, size: 20), SizedBox(width: 8), Text("DAILY LEAD BOARD", style: TextStyle(fontWeight: FontWeight.bold))]),
          const Divider(),
          const Expanded(child: Center(child: Text("Leaderboard Data..."))),
        ],
      ),
    );
  }
}