import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import 'option_data.dart';

class QuestionData {
  String questionId;
  String questionText;
  Uint8List? questionImage;
  List<OptionData> options;
  int questionNumber;
  int correctOptionIndex;

  QuestionData({
    this.questionId = '',
    this.questionText = '',
    this.questionImage,
    List<OptionData>? options,
    this.questionNumber = 0,
    this.correctOptionIndex = 0,
  })  : options = options ?? List.generate(4, (index) => OptionData(optionNumber: index));

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'questionImage': questionImage != null ? base64Encode(questionImage!) : null,
      'options': options.map((o) => o.toJson()).toList(),
      'questionNumber': questionNumber,
      'correctOptionIndex': correctOptionIndex,
    };
  }

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      questionId: json['questionId'],
      questionText: json['questionText'],
      questionImage: json['questionImage'] != null ? base64Decode(json['questionImage']) : null,
      options: (json['options'] as List)
          .map((o) => OptionData.fromJson(o))
          .toList()
          ..sort((a, b) => a.optionNumber.compareTo(b.optionNumber)),
      questionNumber: json['questionNumber'],
      correctOptionIndex: json['correctOptionIndex'],
    );
  }

  Future<void> saveToLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(questionId, jsonEncode(toJson()));
  }

  static Future<QuestionData?> loadFromLocalDatabase(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    String? questionJson = prefs.getString(questionId);
    if (questionJson != null) {
      return QuestionData.fromJson(jsonDecode(questionJson));
    }
    return null;
  }

  static Future<void> deleteFromLocalDatabase(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(questionId);
  }
}