import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ocr_app/services/random_id_generator.dart';

class ResultData {
  String userId;
  String testId;
  int result;
  DateTime submittedAt;

  ResultData({
    String? resultId,
    this.userId = '',
    this.testId = '',
    this.result = 0,
    DateTime? submittedAt,
  })  : submittedAt = submittedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'testId': testId,
      'result': result,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory ResultData.fromJson(Map<String, dynamic> json) {
    return ResultData(
      userId: json['userId'],
      testId: json['testId'],
      result: json['result'],
      submittedAt: DateTime.parse(json['submittedAt']),
    );
  }

  Future<void> saveResult() async {
    final prefs = await SharedPreferences.getInstance();
    final results = prefs.getStringList('results') ?? [];
    results.add(jsonEncode(toJson()));
    await prefs.setStringList('results', results);
  }

  static Future<List<ResultData>> loadAllByTestId(String testId) async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList('results') ?? [];

    return resultsJson
        .map((jsonStr) => ResultData.fromJson(jsonDecode(jsonStr)))
        .where((result) => result.testId == testId)
        .toList();
  }

  static Future<List<ResultData>> loadAllByUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList('results') ?? [];

    return resultsJson
        .map((jsonStr) => ResultData.fromJson(jsonDecode(jsonStr)))
        .where((result) => result.userId == userId)
        .toList();
  }

  static Future<ResultData?> loadResult(String userId, String testId) async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList('results') ?? [];
    for (var jsonStr in resultsJson) {
      final result = ResultData.fromJson(jsonDecode(jsonStr));
      if (result.testId == testId && result.userId == userId) {
        return result;
      }
    }
    return null;
  }

  Future<void> updateResult() async {
    deleteResult();
    saveResult();
  }

  Future<void> deleteResult() async {
    final prefs = await SharedPreferences.getInstance();
    final results = prefs.getStringList('results') ?? [];
    results.removeWhere((jsonStr) {
      final result = ResultData.fromJson(jsonDecode(jsonStr));
      return result.testId == testId && result.userId == userId;
    });
    await prefs.setStringList('results', results);
  }
}