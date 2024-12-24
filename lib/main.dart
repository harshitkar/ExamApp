import 'package:flutter/material.dart';
import 'package:ocr_app/pages/classroom_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  clearSharedPreferences();
  runApp(const MyApp());
}

Future<void> clearSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExamEase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ClassroomListPage(userId: "Harsh"),
    );
  }
}