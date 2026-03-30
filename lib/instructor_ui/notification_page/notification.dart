import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const Color darkNavy = Color(0xFF000080);
  static const Color bgColor = Color(0xFFF8FAFC);

  final List<Map<String, dynamic>> _allNotifications = [
    {"id": 1, "type": "System", "title": "Hotspot Active", "desc": "Classroom hotspot is now broadcasting.", "time": "2 mins ago", "icon": Icons.wifi_tethering, "color": Colors.green},
    {"id": 2, "type": "Attendance", "title": "Attendance Alert", "desc": "3 students are currently out of range.", "time": "5 mins ago", "icon": Icons.person_search, "color": Colors.orange},
    {"id": 3, "type": "System", "title": "Update Available", "desc": "Version 2.1 is ready for installation.", "time": "1 hour ago", "icon": Icons.system_update, "color": Colors.blue},
    {"id": 4, "type": "Quiz", "title": "Quiz Generated", "desc": "AI has successfully generated 10 questions.", "time": "3 hours ago", "icon": Icons.psychology, "color": Colors.purple},
    {"id": 5, "type": "Attendance", "title": "New Enrollment", "desc": "Alex Johnson has joined the class roster.", "time": "Yesterday", "icon": Icons.person_add, "color": Colors.teal},
  ];

  List<Map<String, dynamic>> _filteredNotifications = [];
  String _selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _filteredNotifications = List.from(_allNotifications);
  }

  void _applyFilter(String category) {
    setState(() {
      _selectedFilter = category;
      if (category == "All") {
        _filteredNotifications = List.from(_allNotifications);
      } else {
        _filteredNotifications = _allNotifications.where((n) => n['type'] == category).toList();
      }
    });
  }

  void _clearAll() {
    setState(() {
      _allNotifications.clear();
      _filteredNotifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: darkNavy, // UPDATED: Header is now Blue
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "NOTIFICATIONS",
          style: TextStyle(
            color: Colors.white, 
            fontSize: 14, 
            fontWeight: FontWeight.w900, 
            fontFamily: 'serif', 
            letterSpacing: 1.0
          ),
        ),
        centerTitle: true,
        actions: [
          if (_allNotifications.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                "Clear All", 
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)
              ),
            ),
        ],
        // The filter bar stays white for better contrast against the blue header
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterBar(),
        ),
      ),
      body: _filteredNotifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredNotifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildNotificationItem(_filteredNotifications[index]),
            ),
    );
  }

  Widget _buildFilterBar() {
    List<String> categories = ["All", "System", "Attendance", "Quiz"];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEDF2F7))),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          bool isSelected = _selectedFilter == categories[index];
          return GestureDetector(
            onTap: () => _applyFilter(categories[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? darkNavy : bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: (item['color'] as Color).withValues(alpha: 0.1),
            child: Icon(item['icon'], color: item['color'], size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: darkNavy, fontSize: 13)),
                    Text(item['time'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item['desc'], style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 60, color: Colors.grey[200]),
          const SizedBox(height: 15),
          Text("No notifications", style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }
}