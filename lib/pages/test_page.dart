import 'dart:async';

import 'package:flutter/material.dart';

import '../homepage.dart';
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
  late List<int?> selectedOptions;
  int previouslySelectedOption = 0;
  int currentQuestionIndex = 0;
  late int remainingTimeInSeconds = 0; // Remaining time in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    selectedOptions = List<int?>.filled(widget.testData.questions.length, null);
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
      selectedOptions[currentQuestionIndex] = optionNumber;
    });
  }

  void _onSubmitCallback() {
    _showSubmitConfirmationDialog();
  }

  void _showSubmitConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Submit Test?"),
          content: const Text("Are you sure you want to submit the test?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _computeAndShowResult(); // Compute and display result
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _computeAndShowResult() {
    // Compute the result (example logic; replace with your own)
    final totalQuestions = widget.testData.questions.length;
    int correctAnswers = 0;

    for (int i = 0; i < totalQuestions; i++) {
      final question = widget.testData.questions[i];
      if (question.correctOptionIndex == selectedOptions[i]) {
        correctAnswers++;
      }
    }

    final result = ((correctAnswers / totalQuestions) * 100).round();

    // Show the result dialog
    _showResultDialog(result);
  }

  void _showResultDialog(int result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Test Submitted"),
          content: Text("Your score is $result%."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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
                ...currentQuestion.options.map((option) {
                    return OptionTile(
                      option: option,
                      onOptionSelected: handleOptionSelection,
                      isSelected: selectedOptions[currentQuestionIndex] == option.optionNumber,
                      );
                    }).toList(),
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
                onPressed: _onSubmitCallback,
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
