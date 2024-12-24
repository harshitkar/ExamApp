import 'dart:typed_data';
import 'package:flutter/material.dart';

class TextImageSelectionRow extends StatelessWidget {
  final String text;
  final TextEditingController textController;
  final Uint8List? image;
  final VoidCallback onSelectText;
  final VoidCallback onCaptureImage;
  final ValueChanged<String> onTextChanged;

  const TextImageSelectionRow({
    super.key,
    required this.text,
    required this.textController,
    required this.image,
    required this.onSelectText,
    required this.onCaptureImage,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label Text
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A1D37),
            ),
          ),
          const SizedBox(height: 8),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: onSelectText,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1D37),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Extract Text'),
              ),
              ElevatedButton(
                onPressed: onCaptureImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1D37),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  (image == null) ? 'Crop Image' : 'Delete Image',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: textController,
            maxLines: null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selected Text',
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF0A1D37), // Text color
            ),
            onChanged: onTextChanged,
          ),
          const SizedBox(height: 8),

          if (image != null)
            Image.memory(
              image!,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
        ],
      ),
    );
  }
}
