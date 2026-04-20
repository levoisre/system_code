import 'package:flutter/material.dart';
// FIXED: Prefix changed to lowercase 'io' to follow Dart naming conventions
import 'package:socket_io_client/socket_io_client.dart' as io;
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
  String selectedMonthLabel = "April 2026";
  
  // FIXED: Using lowercase 'io' here as well
  late io.Socket socket;

  final List<Map<String, dynamic>> allNotifications = [
    {
      "date": "April 20, 2026",
      "text": "Quiz Complete! You scored 34/40 on Data Structures Finals.",
      "isRead": true,
      "type": "result",
      "quizId": 1,
      "quizTitle": "Data Structures Finals",
      "score": 34,
      "total": 40,
      "answers": [] 
    },
  ];

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    // FIXED: Updated all calls to use lowercase 'io'
    socket = io.io('http://localhost:5000', 
      io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    socket.connect();

    socket.onConnect((_) => debugPrint('✅ Connected to Live Notification Server'));

    socket.on('notification', (data) {
      if (mounted) {
        setState(() {
          allNotifications.insert(0, {
            ...data,
            "isRead": false, 
          });
        });
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: darkNavy)),
        child: child!,
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedMonthLabel = "${_getMonthName(picked.month)} ${picked.year}";
      });
    }
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "March", "April", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    setState(() {
      notification['isRead'] = true;
    });

    String type = notification['type'] ?? "";

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      if (type == "result") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultsScreen(
              quizId: notification['quizId'] ?? 0,
              quizTitle: notification['quizTitle'] ?? "Assessment Results",
              score: notification['score'] ?? 0,
              totalQuestions: notification['total'] ?? 0,
              studentAnswers: List<Map<String, dynamic>>.from(notification['answers'] ?? []),
            ),
          ),
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
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayList = allNotifications.where((n) => n['isRead'] == isReadSelected).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('NOTIFICATIONS', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildToggleSwitch(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Align(
              alignment: Alignment.centerRight, 
              child: GestureDetector(onTap: _selectDate, child: _buildMonthSelector())
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)],
              ),
              child: displayList.isEmpty 
                ? const Center(child: Text("No notifications found."))
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      bool showHeader = index == 0 || displayList[index-1]['date'] != item['date'];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

  Widget _buildToggleSwitch() {
    return Container(
      width: 240, height: 40,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25), 
        border: Border.all(color: Colors.black12)
      ),
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
          decoration: BoxDecoration(
            color: active ? darkNavy : Colors.transparent, 
            borderRadius: BorderRadius.circular(25)
          ),
          child: Center(
            child: Text(label, 
              style: TextStyle(
                color: active ? Colors.white : darkNavy, 
                fontWeight: FontWeight.bold, fontSize: 12
              ))
          ),
        ),
      ),
    );
  }

  Widget _buildClickableNotification(Map<String, dynamic> item) {
    bool isRead = item['isRead'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () => _handleNotificationTap(item),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : darkNavy.withAlpha(10),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isRead ? Colors.black12 : darkNavy.withAlpha(25)),
          ),
          child: Row(
            children: [
              Icon(
                isRead ? Icons.done_all : Icons.notifications_active, 
                color: isRead ? Colors.black26 : darkNavy, size: 18
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item['text'], 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold
                  )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(date, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black38)),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.calendar_today, size: 14, color: darkNavy),
        const SizedBox(width: 5),
        Text(selectedMonthLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }
}