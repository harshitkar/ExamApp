import 'package:flutter/material.dart';
import 'test_card_widget.dart';
import 'package:ocr_app/models/test_data.dart';

class TestList extends StatelessWidget {
  final List<TestData> tests;
  final Function(int) deleteTest, editTest;

  const TestList({
    required this.tests,
    required this.deleteTest,
    required this.editTest,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return TestCardWidget(
          test: test,
          index: index,
          deleteTest: deleteTest,
          editTest: editTest,
        );
      },
    );
  }
}
