import 'package:flutter/material.dart';
// --- THE KEY FIX: Import the index file so StudentIndex is recognized ---
import 'package:smart_classroom_facilitator_project/student_ui/index.dart'; 
import 'package:smart_classroom_facilitator_project/student_ui/login_page/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Classroom Facilitator',
      
      // Modern Theme Setup
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00084D),
          primary: const Color(0xFF00084D),
        ),
        fontFamily: 'serif', 
      ),

      // 1. Initial Route: The app will start at the Login Screen
      initialRoute: '/login', 

      // 2. Route Map: Defines the nicknames for your pages
      routes: {
        '/login': (context) => const LoginPage(),    
        '/home': (context) => const StudentIndex(),  
      },
    );
  }
}