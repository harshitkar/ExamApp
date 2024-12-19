import 'dart:async';

import 'package:flutter/material.dart';

import '../models/option_data.dart';
import '../models/question_data.dart';
import '../models/test_data.dart';
import '../widgets/option_tile.dart';
import '../widgets/question_navigation_widget.dart';

void main() {
  runApp(const ExamEaseApp());
}

class ExamEaseApp extends StatelessWidget {
  const ExamEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final testData = TestData(
      testId: "w8qihcwd",
      testName: "Sample Test",
      testTime: 45,
      questions: [
        QuestionData(
          questionNumber: 1,
          questionText: "What is 2 + 2?",
          options: [
            OptionData(optionText: "3", optionNumber: 1),
            OptionData(optionText: "4", optionNumber: 2),
            OptionData(optionText: "5", optionNumber: 3),
            OptionData(optionText: "6", optionNumber: 4),
          ],
          correctOptionIndex: 1,
        ),
        QuestionData(
          questionNumber: 2,
          questionText: "What is the capital of France?",
          options: [
            OptionData(optionText: "Berlin", optionNumber: 1),
            OptionData(optionText: "Madrid", optionNumber: 2),
            OptionData(optionText: "Paris", optionNumber: 3),
            OptionData(optionText: "Rome", optionNumber: 4),
          ],
          correctOptionIndex: 2,
        ),
        QuestionData(
          questionNumber: 3,
          questionText: "What is the square root of 16?",
          options: [
            OptionData(optionText: "2", optionNumber: 1),
            OptionData(optionText: "4", optionNumber: 2),
            OptionData(optionText: "6", optionNumber: 3),
            OptionData(optionText: "8", optionNumber: 4),
          ],
          correctOptionIndex: 1,
        ),
      ],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestPage(testData: testData),
    );
  }
}

class TestPage extends StatefulWidget {
  final TestData testData;

  const TestPage({required this.testData, Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int? selectedOption;
  int currentQuestionIndex = 0;
  late int remainingTimeInSeconds = 0; // Remaining time in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    remainingTimeInSeconds = widget.testData.testTime * 60;
    _startTimer();

  }

  void _navigateToQuestion(int index) {
    if (index >= 0 && index < widget.testData.questions.length) {
      setState(() {
        currentQuestionIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTimeInSeconds > 0) {
        setState(() {
          remainingTimeInSeconds--;
        });
      } else {
        timer.cancel();
        _showTimeUpDialog();
      }
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Time's Up!"),
          content: const Text("Your test time has ended."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Add any additional action (like submitting the test)
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void handleOptionSelection(int optionNumber) {
    setState(() {
      selectedOption = optionNumber; // Store the selected option
    });
    print("Selected option: $optionNumber");
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.testData.questions[currentQuestionIndex];
    final totalQuestions = widget.testData.questions.length;
    final progressPercentage = (currentQuestionIndex + 1) / totalQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.testData.testName,
                    style: const TextStyle(
                      color: Color(0xFF0A1D37),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF0A1D37)),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(remainingTimeInSeconds), // Display formatted time
                        style: const TextStyle(
                          color: Color(0xFF0A1D37),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: progressPercentage,
                    color: const Color(0xFF0A1D37),
                    backgroundColor: Colors.grey[300],
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${currentQuestionIndex + 1}/$totalQuestions",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${(progressPercentage * 100).toStringAsFixed(0)}% Complete",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Question and Options Section
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question Text
                      Text(
                        currentQuestion.questionText,
                        style: const TextStyle(
                          color: Color(0xFF0A1D37),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (currentQuestion.questionImage != null)
                        Image.memory(
                          currentQuestion.questionImage!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      const SizedBox(height: 16),
                      ...currentQuestion.options.map(
                            (option) => OptionTile(
                          option: option,
                          onOptionSelected: handleOptionSelection,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation Buttons and Submit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: QuestionNavigationPanel(
                currentQuestionIndex: currentQuestionIndex,
                questions: List.generate(widget.testData.questions.length, (index) => 'Q${index + 1}'),
                onNavigateToQuestion: _navigateToQuestion,
                addNewQuestionEnabled: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Submit test logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1D37),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Submit Test",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
