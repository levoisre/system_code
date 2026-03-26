import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Brand Colors from your screenshots
  static const Color darkNavy = Color(0xFF0C1446);
  static const Color bgLightGrey = Color(0xFFE5E5E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLightGrey,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 1. TITLE SECTION ---
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 60, 
                  fontWeight: FontWeight.bold, 
                  color: darkNavy, 
                  fontFamily: 'serif' // Using serif for that classic look
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your details to access your class',
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.black87, 
                  fontFamily: 'serif'
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 45),

              // --- 2. INPUT FIELDS ---
              _buildModernTextField(
                hint: "Student Number", 
                icon: Icons.person_rounded
              ),
              const SizedBox(height: 20),
              _buildModernTextField(
                hint: "Class Code", 
                icon: Icons.lock_outline_rounded
              ),
              
              const SizedBox(height: 45),

              // --- 3. EXACT PILL-SHAPED JOIN BUTTON ---
              SizedBox(
                width: 200, // Fixed width to match the screenshot proportion
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Functional Routing to Index
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkNavy,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    // StadiumBorder creates the perfect pill shape from your image
                    shape: const StadiumBorder(), 
                  ),
                  child: const Text(
                    "JOIN CLASS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 15, 
                      letterSpacing: 1.0
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TEXTFIELD HELPER ---
  Widget _buildModernTextField({required String hint, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black87, width: 1.2),
      ),
      child: TextField(
        style: const TextStyle(fontFamily: 'serif'),
        cursorColor: darkNavy,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45, fontFamily: 'serif'),
          prefixIcon: Icon(icon, color: darkNavy, size: 24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}