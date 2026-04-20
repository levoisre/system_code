import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../notification_page/notification.dart';

// --- THEME CONSTANTS ---
const Color darkNavy = Color(0xFF0C1446);
const Color stiGold = Color(0xFFFFD100);
const Color accentBlue = Color(0xFF4A90E2);

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> with SingleTickerProviderStateMixin {
  // --- SYNCED SUBJECT DATA ---
  final String subjectName = "MOBILE APPLICATION DEVELOPMENT"; 
  final String subjectCode = "CPE 401"; // Added for consistency with your database

  // --- STATE CONTROL ---
  bool isClockedIn = false;      
  bool isSessionFinished = false; 
  bool showVerification = false; 
  bool isScanning = false;       
  bool showSuccess = false;      
  bool showFinalSummary = false; 

  // --- TIME & DATA ---
  String _currentTime = ""; 
  String clockInTime = "--:-- --";
  String clockOutTime = "--:-- --";
  String totalElapsed = "00:00:00"; 
  
  DateTime? _startTime;
  Timer? _liveClockTimer; 
  Timer? _durationTimer;  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _updateTime(); 
    _liveClockTimer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Trigger verification dialog on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => showVerification = true);
    });
  }

  void _updateTime() {
    if (!mounted) return;
    setState(() {
      _currentTime = DateFormat('hh:mm').format(DateTime.now());
    });
  }

  String _getDisplayTime() {
    if (isSessionFinished && !isClockedIn) return clockOutTime.split(' ')[0]; 
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

  void _autoClockIn() {
    final now = DateTime.now();
    setState(() {
      clockInTime = DateFormat('hh:mm a').format(now);
      _startTime = now;
      isClockedIn = true;
      showSuccess = true; 
    });
    _startDurationTimer();
  }

  void _startScanningProcess() {
    setState(() { showVerification = false; isScanning = true; });
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() { isScanning = false; });
        _autoClockIn(); 
      }
    });
  }

  @override
  void dispose() {
    _liveClockTimer?.cancel();
    _durationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000040), 
        elevation: 4,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subjectCode,
              style: const TextStyle(color: stiGold, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Text(
              subjectName.toUpperCase(), 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 13, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 1.1
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white), 
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const NotificationsPage())
            )
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _buildDashboard(),
          if (showVerification) _buildOverlay(child: _buildVerificationCard()),
          if (isScanning) _buildOverlay(child: _buildScanningUI()),
          if (showSuccess) _buildOverlay(child: _buildSuccessCard()),
          if (showFinalSummary) _buildOverlay(child: _buildFinalSummaryCard()),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(_getDisplayTime(), 
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: darkNavy)),
          Text(DateFormat('EEEE, MMMM d, y').format(DateTime.now()), 
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 40),

          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.2).animate(_pulseController),
                  child: Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isClockedIn ? Colors.green : accentBlue).withAlpha(25),
                    ),
                  ),
                ),
                Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 20, spreadRadius: 5)
                    ],
                    border: Border.all(
                      color: isClockedIn ? Colors.green : Colors.black.withAlpha(12),
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isClockedIn ? Icons.wifi_tethering : Icons.face_retouching_natural_rounded,
                      size: 80,
                      color: isClockedIn ? Colors.green : darkNavy.withAlpha(128),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          _buildStatusBadge(),
          const SizedBox(height: 40),
          _buildStatsCard(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    bool isConnected = isClockedIn;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isConnected ? Colors.green : Colors.red),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isConnected ? Icons.check_circle : Icons.warning, color: isConnected ? Colors.green : Colors.red, size: 18),
          const SizedBox(width: 10),
          Text(
            isConnected ? "Smart Classroom Hub Connected" : "Attendance Required",
            style: TextStyle(fontWeight: FontWeight.bold, color: isConnected ? Colors.green : Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20), 
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25), 
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
        children: [
          _StatCol(icon: Icons.login, time: clockInTime, label: 'Clock In'),
          _StatCol(icon: Icons.timer_outlined, time: totalElapsed, label: 'Session'),
          _StatCol(icon: Icons.logout, time: clockOutTime, label: 'Clock Out'),
        ]
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Center(
      child: Container(
        width: 320, padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(color: darkNavy, borderRadius: BorderRadius.circular(25)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.face_unlock_rounded, color: Colors.white, size: 60),
            const SizedBox(height: 20),
            const Text('Verify Attendance', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text(
              'Position your face clearly. The system will sync your attendance with the classroom hub.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _startScanningProcess, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: stiGold, 
                  foregroundColor: darkNavy, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                child: const Text('START FACIAL SCAN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningUI() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        const CircularProgressIndicator(color: stiGold), 
        const SizedBox(height: 20), 
        Text('Processing Identity...', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 16, fontWeight: FontWeight.bold)),
      ]
    ),
  );

  Widget _buildSuccessCard() {
    return Center(
      child: Container(
        width: 310, padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user, color: Colors.green, size: 70),
            const SizedBox(height: 20),
            const Text('IDENTIFIED', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkNavy)),
            const SizedBox(height: 10),
            const Text(
              'Attendance has been marked successfully for today.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() => showSuccess = false),
              style: ElevatedButton.styleFrom(backgroundColor: darkNavy, foregroundColor: Colors.white),
              child: const Text('PROCEED TO DASHBOARD'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalSummaryCard() {
    return Center(
      child: Container(
        width: 320, padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, color: Colors.redAccent, size: 60),
            const SizedBox(height: 20),
            const Text('SESSION ENDED', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkNavy)),
            const SizedBox(height: 20),
            Text('Duration: $totalElapsed'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() => showFinalSummary = false),
              style: ElevatedButton.styleFrom(backgroundColor: darkNavy),
              child: const Text("CLOSE", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay({required Widget child}) => 
      Container(
        color: Colors.black.withAlpha(200), 
        width: double.infinity, height: double.infinity, 
        child: child
      );
}

class _StatCol extends StatelessWidget {
  final IconData icon; final String time; final String label;
  const _StatCol({required this.icon, required this.time, required this.label});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: darkNavy), 
        const SizedBox(height: 8), 
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkNavy)), 
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black38))
      ]
    );
  }
}