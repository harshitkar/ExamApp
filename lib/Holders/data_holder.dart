import 'package:flutter/material.dart';
import '../models/classroom_data.dart';
import '../models/test_data.dart';
import '../models/user_data.dart';

class DataHolder {
  static ClassroomData? currentClassroom;
  static UserData? currentUser;
  static TestData? currentTest;
}
