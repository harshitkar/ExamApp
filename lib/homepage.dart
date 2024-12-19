import 'package:flutter/material.dart';
import 'package:ocr_app/models/test_data.dart';  // Assuming your TestData model is here
import 'package:ocr_app/pages/image_text_selection_page.dart';
import 'package:ocr_app/pages/test_page.dart';  // Import the TestPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TestData> tests = [];

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  // Load test data from local storage or any other source
  Future<void> _loadTestData() async {
    try {
      // Assuming `loadFromLocalDatabase` is a method in TestData to get the list of tests
      List<TestData> loadedTests = await TestData.getAllTestsFromLocalDatabase();
      setState(() {
        tests = loadedTests;
      });
    } catch (e) {
      print('Error loading test data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load test data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImageTextSelectionPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: tests.isEmpty
          ? const Center(child: CircularProgressIndicator())  // Loading indicator until data is fetched
          : ListView.builder(
        itemCount: tests.length,
        itemBuilder: (context, index) {
          final test = tests[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(test.testName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start Time: ${test.startFrom}'),
                  Text('Deadline: ${test.deadlineTime}'),
                  Text('Duration: ${test.testTime} minutes'),
                ],
              ),
              onTap: () {
                // Navigate to the TestPage with the selected test's data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestPage(testData: test),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
