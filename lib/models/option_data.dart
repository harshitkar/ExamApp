import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/random_id_generator.dart';

class OptionData {
  String optionId;
  String optionText;
  Uint8List? image;
  int optionNumber;

  OptionData({
    String? optionId,
    this.optionText = '',
    this.image,
    this.optionNumber = 0,
  }) : optionId = optionId ?? RandomIdGenerator.generateOptionId();

  Map<String, dynamic> toJson() {
    return {
      'optionId': optionId,
      'optionText': optionText,
      'image': image != null ? base64Encode(image!) : null,
      'optionNumber': optionNumber,
    };
  }

  factory OptionData.fromJson(Map<String, dynamic> json) {
    return OptionData(
      optionId: json['optionId'],
      optionText: json['optionText'],
      image: json['image'] != null ? base64Decode(json['image']) : null,
      optionNumber: json['optionNumber'],
    );
  }

  Future<void> saveToLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(optionId, jsonEncode(toJson()));
  }

  static Future<OptionData?> loadFromLocalDatabase(String optionId) async {
    final prefs = await SharedPreferences.getInstance();
    String? optionJson = prefs.getString(optionId);
    if (optionJson != null) {
      return OptionData.fromJson(jsonDecode(optionJson));
    }
    return null;
  }

  static Future<void> deleteFromLocalDatabase(String optionId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(optionId);
  }
}
