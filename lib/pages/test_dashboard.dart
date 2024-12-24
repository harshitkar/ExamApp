import 'package:flutter/material.dart';
import 'package:ocr_app/models/test_data.dart';
import 'package:ocr_app/pages/question_builder_page.dart';
import 'package:ocr_app/widgets/test_list.dart';

class TestDashboard extends StatefulWidget {
  const TestDashboard({super.key});

  @override
  State<TestDashboard> createState() => _TestDashboardState();
}

class _TestDashboardState extends State<TestDashboard> {
  List<TestData> tests = [];
  bool isLoading = true; // Flag for loading state

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  Future<void> _loadTestData() async {
    try {
      List<TestData> loadedTests = await TestData.getAllTestsFromLocalDatabase();
      setState(() {
        tests = loadedTests;
        isLoading = false; // Data loading complete
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Set loading to false if there's an error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load test data: $e')),
      );
    }
  }

  Future<void> _deleteTest(int index) async {
    final testId = tests[index].testId;
    try {
      await TestData.deleteFromLocalDatabase(testId);
      setState(() {
        tests.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete test: $e')),
      );
    }
  }

  Future<void> _editTest(int index) async {
    final test = tests[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionBuilderPage(testData: test),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExamEase'),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : tests.isEmpty
            ? const Center(
          child: Text(
            "No test Posted Yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        )
            : TestList(tests: tests, deleteTest: _deleteTest, editTest: _editTest),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionBuilderPage(testData: TestData()),
            ),
          );
        },
        backgroundColor: const Color(0xFF0A1D37), // Matching button color
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
