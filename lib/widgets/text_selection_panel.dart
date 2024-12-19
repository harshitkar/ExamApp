import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ocr_app/widgets/selection_row.dart';

import 'draggable_drawer.dart';

class TextSelectionPanelDrawer extends StatelessWidget {
  final List<TextEditingController> textControllers;
  final List<Uint8List?> images;
  final List<VoidCallback> onSelectTextCallbacks;
  final List<VoidCallback> onCaptureImageCallbacks;
  final List<ValueChanged<String>> onTextChangedCallbacks;
  final int questionIndex;

  const TextSelectionPanelDrawer({
    Key? key,
    required this.textControllers,
    required this.images,
    required this.onSelectTextCallbacks,
    required this.onCaptureImageCallbacks,
    required this.onTextChangedCallbacks,
    required this.questionIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableDrawer(
      initialSize: 0.3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${questionIndex+1}',
              style: const TextStyle(
                color: Color(0xFF0A1D37),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < 5; i++) ...[
              SelectionRow(
                text: i == 0 ? 'Question' : 'Option $i',
                textController: textControllers[i],
                image: images[i],
                onSelectText: onSelectTextCallbacks[i],
                onCaptureImage: onCaptureImageCallbacks[i],
                onTextChanged: onTextChangedCallbacks[i],
              ),
              const SizedBox(height: 20)
            ],
          ],
        ),
      ),
    );
  }
}