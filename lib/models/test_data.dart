import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/random_id_generator.dart';
import 'question_data.dart';

class TestData {
  String testId;
  String testName;
  List<QuestionData> questions;
  DateTime postedAt;
  DateTime startFrom;
  DateTime deadlineTime;
  int testTime;
  int result;

  TestData({
    String? testId,
    this.testName = '',
    List<QuestionData>? questions,
    DateTime? postedAt,
    DateTime? startFrom,
    DateTime? deadlineTime,
    this.testTime = 0,
    this.result = -1,  // Initialize result with a default value
  })  : testId = testId ?? RandomIdGenerator.generateTestId(),
        questions = questions ?? [],
        postedAt = postedAt ?? DateTime.now(),
        startFrom = startFrom ?? DateTime.now(),
        deadlineTime = deadlineTime ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'testName': testName,
      'questions': questions.map((q) => q.toJson()).toList(),
      'postedAt': postedAt.toIso8601String(),
      'startFrom': startFrom.toIso8601String(),
      'deadlineTime': deadlineTime.toIso8601String(),
      'testTime': testTime,
      'result': result,  // Include result in the toJson method
    };
  }

  factory TestData.fromJson(Map<String, dynamic> json) {
    return TestData(
      testId: json['testId'],
      testName: json['testName'],
      questions: (json['questions'] as List)
          .map((q) => QuestionData.fromJson(q))
          .toList()
        ..sort((a, b) => a.questionNumber.compareTo(b.questionNumber)),
      postedAt: DateTime.parse(json['postedAt']),
      startFrom: DateTime.parse(json['startFrom']),
      deadlineTime: DateTime.parse(json['deadlineTime']),
      testTime: json['testTime'],
      result: json['result'],  // Parse result from JSON
    );
  }

  Future<void> saveToLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> allTests = prefs.getStringList('tests') ?? [];
    while (allTests.contains(testId)) {
      RandomIdGenerator.generateTestId();
    }
    allTests.add(testId);
    prefs.setStringList('tests', allTests);
    prefs.setString(testId, jsonEncode(toJson()));
  }

  static Future<TestData?> loadFromLocalDatabase(String testId) async {
    final prefs = await SharedPreferences.getInstance();
    String? testJson = prefs.getString(testId);
    if (testJson != null) {
      return TestData.fromJson(jsonDecode(testJson));
    }
    return null;
  }

  static Future<void> deleteFromLocalDatabase(String testId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> allTests = prefs.getStringList('tests') ?? [];
    allTests.remove(testId);
    prefs.setStringList('tests', allTests);
    prefs.remove(testId);
  }

  static Future<List<TestData>> getAllTestsFromLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> allTests = prefs.getStringList('tests') ?? [];
    List<TestData> tests = [];

    for (String testId in allTests) {
      String? testJson = prefs.getString(testId);
      if (testJson != null) {
        tests.add(TestData.fromJson(jsonDecode(testJson)));
      }
    }

    tests.sort((a, b) => a.postedAt.compareTo(b.postedAt));

    return tests;
  }

  void updateTestData(TestData updatedTestData) async {
    testName = updatedTestData.testName;
    questions = updatedTestData.questions;
    postedAt = updatedTestData.postedAt;
    startFrom = updatedTestData.startFrom;
    deadlineTime = updatedTestData.deadlineTime;
    testTime = updatedTestData.testTime;
    result = updatedTestData.result;
    await saveToLocalDatabase();
  }
}