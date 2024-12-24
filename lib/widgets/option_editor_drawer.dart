import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ocr_app/widgets/text_image_selection_row.dart';

import 'draggable_drawer.dart';

class OptionEditorDrawer extends StatelessWidget {
  final List<TextEditingController> textControllers;
  final List<Uint8List?> images;
  final List<VoidCallback> onSelectTextCallbacks;
  final List<VoidCallback> onCaptureImageCallbacks;
  final List<ValueChanged<String>> onTextChangedCallbacks;
  final ValueChanged<int> onSetCorrectOption;
  final int questionIndex;
  final int correctOptionIndex;
  final void Function()? deleteCurrentQuestion;

  const OptionEditorDrawer({
    super.key,
    required this.textControllers,
    required this.images,
    required this.onSelectTextCallbacks,
    required this.onCaptureImageCallbacks,
    required this.onTextChangedCallbacks,
    required this.questionIndex,
    required this.onSetCorrectOption,
    required this.correctOptionIndex,
    required this.deleteCurrentQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableDrawer(
      initialSize: 0.3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Question ${questionIndex+1}',
                  style: const TextStyle(
                    color: Color(0xFF0A1D37),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(onPressed: deleteCurrentQuestion, icon: const Icon(Icons.delete))
              ],
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < 5; i++) ...[
              TextImageSelectionRow(
                text: i == 0 ? 'Question' : 'Option $i',
                textController: textControllers[i],
                image: images[i],
                onSelectText: onSelectTextCallbacks[i],
                onCaptureImage: onCaptureImageCallbacks[i],
                onTextChanged: onTextChangedCallbacks[i],
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              "Choose correct option number",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1D37),
              ),
            ),
            DropdownButton<int>(
              value: correctOptionIndex,
              onChanged: (value) {
                if (value != null) {
                  onSetCorrectOption(value);
                }
              },
              items: List.generate(
                4,
                    (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text('Option ${index + 1}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}