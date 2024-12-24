import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Classroom {
  final String classroomId;
  final String classroomName;
  final DateTime createdAt;

  Classroom({
    required this.classroomId,
    required this.classroomName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'classroomId': classroomId,
      'classroomName': classroomName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      classroomId: json['classroomId'],
      classroomName: json['classroomName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Future<void> saveClassroom() async {
    final prefs = await SharedPreferences.getInstance();
    final classrooms = prefs.getStringList('classrooms') ?? [];
    classrooms.add(jsonEncode(this.toJson()));
    await prefs.setStringList('classrooms', classrooms);
  }

  static Future<void> deleteClassroom(String classroomId) async {
    final prefs = await SharedPreferences.getInstance();
    final classrooms = prefs.getStringList('classrooms') ?? [];
    classrooms.removeWhere((jsonStr) {
      final classroom = Classroom.fromJson(jsonDecode(jsonStr));
      return classroom.classroomId == classroomId;
    });
    await prefs.setStringList('classrooms', classrooms);
  }

  Future<void> joinClassroom(String userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    final userClassrooms = prefs.getStringList('user-classrooms') ?? [];
    final userClassroom = UserClassroom(userId: userId, classroomId: classroomId, role: role);
    userClassrooms.add(jsonEncode(userClassroom.toJson()));
    await prefs.setStringList('user-classrooms', userClassrooms);
  }

  static Future<List<Classroom>> loadAllClassroomsForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userClassroomsJson = prefs.getStringList('user-classrooms') ?? [];
    final userClassrooms = userClassroomsJson
        .map((jsonStr) => UserClassroom.fromJson(jsonDecode(jsonStr)))
        .where((userClassroom) => userClassroom.userId == userId)
        .toList();

    final classroomsJson = prefs.getStringList('classrooms') ?? [];
    return classroomsJson
        .map((jsonStr) => Classroom.fromJson(jsonDecode(jsonStr)))
        .where((classroom) => userClassrooms.any((userClassroom) => userClassroom.classroomId == classroom.classroomId))
        .toList();
  }

  static Future<void> leaveClassroom(String userId, String classroomId) async {
    final prefs = await SharedPreferences.getInstance();
    final userClassrooms = prefs.getStringList('user-classrooms') ?? [];
    userClassrooms.removeWhere((jsonStr) {
      final userClassroom = UserClassroom.fromJson(jsonDecode(jsonStr));
      return userClassroom.userId == userId && userClassroom.classroomId == classroomId;
    });
    await prefs.setStringList('user-classrooms', userClassrooms);
  }
}

class UserClassroom {
  final String userId;
  final String classroomId;
  final String role;

  UserClassroom({
    required this.userId,
    required this.classroomId,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'classroomId': classroomId,
      'role': role,
    };
  }

  factory UserClassroom.fromJson(Map<String, dynamic> json) {
    return UserClassroom(
      userId: json['userId'],
      classroomId: json['classroomId'],
      role: json['role'],
    );
  }
}