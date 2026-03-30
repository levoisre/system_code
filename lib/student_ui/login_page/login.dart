import 'package:flutter/material.dart';
import '../index.dart'; // Ensure this points to your student dashboard/index file

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const Color darkNavy = Color(0xFF0C1446); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      // 1. BRANDED APP BAR (Identical to Instructor)
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
            
            // 2. LARGE IDENTITY ICON (Consistent placeholder)
            const Center(
              child: Icon(Icons.account_circle, size: 160, color: Colors.black12),
            ),
            
            const SizedBox(height: 40),

            // 3. STUDENT LOGIN CARD (Matches Instructor Card Design)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 45),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withAlpha(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "STUDENT LOGIN",
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: darkNavy,
                        fontFamily: 'serif',
                        letterSpacing: 1.1
                      ),
                    ),
                    const SizedBox(height: 45),

                    // 4. MATCHING INPUT FIELDS
                    _buildLoginInput(
                      controller: _studentIdController,
                      hint: 'Student ID Number',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 20),

                    _buildLoginInput(
                      controller: _passwordController,
                      hint: 'Access Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    
                    const SizedBox(height: 50),

                    // 5. STYLISH LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          
                          // Subtle delay for transition
                          await Future.delayed(const Duration(milliseconds: 200));
                          
                          if (!mounted) return;

                          // NAVIGATE to Student Dashboard
                          navigator.pushReplacement(
                            MaterialPageRoute(builder: (context) => const StudentIndex()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkNavy,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 3,
                        ),
                        child: const Text(
                          'SIGN IN',
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
            
            // Switcher Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context), 
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black12),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  "Switch to Instructor Portal", 
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

  // --- UI HELPER METHOD (Matches Instructor helper) ---
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
        border: Border.all(color: Colors.black.withAlpha(20)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontFamily: 'serif'),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: darkNavy),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}