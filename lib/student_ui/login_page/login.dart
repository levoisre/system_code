import 'package:flutter/material.dart';
import '../index.dart'; // IMPORTANT: Navigate to Index, not Home

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _studentNumberController = TextEditingController();
  final TextEditingController _classCodeController = TextEditingController();

  static const Color darkNavy = Color(0xFF0C1446);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8), 
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: darkNavy,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 10),
            
            const Text(
              'Enter your details to access your class',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 30),

            _buildInputBox(
              controller: _studentNumberController,
              hint: 'Student Number',
              icon: Icons.person,
            ),
            const SizedBox(height: 15),

            _buildInputBox(
              controller: _classCodeController,
              hint: 'Class Code',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 40),

            // --- OPTIMIZED JOIN CLASS BUTTON ---
            SizedBox(
              width: 180, 
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  // 1. Capture Navigator BEFORE the await delay
                  final navigator = Navigator.of(context);

                  // 2. Small delay to allow ripple animation to finish (Fixes Lag)
                  await Future.delayed(const Duration(milliseconds: 150));

                  // 3. MANDATORY: Check if the widget is still in the tree
                  if (!mounted) return;

                  // 4. USE the captured navigator (This clears the linter error)
                  navigator.pushReplacement(
                    MaterialPageRoute(builder: (context) => const StudentIndex()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkNavy,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 5,
                ),
                child: const Text(
                  'JOIN CLASS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER FUNCTION FOR INPUT BOXES ---
  Widget _buildInputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontFamily: 'serif'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54, fontSize: 16),
          prefixIcon: Icon(icon, color: darkNavy, size: 28),
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}