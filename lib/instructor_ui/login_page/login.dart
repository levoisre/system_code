import 'package:flutter/material.dart';
import '../course_page/course_list.dart'; 

class InstructorLoginPage extends StatefulWidget {
  const InstructorLoginPage({super.key});

  @override
  State<InstructorLoginPage> createState() => _InstructorLoginPageState();
}

class _InstructorLoginPageState extends State<InstructorLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Track password visibility state
  bool _isObscured = true;

  static const Color darkNavy = Color(0xFF0C1446); 

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
                  border: Border.all(color: const Color(0x1A000000)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 15,
                      offset: Offset(0, 5),
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

                    // INPUT FIELDS
                    _buildLoginInput(
                      controller: _emailController,
                      hint: 'School Email Address',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),

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
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          await Future.delayed(const Duration(milliseconds: 200));
                          if (!mounted) return;

                          navigator.pushReplacement(
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
            
            // Switch to Student Portal Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context), 
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0x1F000000)),
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
        border: Border.all(color: const Color(0x1A000000)),
      ),
      child: TextField(
        controller: controller,
        // Uses the state variable if it's a password field
        obscureText: isPassword ? _isObscured : false,
        style: const TextStyle(fontFamily: 'serif'),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: darkNavy),
          // Added the Eye Symbol logic here
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black26,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
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