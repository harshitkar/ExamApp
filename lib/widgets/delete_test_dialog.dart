import 'package:flutter/material.dart';

class DeleteTestDialog extends StatelessWidget {
  const DeleteTestDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Are you sure you want to delete this test?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);  // Dismiss dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);  // Confirm delete
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}