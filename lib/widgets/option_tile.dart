import 'package:flutter/material.dart';

import '../models/option_data.dart';

class OptionTile extends StatefulWidget {
  final OptionData option;
  final Function(int optionNumber) onOptionSelected;
  final bool isSelected;

  const OptionTile({
    super.key,
    required this.option,
    required this.onOptionSelected,
    required this.isSelected,
  });

  @override
  _OptionTileState createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
  }

  void _onOptionTapped() {
    widget.onOptionSelected(widget.option.optionNumber);
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        GestureDetector(
          onTap: _onOptionTapped,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: (widget.isSelected) ? Colors.green : Colors.grey[100]!),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Text("${String.fromCharCode(65 + widget.option.optionNumber)}. "),
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
                      if (widget.option.image != null)
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