import 'package:flutter/material.dart';
import 'package:ocr_app/Holders/data_holder.dart';
import 'package:ocr_app/models/user_data.dart';
import 'package:ocr_app/pages/classroom_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure the Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Clear shared preferences
  await clearSharedPreferences();
  // DataHolder.currentUser = UserData(userId: "Harsh1234", username: 'Harsh',phoneNumber: "9924791022");
  DataHolder.currentUser = UserData(userId: "Onkar4321", username: 'Onkar',phoneNumber: "9924791022");

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
      home: const ClassroomListPage(),
    );
  }
}