import 'package:flutter/material.dart';
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/assessment_result.dart';
import 'package:smart_classroom_facilitator_project/student_ui/assessment_page/assessments_list.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const Color darkNavy = Color(0xFF0C1446);
  bool isReadSelected = false;
  String selectedMonthLabel = "March 2026";

  // --- MOCK DATA ---
  final List<Map<String, dynamic>> allNotifications = [
    {
      "date": "March 9, 2026",
      "text": "The class assessment is over. Your score of 34/40 placed you at Rank #4 overall. Great job!",
      "isRead": true,
      "type": "result"
    },
    {
      "date": "March 9, 2026",
      "text": "Final 2 Minutes! 3 questions remaining. Don't forget to lock in your answers.",
      "isRead": false,
      "type": "alert"
    },
    {
      "date": "March 8, 2026",
      "text": "Your Turn! Professor has selected you for the current recitation. Prepare to speak!",
      "isRead": false,
      "type": "recitation"
    },
  ];

  // --- 1. UPDATED DATE PICKER (Now linked to Month Selector) ---
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 3, 9),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: darkNavy),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        selectedMonthLabel = "${_getMonthName(picked.month)} ${picked.year}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Showing notifications for $selectedMonthLabel")),
      );
    }
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "March", "April", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  // --- 2. CLICK HANDLER WITH ASYNC GAP FIX ---
  void _handleNotificationTap(Map<String, dynamic> notification) {
    setState(() {
      notification['isRead'] = true;
    });

    String type = notification['type'] ?? "";
    String message = (notification['text'] ?? "").toLowerCase();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return; // Safety check for BuildContext

      if (type == "result" || message.contains("quiz")) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuizResultsScreen(quizTitle: "Quiz 3 Results")),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AssessmentPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayList = allNotifications.where((n) => n['isRead'] == isReadSelected).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'NOTIFICATIONS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'serif'),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildToggleSwitch(),
          const SizedBox(height: 20),
          
          // Month Selector (NOW CLICKABLE)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Align(
              alignment: Alignment.centerRight, 
              child: GestureDetector(
                onTap: _selectDate,
                child: _buildMonthSelector(),
              )
            ),
          ),
          
          const SizedBox(height: 15),

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black12),
              ),
              child: displayList.isEmpty 
                ? const Center(child: Text("No notifications found."))
                : ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      bool showHeader = index == 0 || displayList[index-1]['date'] != item['date'];
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FIXED: Headers are now simple and non-clickable
                          if (showHeader) _dateHeader(item['date']),
                          _buildClickableNotification(item),
                        ],
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildClickableNotification(Map<String, dynamic> item) {
    bool isRead = item['isRead'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNotificationTap(item),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isRead ? Colors.white : darkNavy.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isRead ? Colors.black12 : darkNavy.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  isRead ? Icons.verified_outlined : Icons.mark_email_unread_outlined, 
                  color: isRead ? Colors.black54 : darkNavy, 
                  size: 20
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['text'],
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.black87, 
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54, fontFamily: 'serif')
          ),
          const Divider(thickness: 1, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      width: 240, height: 40,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.black26)),
      child: Row(
        children: [
          _toggleBtn("UNREAD", !isReadSelected),
          _toggleBtn("READ", isReadSelected),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isReadSelected = label == "READ"),
        child: Container(
          decoration: BoxDecoration(color: active ? darkNavy : Colors.transparent, borderRadius: BorderRadius.circular(25)),
          child: Center(
            child: Text(label, style: TextStyle(color: active ? Colors.white : darkNavy, fontWeight: FontWeight.bold, fontSize: 13))
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.black12)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_month, size: 16, color: darkNavy),
          const SizedBox(width: 8),
          Text(selectedMonthLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
        ],
      ),
    );
  }
}