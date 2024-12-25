import 'package:flutter/material.dart';
import 'package:ocr_app/models/test_data.dart';
import 'package:ocr_app/pages/test_attempt_page.dart';

import '../Holders/data_holder.dart';

class TestActionButtons extends StatelessWidget {
  final TestData test;

  const TestActionButtons({required this.test, super.key});

  @override
  Widget build(BuildContext context) {
    return test.result == -1 ?
    ElevatedButton(
      onPressed: () {
        DataHolder.currentTest = test;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TestAttemptPage(),
          ),
        );
      },
      child: const Text('Start Test'),
    ) :
    Align(
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          const Text(
            'Submitted',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
          Text(
            'Result: ${test.result}%',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
  );
  }
}
