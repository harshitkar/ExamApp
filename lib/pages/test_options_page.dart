import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ocr_app/homepage.dart';
import '../models/test_data.dart';

class AdditionalTestOptionsPage extends StatefulWidget {
  final TestData testData;

  const AdditionalTestOptionsPage({Key? key, required this.testData}) : super(key: key);

  @override
  State<AdditionalTestOptionsPage> createState() =>
      _AdditionalTestOptionsPageState();
}

class _AdditionalTestOptionsPageState extends State<AdditionalTestOptionsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _testNameController;
  late TextEditingController _startTimeController;
  late TextEditingController _deadlineController;
  late TextEditingController _testDurationController;

  DateTime? _startDateTime;
  DateTime? _deadlineDateTime;
  bool isEditTest = false;

  @override
  void initState() {
    super.initState();
    _testNameController = TextEditingController(
        text: widget.testData.testName
    );
    _startTimeController = TextEditingController(
        text: widget.testData.startFrom != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(widget.testData.startFrom)
            : ''
    );
    _deadlineController = TextEditingController(
        text: widget.testData.deadlineTime != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(widget.testData.deadlineTime)
            : ''
    );
    _testDurationController = TextEditingController(
        text: widget.testData.testTime > 0
            ? widget.testData.testTime.toString()
            : ''
    );
  }

  @override
  void dispose() {
    _testNameController.dispose();
    _startTimeController.dispose();
    _deadlineController.dispose();
    _testDurationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(
      BuildContext context, TextEditingController controller, bool isStart) async {
    DateTime initialDate =
    isStart ? (_startDateTime ?? DateTime.now()) : (_deadlineDateTime ?? DateTime.now());
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    DateTime fullDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _startDateTime = fullDateTime;
        widget.testData.startFrom = fullDateTime;
      } else {
        _deadlineDateTime = fullDateTime;
        widget.testData.deadlineTime = fullDateTime;
      }
      controller.text = DateFormat('yyyy-MM-dd HH:mm').format(fullDateTime);
    });
  }

  void _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      widget.testData.testName = _testNameController.text;
      widget.testData.testTime = int.tryParse(_testDurationController.text) ?? 0;

      try {
        await widget.testData.saveToLocalDatabase();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test saved successfully!')),
        );
        // Navigate back
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
        );

      } catch (e) {
        // Show error message if saving fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save test: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Options'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _onSave,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _testNameController,
                decoration: const InputDecoration(
                  labelText: 'Test Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a test name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startTimeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _pickDateTime(context, _startTimeController, true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deadlineController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _pickDateTime(context, _deadlineController, false),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _testDurationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Test Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the test duration';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
