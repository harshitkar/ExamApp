import 'package:flutter/material.dart';

class QuestionNavigationPanel extends StatelessWidget {
  final int currentQuestionIndex;
  final List<String> questions;
  final void Function(int) onNavigateToQuestion;
  final VoidCallback? onAddNewQuestion;
  final ScrollController? scrollController;
  final bool addNewQuestionEnabled;

  const QuestionNavigationPanel({
    super.key,
    required this.currentQuestionIndex,
    required this.questions,
    required this.onNavigateToQuestion,
    this.onAddNewQuestion,
    this.scrollController,
    this.addNewQuestionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Generate question navigation tiles
                  ...List.generate(questions.length, (index) {
                    return GestureDetector(
                      onTap: () => onNavigateToQuestion(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: index == currentQuestionIndex
                              ? const Color(0xFF0A1D37) // Selected color
                              : Colors.white, // Unselected color
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: const Color(0xFF0A1D37), // Border color
                          ),
                        ),
                        child: Text(
                          questions[index],
                          style: TextStyle(
                            color: index == currentQuestionIndex
                                ? Colors.white // Text color for selected tile
                                : const Color(0xFF0A1D37), // Text color for unselected tile
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                  // Add new question button (conditionally enabled)
                  if (addNewQuestionEnabled)
                    IconButton(
                      icon: const Icon(Icons.add),
                      color: const Color(0xFF0A1D37), // Icon color matching TestPage
                      onPressed: onAddNewQuestion,
                      tooltip: "Add new question",
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}