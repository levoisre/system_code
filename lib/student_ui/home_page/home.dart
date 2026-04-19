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
  // --- SUBJECT DATA ---
  final String subjectName = "MOBILE APPLICATION DEVELOPMENT"; 

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
  double proximityDistance = 1.2; 
  
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
          if (proximityDistance < 2.5) proximityDistance += 0.01;
        });

        if (duration.inSeconds >= 3600) { 
          _autoClockOut();
        }
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
      isSessionFinished = false;
      showSuccess = true; 
    });
    _startDurationTimer();
  }

  void _autoClockOut() {
    if (!isClockedIn) return;
    setState(() {
      clockOutTime = DateFormat('hh:mm a').format(DateTime.now());
      isClockedIn = false;
      isSessionFinished = true;
      showFinalSummary = true; 
      _durationTimer?.cancel();
    });
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
        title: Text(
          subjectName.toUpperCase(), 
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 15, 
            fontWeight: FontWeight.w900, 
            fontFamily: 'serif',
            letterSpacing: 1.2
          ),
        ),
        actions: [
          // Notifications Page integrated in Header
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
          
          if (showVerification) 
            _buildOverlay(child: _buildVerificationCard()),
          
          if (isScanning) 
            _buildOverlay(
              backgroundColor: Colors.black.withValues(alpha: 0.85), 
              child: _buildScanningUI()
            ),
          
          if (showSuccess) 
            _buildOverlay(
              backgroundColor: darkNavy.withValues(alpha: 0.8), 
              child: _buildSuccessCard()
            ),
          
          if (showFinalSummary) 
            _buildOverlay(
              backgroundColor: Colors.black.withValues(alpha: 0.9), 
              child: _buildFinalSummaryCard()
            ),
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
              style: const TextStyle(fontSize: 90, fontWeight: FontWeight.w900, fontFamily: 'serif', color: darkNavy)),
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
                      color: (isClockedIn ? Colors.green : accentBlue).withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5)
                    ],
                    border: Border.all(
                      color: isClockedIn ? Colors.green : Colors.black.withValues(alpha: 0.05),
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isClockedIn ? Icons.settings_input_antenna_rounded : Icons.face_retouching_natural_rounded,
                      size: 80,
                      color: isClockedIn ? Colors.green : darkNavy.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                if (isClockedIn)
                  Positioned(
                    bottom: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          _buildProximityIndicator(),
          const SizedBox(height: 40),
          _buildStatsCard(),
        ],
      ),
    );
  }

  Widget _buildProximityIndicator() {
    bool isConnected = isClockedIn;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 50),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isConnected ? Colors.green : Colors.red, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded, color: isConnected ? Colors.green : Colors.red, size: 18),
          const SizedBox(width: 10),
          Text(
            isConnected ? "Hub Connected" : "Connection Lost",
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
        children: [
          _StatCol(icon: Icons.login, time: clockInTime, label: 'Clock In'),
          Container(height: 40, width: 1, color: Colors.black.withValues(alpha: 0.05)),
          _StatCol(icon: Icons.hourglass_bottom, time: totalElapsed, label: 'Elapsed'),
          Container(height: 40, width: 1, color: Colors.black.withValues(alpha: 0.05)),
          _StatCol(icon: Icons.logout, time: clockOutTime, label: 'Clock Out'),
        ]
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
            const Icon(Icons.face_unlock_rounded, color: Colors.white, size: 50),
            const SizedBox(height: 20),
            const Text('Verify Attendance', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif')),
            const SizedBox(height: 15),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5))
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Text('Hub not yet connected', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 15),
            const Text('The system will establish a connection to the Smart Classroom Hub once your identity is verified.', 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _startScanningProcess, 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: darkNavy, shape: const StadiumBorder()),
                child: const Text('START SCAN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningUI() => Column(
    mainAxisAlignment: MainAxisAlignment.center, 
    children: [
      const CircularProgressIndicator(color: Colors.white), 
      const SizedBox(height: 20), 
      Text('Establishing Hub Connection...', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
      const SizedBox(height: 8),
      const Text('Verifying Identity...', style: TextStyle(color: Colors.white54, fontSize: 12)),
    ]
  );

  Widget _buildSuccessCard() {
    return Center(
      child: Container(
        width: 310, padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
        decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(25)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 70),
            const SizedBox(height: 20),
            const Text('IDENTIFIED', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif', color: darkNavy)),
            const SizedBox(height: 10),
            // Updated to include that attendance has been marked
            const Text(
              'Attendance has been marked successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Face recognized. Hub connected.\nSession started at: $clockInTime', textAlign: TextAlign.center),
            const SizedBox(height: 35),
            GestureDetector(
              onTap: () => setState(() => showSuccess = false),
              child: const Text('PROCEED', style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold, fontSize: 16)),
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
            const Icon(Icons.notification_important, color: Colors.orange, size: 60),
            const SizedBox(height: 20),
            const Text('SESSION ENDED', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'serif', color: darkNavy)),
            const SizedBox(height: 10),
            const Text('The instructor has ended the class session. You have been clocked out.', textAlign: TextAlign.center),
            const Divider(height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Duration:"),
              Text(totalElapsed, style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() => showFinalSummary = false),
              style: ElevatedButton.styleFrom(backgroundColor: darkNavy, shape: const StadiumBorder()),
              child: const Text("RETURN TO DASHBOARD", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay({required Widget child, Color? backgroundColor}) => 
      Container(
        color: backgroundColor ?? Colors.black.withValues(alpha: 0.6), 
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
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkNavy)), 
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black38))
      ]
    );
  }
}