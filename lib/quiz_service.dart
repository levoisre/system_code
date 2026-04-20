import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class QuizService {
  // --- 1. NETWORK CONFIGURATION ---
  static const String localIP = "192.168.1.15"; 

  static final String host = kIsWeb 
      ? "localhost" 
      : (defaultTargetPlatform == TargetPlatform.android ? "10.0.2.2" : localIP);

  static final String quizBase = "http://$host:5000/api/quiz";
  static final String resultBase = "http://$host:5000/api/results";

  // --- 2. INSTRUCTOR METHODS (FIXES YOUR ERRORS) ---

  static Future<bool> createAssessment({
    required String subjectCode,
    required String title,
    required String description,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$quizBase/create'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "subjectCode": subjectCode,
          "title": title,
          "description": description,
          "questions": questions,
        }),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Create Error: $e");
      return false;
    }
  }

  static Future<bool> updateAssessment(int quizId, Map<String, dynamic> updatedData) async {
    try {
      final response = await http.patch(
        Uri.parse('$quizBase/update/$quizId'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(updatedData),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Update Error: $e");
      return false;
    }
  }

  static Future<bool> updateAssessmentStatus(int quizId, int status) async {
    try {
      final response = await http.patch(
        Uri.parse('$quizBase/status/$quizId'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({"status": status}),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Status Error: $e");
      return false;
    }
  }

  static Future<bool> deleteAssessment(int quizId) async {
    try {
      final response = await http.delete(Uri.parse('$quizBase/delete/$quizId'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Delete Error: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getQuizList(String subjectCode) async {
    try {
      final response = await http.get(Uri.parse('$quizBase/list/$subjectCode'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      debugPrint("❌ List Error: $e");
    }
    return [];
  }

  static Future<bool> toggleGiveQuiz(int quizId, bool isGiven, String title) async {
    try {
      final response = await http.patch(
        Uri.parse('$quizBase/give/$quizId'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "isGiven": isGiven ? 1 : 0,
          "title": title 
        }),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- 3. STUDENT METHODS ---

  static Future<List<dynamic>> getLiveQuizzes(String subjectCode) async {
    try {
      final response = await http.get(Uri.parse('$quizBase/student-view/$subjectCode'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      debugPrint("❌ Live Quiz Error: $e");
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getQuizDetails(int quizId) async {
    try {
      final response = await http.get(Uri.parse('$quizBase/details/$quizId'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> rawList = json.decode(response.body);
        return rawList.map((q) {
          dynamic meta = q['metadata'];
          if (meta != null && meta is String && meta.isNotEmpty) {
            try { meta = json.decode(meta); } catch (_) {}
          }
          return {
            "id": q['id'],
            "type": q['type']?.toString().toUpperCase().trim() ?? "MULTIPLE_CHOICE",
            "text": q['question_text'],
            "answer": q['correct_answer'],
            "options": meta is List ? meta : [], 
            "row": q['row'] ?? 0,
            "col": q['col'] ?? 0,
            "dir": q['dir'] ?? 'H',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint("❌ Details Error: $e");
    }
    return [];
  }

  static Future<bool> submitQuizResult({
    required int quizId, 
    required String studentName, 
    required int score, 
    required int totalQuestions, 
    required List<Map<String, dynamic>> answers,
    required String quizTitle,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$resultBase/submit'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "quizId": quizId,
          "studentName": studentName,
          "score": score,
          "totalQuestions": totalQuestions,
          "answers": answers, 
          "quizTitle": quizTitle,
        }),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> checkCompletion(int quizId, String studentName) async {
    try {
      final response = await http.get(Uri.parse('$resultBase/check/$quizId/$studentName'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      return {"completed": false, "data": null};
    }
    return {"completed": false, "data": null};
  }

  static Future<List<dynamic>> getQuizLeaderboard(String subjectCode) async {
    try {
      final response = await http.get(Uri.parse('$quizBase/leaderboard/$subjectCode'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      debugPrint("❌ Leaderboard Error: $e");
    }
    return [];
  }
}