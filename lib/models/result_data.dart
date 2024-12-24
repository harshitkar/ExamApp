import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ocr_app/services/random_id_generator.dart';

class ResultData {
  String userId;
  String testId;
  String resultId;
  int result;
  DateTime submittedAt;

  ResultData({
    String? resultId,
    this.userId = '',
    this.testId = '',
    this.result = 0,
    DateTime? submittedAt,
  })  : resultId = resultId ?? RandomIdGenerator.generateResultId(),
        submittedAt = submittedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'testId': testId,
      'resultId': resultId,
      'result': result,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory ResultData.fromJson(Map<String, dynamic> json) {
    return ResultData(
      userId: json['userId'],
      testId: json['testId'],
      resultId: json['resultId'],
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

  static Future<List<ResultData>> loadAllByTestIdFromSharedPreferences(String testId) async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList('results') ?? [];

    return resultsJson
        .map((jsonStr) => ResultData.fromJson(jsonDecode(jsonStr)))
        .where((result) => result.testId == testId)
        .toList();
  }

  static Future<List<ResultData>> loadAllByUserIdFromSharedPreferences(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList('results') ?? [];

    return resultsJson
        .map((jsonStr) => ResultData.fromJson(jsonDecode(jsonStr)))
        .where((result) => result.userId == userId)
        .toList();
  }


  static Future<ResultData?> loadResult(String resultId) async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList('results') ?? [];
    for (var jsonStr in resultsJson) {
      final result = ResultData.fromJson(jsonDecode(jsonStr));
      if (result.resultId == resultId) {
        return result;
      }
    }
    return null;
  }

  static Future<void> updateResult(ResultData updatedResult) async {
    final prefs = await SharedPreferences.getInstance();
    final results = prefs.getStringList('results') ?? [];
    for (int i = 0; i < results.length; i++) {
      final result = ResultData.fromJson(jsonDecode(results[i]));
      if (result.resultId == updatedResult.resultId) {
        results[i] = jsonEncode(updatedResult.toJson());
        await prefs.setStringList('results', results);
        return;
      }
    }
  }

  static Future<void> deleteResult(String resultId) async {
    final prefs = await SharedPreferences.getInstance();
    final results = prefs.getStringList('results') ?? [];
    results.removeWhere((jsonStr) {
      final result = ResultData.fromJson(jsonDecode(jsonStr));
      return result.resultId == resultId;
    });
    await prefs.setStringList('results', results);
  }
}