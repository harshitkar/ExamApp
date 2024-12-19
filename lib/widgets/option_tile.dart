import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/option_data.dart';

class OptionTile extends StatefulWidget {
  final OptionData option;
  final Function(int selectedOption) onOptionSelected;

  const OptionTile({
    super.key,
    required this.option,
    required this.onOptionSelected,
  });

  @override
  _OptionTileState createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {
  late Uint8List? _imageData;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    _imageData = widget.option.image;
  }

  void _onOptionTapped() {
    setState(() {
      isSelected = !isSelected;  // Toggle selection state
    });

    widget.onOptionSelected(widget.option.optionNumber);
  }

  @override
  Widget build(BuildContext context) {
    // Print the image data length (for debugging)
    if (_imageData != null) {
      print("Image data length: ${_imageData!.length}");
    } else {
      print("No image provided");
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _onOptionTapped,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? Colors.green : Colors.grey[100]!),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Text("${String.fromCharCode(65 + widget.option.optionNumber - 1)}. "),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.option.optionText,
                        style: const TextStyle(
                          color: Color(0xFF0A1D37),
                          fontSize: 16,
                        ),
                      ),
                      if (widget.option.image != null)
                        const SizedBox(height: 8),
                      Image.memory(
                        widget.option.image!,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16)
      ],
    );
  }
}