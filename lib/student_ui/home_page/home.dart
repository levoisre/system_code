import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart'; 
import '../notification_page/notification.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  // --- STATE CONTROL ---
  bool isClockedIn = false;      
  bool isSessionFinished = false; 
  bool showVerification = false; 
  bool isScanning = false;      
  bool showSuccess = false;      

  // --- TIME DATA ---
  String _currentTime = ""; // The live working clock
  String clockInTime = "--:-- --";
  String clockOutTime = "--:-- --";
  String totalElapsed = "00:00:00"; 
  
  DateTime? _startTime;
  Timer? _liveClockTimer; // Timer for the real-time clock
  Timer? _durationTimer;  // Timer for the elapsed duration

  static const Color darkNavy = Color(0xFF0C1446); 

  @override
  void initState() {
    super.initState();
    _updateTime(); // Set initial time
    // 1. START THE WORKING CLOCK (Updates every second)
    _liveClockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (!mounted) return;
    setState(() {
      _currentTime = DateFormat('hh:mm').format(DateTime.now());
    });
  }

  // --- HELPER: Logic for the Top Clock Display ---
  String _getDisplayTime() {
    // If they just finished, show the exact time they clocked out
    if (isSessionFinished && !isClockedIn) return clockOutTime.split(' ')[0]; 
    // Otherwise, show the live working clock
    return _currentTime;
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null && isClockedIn) {
        final duration = DateTime.now().difference(_startTime!);
        setState(() {
          totalElapsed = _formatDuration(duration);
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  void _handleAttendance() {
    final now = DateTime.now();
    final String formattedTime = DateFormat('hh:mm a').format(now);

    setState(() {
      if (!isClockedIn) {
        clockInTime = formattedTime;
        _startTime = now;
        isClockedIn = true;
        isSessionFinished = false;
        _startDurationTimer();
      } else {
        clockOutTime = formattedTime;
        isClockedIn = false;
        isSessionFinished = true;
        _durationTimer?.cancel(); 
      }
      showSuccess = true; 
    });
  }

  void _startScanningProcess() {
    setState(() { showVerification = false; isScanning = true; });
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() { isScanning = false; });
        _handleAttendance();
      }
    });
  }

  @override
  void dispose() {
    _liveClockTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Data Structures & Algorithms', 
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()))
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildDashboard(),
          if (showVerification) _buildOverlay(child: _buildVerificationCard()),
          if (isScanning) _buildOverlay(backgroundColor: Colors.black.withAlpha(220), child: _buildScanningUI()),
          if (showSuccess) _buildOverlay(backgroundColor: const Color(0xFF4C5771).withAlpha(180), child: _buildSuccessCard()),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          // --- LIVE WORKING CLOCK ---
          Text(
            _getDisplayTime(), 
            style: const TextStyle(fontSize: 90, fontWeight: FontWeight.w900, fontFamily: 'serif')
          ),
          Text(
            DateFormat('EEEE | MMMM d, y').format(DateTime.now()), 
            style: const TextStyle(fontSize: 18, fontFamily: 'serif')
          ),
          
          const SizedBox(height: 40),
          const Center(child: Icon(Icons.account_circle, size: 200, color: Colors.black12)),
          
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: ElevatedButton(
              onPressed: () => setState(() => showVerification = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkNavy, foregroundColor: Colors.white, 
                minimumSize: const Size(double.infinity, 50), shape: const StadiumBorder()
              ),
              child: Text(isClockedIn ? 'CLOCK OUT' : 'CLOCK IN', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          
          const SizedBox(height: 30),
          _buildStatsCard(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black87)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _StatCol(icon: Icons.south_west, time: clockInTime, label: 'In'),
        _StatCol(icon: Icons.north_east, time: clockOutTime, label: 'Out'),
        _StatCol(icon: Icons.timer_outlined, time: totalElapsed, label: 'Total Hours'),
      ]),
    );
  }

  // Popups (Verification & Success) match your photos
  Widget _buildSuccessCard() {
    return Center(
      child: Container(
        width: 310, padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE4F3), borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.black, width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ATTENDANCE\nMARKED!', textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif', height: 1.2)),
            const SizedBox(height: 20),
            Text('Time in for ${isSessionFinished ? clockOutTime : clockInTime}\nhas been marked!', 
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontFamily: 'serif')),
            const SizedBox(height: 35),
            GestureDetector(
              onTap: () => setState(() => showSuccess = false),
              child: const Text('CLOSE', style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Center(
      child: Container(
        width: 330, padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(color: darkNavy, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(alignment: Alignment.topLeft, child: GestureDetector(onTap: () => setState(() => showVerification = false), child: const Icon(Icons.close, color: Colors.white, size: 20))),
            const Text('Facial Verification Required', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif')),
            const SizedBox(height: 15),
            const Text('To ensure secure and accurate attendance, the system will verify your identity through facial recognition.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
            const SizedBox(height: 20),
            _bullet('Your camera will be used for a quick face scan.'),
            _bullet('Data is used only for attendance verification.'),
            _bullet('If verification fails, you may retry or request assistance.'),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: _startScanningProcess,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8E8E8), foregroundColor: Colors.black, shape: const StadiumBorder()),
                child: const Text('START VERIFICATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(color: Colors.white)), Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3)))]));
  Widget _buildOverlay({required Widget child, Color? backgroundColor}) => Container(color: backgroundColor ?? Colors.black.withAlpha(100), width: double.infinity, height: double.infinity, child: child);
  Widget _buildScanningUI() => const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.face, size: 80, color: Colors.white), SizedBox(height: 20), Text('Scanning...', style: TextStyle(color: Colors.white, fontSize: 18))]);
}

class _StatCol extends StatelessWidget {
  final IconData icon; final String time; final String label;
  const _StatCol({required this.icon, required this.time, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(children: [Icon(icon, size: 20, color: Colors.black54), const SizedBox(height: 4), Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54))]);
  }
}