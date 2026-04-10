import 'package:flutter/material.dart';

// --- UPDATED IMPORTS ---
// Replaces InstructorIndex with the Course List (Manage Subject) page
import '../course_page/course_list.dart'; 

// Corrected relative path to reach the student login page
import '../../student_ui/login_page/login.dart'; 

class InstructorLoginPage extends StatefulWidget {
  const InstructorLoginPage({super.key});

  @override
  State<InstructorLoginPage> createState() => _InstructorLoginPageState();
}

class _InstructorLoginPageState extends State<InstructorLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Manage password visibility state
  bool _isPasswordObscured = true;

  static const Color darkNavy = Color(0xFF0C1446); 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'SMART CLASSROOM FACILITATOR',
          style: TextStyle(
            color: Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            fontFamily: 'serif'
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            
            // LARGE IDENTITY ICON
            const Center(
              child: Icon(Icons.account_circle, size: 160, color: Colors.black12),
            ),
            
            const SizedBox(height: 40),

            // INSTRUCTOR LOGIN CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 45),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "INSTRUCTOR LOGIN",
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: darkNavy,
                        fontFamily: 'serif',
                        letterSpacing: 1.1
                      ),
                    ),
                    const SizedBox(height: 45),

                    // EMAIL FIELD
                    _buildLoginInput(
                      controller: _emailController,
                      hint: 'School Email Address',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),

                    // PASSWORD FIELD
                    _buildLoginInput(
                      controller: _passwordController,
                      hint: 'Access Password',
                      icon: Icons.lock_open_outlined,
                      isPassword: true,
                    ),
                    
                    const SizedBox(height: 50),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // FIXED: Navigate to Course Selection instead of Dashboard
                          // This allows the professor to choose a subject first.
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const InstructorCourseList()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkNavy,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 3,
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 1.5, 
                            fontSize: 16, 
                            fontFamily: 'serif'
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Switch to Student Portal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }, 
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  "Switch to Student Portal", 
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isPasswordObscured : false,
        style: const TextStyle(fontFamily: 'serif'),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: darkNavy),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(
                  _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black26,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}