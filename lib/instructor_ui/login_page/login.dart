import 'package:flutter/material.dart';

class InstructorLoginPage extends StatefulWidget {
  const InstructorLoginPage({super.key});

  @override
  State<InstructorLoginPage> createState() => _InstructorLoginPageState();
}

class _InstructorLoginPageState extends State<InstructorLoginPage> {
  // 1. Text Controllers to capture input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Color matching from wireframe
  static const Color darkNavy = Color(0xFF0C1446);
  static const Color lightGreyBg = Color(0xFFE0E0E0); // Outer background

  void _handleLogin() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email == "instructor@sti.edu" && password == "password123") {
      // Navigate to Instructor Dashboard (will create next)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const InstructorDashboard()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Credentials. Use standard STI login.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The main screen has the outer light grey background
    return Scaffold(
      backgroundColor: lightGreyBg,
      body: Center(
        // Constraining the width makes it look like the Wireframe on Web/Emulators
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          // Inner content container (white/light grey in image)
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0), // Inner card color
            borderRadius: BorderRadius.circular(5), // Slight rounded edge
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Shrinks to fit content
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- 2. THE TITLE (SERIF FONT) ---
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  // Using default serif to match wireframe style
                  fontFamily: 'serif', 
                ),
              ),
              const SizedBox(height: 15),

              // --- 3. SUBTITLE ---
              const Text(
                'Enter your details to access your class',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 40),

              // --- 4. E-MAIL INPUT FIELD ---
              _buildInputField(
                controller: _emailController,
                hintText: 'E-mail Address',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              // --- 5. PASSWORD INPUT FIELD ---
              _buildInputField(
                controller: _passwordController,
                hintText: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 50),

              // --- 6. THE LOGIN BUTTON ---
              SizedBox(
                width: double.infinity, // Fills available width in Column
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkNavy,
                    // Fully rounded edges as shown in image
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 3,
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.2, // Gives it that modern professional look
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE INPUT FIELD WIDGET (Matching the image style) ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // Match the rounded rectangles from the wireframe
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black38), // Subtle dark border
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword, // Hides text for password
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black45, fontSize: 16),
          prefixIcon: Icon(icon, color: Colors.black87, size: 22),
          border: InputBorder.none, // Hide default TextField border
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}