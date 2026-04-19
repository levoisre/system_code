import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class QuizService {
  static const String baseUrl = "http://localhost:5000/api/quiz";

  /// Sends a full assessment (TF, ID, Crossword, or Multiple Choice)
  static Future<bool> createAssessment({
    required String subjectCode,
    required String title,
    required String description,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
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
      debugPrint("❌ Create Quiz Error: $e");
      return false;
    }
  }

  /// FIXED: This is the method the Edit page was looking for.
  /// status values: 0 = Archive, 1 = Active, 2 = Completed
  static Future<bool> updateAssessmentStatus(int quizId, int status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/status/$quizId'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({"status": status}),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Update Status Error: $e");
      return false;
    }
  }

  /// Fetches the list of available quizzes for a subject
  static Future<List<dynamic>> getQuizList(String subjectCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/list/$subjectCode'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint("❌ Fetch Quiz List Error: $e");
    }
    return [];
  }

  /// Update an existing assessment (Title, Description, or Questions)
  static Future<bool> updateAssessment(int quizId, Map<String, dynamic> updatedData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/$quizId'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(updatedData),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Update Quiz Error: $e");
      return false;
    }
  }

  /// Permanently delete an assessment and its questions from the database
  static Future<bool> deleteAssessment(int quizId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/$quizId'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Delete Quiz Error: $e");
      return false;
    }
  }

  /// Fetches full question details and parses JSON metadata automatically
  static Future<List<Map<String, dynamic>>> getQuizDetails(int quizId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/details/$quizId'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List<dynamic> rawList = json.decode(response.body);
        return rawList.map((q) {
          var metadata = q['metadata'];
          return {
            "id": q['id'],
            "type": q['type'],
            "text": q['question_text'],
            "answer": q['correct_answer'],
            "options": (metadata != null && metadata.toString().isNotEmpty) 
                ? json.decode(metadata) 
                : [],
          };
        }).toList();
      }
    } catch (e) {
      debugPrint("❌ Fetch Quiz Details Error: $e");
    }
    return [];
  }

  /// Validates a student's answer against the backend
  static Future<bool> validateAnswer(int questionId, String studentAnswer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "questionId": questionId,
          "studentAnswer": studentAnswer,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body)['correct'] ?? false;
      }
    } catch (e) {
      debugPrint("❌ Validation Error: $e");
    }
    return false;
  }
}