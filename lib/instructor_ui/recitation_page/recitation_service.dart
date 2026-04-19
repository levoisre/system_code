import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class RecitationService {
  // Base configuration
  static const String _authority = "localhost:5000";
  static const String _basePath = "/api/recitation";

  /// Helper to build URLs consistently to avoid 404/path errors
  static Uri _getUri(String endpoint) => Uri.http(_authority, "$_basePath$endpoint");

  /// Fetches the leaderboard/stats for a specific subject
  static Future<List<dynamic>> getSessionStats(String subjectCode) async {
    try {
      final response = await http.get(
        _getUri('/session-stats/$subjectCode'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      debugPrint("❌ Fetch Error: $e");
    }
    return [];
  }

  /// Sends the current pool of present students to the backend
  static Future<String?> pickStudent(String subjectCode, List<String> students) async {
    try {
      final response = await http.post(
        _getUri('/randomize'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({"subjectCode": subjectCode, "students": students}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) return json.decode(response.body)['selected'];
    } catch (e) {
      debugPrint("❌ Randomize Error: $e");
    }
    return null;
  }

  /// Submits the star rating for a selected student
  static Future<bool> submitGrade(String name, String subjectCode, int stars) async {
    try {
      final response = await http.post(
        _getUri('/submit'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({"name": name, "subjectCode": subjectCode, "stars": stars}),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Submit Error: $e");
      return false;
    }
  }

  /// Reset Session Function (Corrected for 404 errors)
  static Future<bool> resetSession(String subjectCode) async {
    try {
      debugPrint("📡 Sending Reset Request for: $subjectCode");
      
      final response = await http.post(
        _getUri('/reset'),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
        },
        body: jsonEncode({"subjectCode": subjectCode}),
      ).timeout(const Duration(seconds: 5));

      debugPrint("📡 Server Response: ${response.statusCode}");
      
      if (response.statusCode == 404) {
        debugPrint("⚠️ ERROR: The server doesn't recognize the /reset route. Did you restart the Node.js backend?");
      }

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Connection Error during Reset: $e");
      return false;
    }
  }
}