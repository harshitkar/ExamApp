import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  String userId;
  String username;
  String phoneNumber;

  UserData({
    this.userId = '',
    this.username = '',
    this.phoneNumber = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'phoneNumber': phoneNumber,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'],
      username: json['username'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Future<void> saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('user') ?? [];
    users.add(jsonEncode(toJson()));
    await prefs.setStringList('user', users);
  }

  static Future<UserData?> loadUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('user') ?? [];
    for (var jsonStr in usersJson) {
      final user = UserData.fromJson(jsonDecode(jsonStr));
      if (user.userId == userId) {
        return user;
      }
    }
    return null;
  }

  static Future<void> updateUserData(UserData updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('user') ?? [];
    for (int i = 0; i < users.length; i++) {
      final user = UserData.fromJson(jsonDecode(users[i]));
      if (user.userId == updatedUser.userId) {
        users[i] = jsonEncode(updatedUser.toJson()); // Update the user data
        await prefs.setStringList('user', users);
        return;
      }
    }
  }

  static Future<void> deleteUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('user') ?? [];
    users.removeWhere((jsonStr) {
      final user = UserData.fromJson(jsonDecode(jsonStr));
      return user.userId == userId;
    });
    await prefs.setStringList('user', users);
  }
}