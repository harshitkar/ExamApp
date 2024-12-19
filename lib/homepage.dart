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
  bool noTestsPosted = false;

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  // Load test data from local storage or any other source
  Future<void> _loadTestData() async {
    try {
      List<TestData> loadedTests = await TestData.getAllTestsFromLocalDatabase();
      setState(() {
        if (loadedTests.isEmpty) {
          noTestsPosted = true;
        } else {
          tests = loadedTests;
        }
      });
    } catch (e) {
      print('Error loading test data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load test data: $e')),
      );
    }
  }

  // Function to delete a test from the list and local database
  Future<void> _deleteTest(int index) async {
    final testId = tests[index].testId;
    try {
      await TestData.deleteFromLocalDatabase(testId);  // Delete from local storage
      setState(() {
        tests.removeAt(index);  // Remove from the list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete test: $e')),
      );
    }
    setState(() {
      if(tests.isEmpty) {
        noTestsPosted = true;
      }
    });
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
          ? !noTestsPosted
          ? const Center(child: CircularProgressIndicator())
          : const Text("No test Posted Yet")
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
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  // Show a confirmation dialog before deleting
                  bool? confirmDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text('Are you sure you want to delete this test?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);  // Dismiss dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);  // Confirm delete
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  // If confirmed, delete the test
                  if (confirmDelete == true) {
                    await _deleteTest(index);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
