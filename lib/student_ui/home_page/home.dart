import 'package:flutter/material.dart';
import 'dart:async'; // Required for the timer
// 1. IMPORT YOUR NOTIFICATIONS PAGE
import 'package:smart_classroom_facilitator_project/student_ui/notification_page/notification.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> with TickerProviderStateMixin {
  // MASTER FLOW SWITCHES
  bool isClockedIn = false;      
  bool isSessionFinished = false; 
  bool showVerification = false; 
  bool isScanning = false;      
  bool showSuccess = false;      
  bool showClockOutSuccess = false; 

  static const Color darkNavy = Color(0xFF0C1446); 
  static const Color lightBlueCard = Color(0xFFDDE4F3);

  // Function to handle the Scanning Transition
  void _startScanningProcess() {
    setState(() {
      showVerification = false;
      isScanning = true;
    });

    // Simulate 3 seconds of "Face Scanning"
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isScanning = false;
          if (!isClockedIn) {
            isClockedIn = true;
            showSuccess = true;
          } else {
            isSessionFinished = true;
            showClockOutSuccess = true;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          isClockedIn ? 'HOME | DATA STRUCTURES & ALGORITHMS' : 'DATA STRUCTURES & ALGORITHMS',
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        // 2. UPDATED ACTIONS TO NAVIGATE TO NOTIFICATIONS
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          _buildMainUI(),

          // 1. Initial Prompt
          if (showVerification)
            _buildOverlay(child: _buildVerificationCard()),

          // 2. The Scanning Transition
          if (isScanning)
            _buildOverlay(
              backgroundColor: Colors.black.withValues(alpha: 0.85),
              child: _buildScanningUI(),
            ),

          // 3. Success Messages
          if (showSuccess)
            _buildOverlay(
              backgroundColor: const Color(0xFF4C5771).withValues(alpha: 0.8),
              child: _buildSuccessCard(
                title: 'ATTENDANCE\nMARKED!',
                message: 'Time in for 9:30 AM\nhas been marked!',
                onTap: () => setState(() => showSuccess = false),
              ),
            ),

          if (showClockOutSuccess)
            _buildOverlay(
              backgroundColor: const Color(0xFF4C5771).withValues(alpha: 0.8),
              child: _buildSuccessCard(
                title: 'CHECKED\nOUT\nMARKED!',
                message: 'You have successfully clocked\nout for DATA STRUCTURES &\nALGORITHMS.',
                onTap: () => setState(() => showClockOutSuccess = false),
              ),
            ),
        ],
      ),
    );
  }

  // --- SCANNING UI ---
  Widget _buildScanningUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.face_retouching_natural, size: 120, color: Colors.white),
        const SizedBox(height: 30),
        const Text(
          'Scanning Face...',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 10),
        const Text(
          'Please stay still and look at the camera',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
          ),
        ),
      ],
    );
  }

  // --- VERIFICATION CARD ---
  Widget _buildVerificationCard() {
    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(color: darkNavy, borderRadius: BorderRadius.circular(25)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => setState(() => showVerification = false),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('x', style: TextStyle(color: Colors.white, fontSize: 22)),
                ),
              ),
            ),
            const Center(
              child: Text(
                'Facial Verification Required',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'To ensure secure and accurate attendance, the system will verify your identity through facial recognition.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 15),
            const Text('  • Your camera will be used for a quick\n    face scan.',
              style: TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 8),
            const Text('  • Data is used only for attendance\n    verification.',
              style: TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 8),
            const Text('  • If verification fails, you may retry or\n    request assistance.',
              style: TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _startScanningProcess, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, 
                  foregroundColor: darkNavy,
                  minimumSize: const Size(220, 45),
                  shape: const StadiumBorder(),
                ),
                child: const Text('START VERIFICATION', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(isClockedIn ? '2:00' : '9:30', 
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),
          const Text('Tuesday | March 9, 2026', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 30),

          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(130),
                  ),
                ),
                const Icon(Icons.person_outline, size: 180, color: Colors.black26),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          const Text('You are 1 meter away from school'),
          const SizedBox(height: 25),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: ElevatedButton(
              onPressed: () => setState(() => showVerification = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkNavy,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: const StadiumBorder(),
              ),
              child: Text(isClockedIn ? 'CLOCK OUT' : 'CLOCK IN', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),

          _buildStatsCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSuccessCard({required String title, required String message, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.symmetric(vertical: 65, horizontal: 20),
          decoration: BoxDecoration(
            color: lightBlueCard.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1)),
              const SizedBox(height: 30),
              Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay({required Widget child, Color? backgroundColor}) {
    return Container(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.3),
      width: double.infinity,
      height: double.infinity,
      child: child,
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatColumn(icon: Icons.south_west, time: isClockedIn ? '09:30' : '0:00', label: 'Clock In'),
          _StatColumn(icon: Icons.north_east, time: isSessionFinished ? '05:00' : '0:00', label: 'Clock Out'),
          _StatColumn(icon: Icons.access_time, time: isSessionFinished ? '04:30' : '0:00', label: 'Total Hours'),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String time;
  final String label;
  const _StatColumn({required this.icon, required this.time, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.black87),
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}