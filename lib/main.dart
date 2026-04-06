import 'package:flutter/material.dart';

// --- 1. PORTAL IMPORTS ---
import 'student_ui/login_page/login.dart' as student;
import 'instructor_ui/login_page/login.dart' as instructor;

void main() {
  runApp(const SmartClassroomApp());
}

class SmartClassroomApp extends StatelessWidget {
  const SmartClassroomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Classroom Facilitator',
      theme: ThemeData(
        primaryColor: const Color(0xFF0C1446),
        scaffoldBackgroundColor: const Color(0xFFE0E0E0),
        fontFamily: 'serif', // STI-style serif branding
        useMaterial3: true,
      ),
      home: const RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  static const Color darkNavy = Color(0xFF0C1446);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'WELCOME',
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1.2,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Select your portal to continue',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 50),

              // --- BUTTON TO STUDENT PORTAL ---
              _buildRoleButton(
                context,
                label: "STUDENT PORTAL",
                icon: Icons.school_outlined,
                // Ensure student.LoginPage is defined in your student login file
                destination: const student.LoginPage(), 
              ),

              const SizedBox(height: 20),

              // --- BUTTON TO INSTRUCTOR PORTAL ---
              _buildRoleButton(
                context,
                label: "INSTRUCTOR PORTAL",
                icon: Icons.admin_panel_settings_outlined,
                // Points to the updated InstructorLoginPage
                destination: const instructor.InstructorLoginPage(), 
              ),
              
              const SizedBox(height: 40),
              const Text(
                "STI College - Thesis 2026",
                style: TextStyle(fontSize: 11, color: Colors.black26),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER FUNCTION WITH NAMED PARAMETERS ---
  Widget _buildRoleButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Widget destination,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: darkNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 4,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
      ),
    );
  }
}