import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../services/random_id_generator.dart';
import '../Holders/data_holder.dart';

class ClassroomData {
  String classroomId;
  String classroomName;
  DateTime? createdAt;

  ClassroomData({
    this.classroomId = '',
    this.classroomName = '',
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'classroomId': classroomId,
      'classroomName': classroomName,
      'createdAt': createdAt!.toIso8601String(),
    };
  }

  factory ClassroomData.fromJson(Map<String, dynamic> json) {
    return ClassroomData(
      classroomId: json['classroomId'],
      classroomName: json['classroomName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Future<void> saveClassroom() async {
    final prefs = await SharedPreferences.getInstance();
    final classrooms = prefs.getStringList('classrooms') ?? [];
    classroomId = RandomIdGenerator.generateClassroomId();
    while (classrooms.contains(classroomId)) {
      classroomId = RandomIdGenerator.generateClassroomId();
    }
    classrooms.add(jsonEncode(toJson()));
    await prefs.setStringList('classrooms', classrooms);
  }

  static Future<ClassroomData?> loadClassroomData(String classroomId) async {
    final prefs = await SharedPreferences.getInstance();
    final classroomsJson = prefs.getStringList('classrooms') ?? [];
    for (final jsonStr in classroomsJson) {
      final classroom = ClassroomData.fromJson(jsonDecode(jsonStr));
      if (classroom.classroomId == classroomId) {
        return classroom;
      }
    }
    return null;
  }

  static Future<void> deleteClassroom(String classroomId) async {
    final prefs = await SharedPreferences.getInstance();
    final classrooms = prefs.getStringList('classrooms') ?? [];
    classrooms.removeWhere((jsonStr) {
      final classroom = ClassroomData.fromJson(jsonDecode(jsonStr));
      return classroom.classroomId == classroomId;
    });
    await prefs.setStringList('classrooms', classrooms);
  }

  Future<void> joinClassroom(String role) async {
    final prefs = await SharedPreferences.getInstance();
    final userClassrooms = prefs.getStringList('user-classrooms') ?? [];
    final userClassroom = UserClassroomData(userId: DataHolder.currentUser!.userId, classroomId: classroomId, role: role);
    userClassrooms.add(jsonEncode(userClassroom.toJson()));
    await prefs.setStringList('user-classrooms', userClassrooms);
  }

  static Future<List<ClassroomData>> loadAllClassroomsForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userClassroomsJson = prefs.getStringList('user-classrooms') ?? [];
    final userClassrooms = userClassroomsJson
        .map((jsonStr) => UserClassroomData.fromJson(jsonDecode(jsonStr)))
        .where((userClassroom) => userClassroom.userId == userId)
        .toList();

    final classroomsJson = prefs.getStringList('classrooms') ?? [];
    return classroomsJson
        .map((jsonStr) => ClassroomData.fromJson(jsonDecode(jsonStr)))
        .where((classroom) => userClassrooms.any((userClassroom) => userClassroom.classroomId == classroom.classroomId))
        .toList();
  }

  static Future<void> leaveClassroom(String classroomId) async {
    final prefs = await SharedPreferences.getInstance();
    final userClassrooms = prefs.getStringList('user-classrooms') ?? [];
    userClassrooms.removeWhere((jsonStr) {
      final userClassroom = UserClassroomData.fromJson(jsonDecode(jsonStr));
      return userClassroom.userId == DataHolder.currentUser!.userId && userClassroom.classroomId == classroomId;
    });
    await prefs.setStringList('user-classrooms', userClassrooms);
  }

  static Future<void> removeStudent(String userId, String classroomId) async {
    final prefs = await SharedPreferences.getInstance();
    final userClassrooms = prefs.getStringList('user-classrooms') ?? [];
    userClassrooms.removeWhere((jsonStr) {
      final userClassroom = UserClassroomData.fromJson(jsonDecode(jsonStr));
      return userClassroom.userId == userId && userClassroom.classroomId == classroomId;
    });
    await prefs.setStringList('user-classrooms', userClassrooms);
  }
}

class UserClassroomData {
  final String userId;
  final String classroomId;
  final String role;

  UserClassroomData({
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

  factory UserClassroomData.fromJson(Map<String, dynamic> json) {
    return UserClassroomData(
      userId: json['userId'],
      classroomId: json['classroomId'],
      role: json['role'],
    );
  }
}