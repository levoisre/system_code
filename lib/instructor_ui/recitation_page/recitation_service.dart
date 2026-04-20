import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class RecitationService {
  // --- 1. NETWORK CONFIGURATION ---
  // Ensure this matches your laptop's current IPv4 address
  static const String localIP = "192.168.1.15"; 

  static final String host = kIsWeb 
      ? "localhost" 
      : (defaultTargetPlatform == TargetPlatform.android ? "10.0.2.2" : localIP);

  static final String _baseUrl = "http://$host:5000/api/recitation";

  // --- 2. CORE METHODS ---

  /// Fetches the roster for the "SESSION STATS" panel
  static Future<List<dynamic>> getSessionStats(String subjectCode) async {
    try {
      // FIX: Matches app.get('/api/recitation/stats/:subjectCode') in server.js
      final response = await http.get(
        Uri.parse('$_baseUrl/stats/$subjectCode'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      debugPrint("❌ Recitation Fetch Error: $e");
    }
    return [];
  }

  /// Weighted randomization for student selection
  static Future<String?> pickStudent(String subjectCode, List<String> students) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/randomize'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "subjectCode": subjectCode, 
          "students": students
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) return json.decode(response.body)['selected'];
    } catch (e) {
      debugPrint("❌ Randomize Error: $e");
    }
    return null;
  }

  /// Submits the star rating (1-5) which the backend converts to points (10-50)
  static Future<bool> submitGrade(String name, String subjectCode, int stars) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/submit'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "name": name, 
          "subjectCode": subjectCode, 
          "stars": stars
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Grading Submit Error: $e");
      return false;
    }
  }

  /// Clears the recitation logs for the session
  static Future<bool> resetSession(String subjectCode) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({"subjectCode": subjectCode}),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Reset Session Error: $e");
      return false;
    }
  }
}