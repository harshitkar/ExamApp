import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ocr_app/Holders/classroom_holder.dart';
import 'package:ocr_app/pages/test_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/classroom_data.dart';

class ClassroomListPage extends StatefulWidget {
  final String userId;

  const ClassroomListPage({
    required this.userId,
    super.key,
  });

  @override
  State<ClassroomListPage> createState() => _ClassroomListPageState();
}

class _ClassroomListPageState extends State<ClassroomListPage> {
  List<ClassroomData> classrooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    try {
      final loadedClassrooms = await ClassroomData.loadAllClassroomsForUser(widget.userId);
      setState(() {
        classrooms = loadedClassrooms;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classrooms: $e')),
      );
    }
  }

  Future<void> _deleteClassroom(int index) async {
    final classroomId = classrooms[index].classroomId;
    await ClassroomData.deleteClassroom(classroomId);
    setState(() {
      classrooms.removeAt(index);
    });
  }

  Future<void> _leaveClassroom(int index) async {
    final classroomId = classrooms[index].classroomId;
    await ClassroomData.leaveClassroom(widget.userId, classroomId);
    setState(() {
      classrooms.removeAt(index);
    });
  }

  Future<void> _addClassroomDialog() async {
    final TextEditingController classroomNameController = TextEditingController();
    bool isSubmitting = false;
    ClassroomData? newClassroom;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Classroom'),
              content: TextField(
                controller: classroomNameController,
                decoration: const InputDecoration(
                  labelText: 'Classroom Name',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                    if (classroomNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Classroom name cannot be empty')),
                      );
                      return;
                    }
                    setState(() {
                      isSubmitting = true;
                    });
                    try {
                      newClassroom = ClassroomData(
                        classroomName: classroomNameController.text.trim(),
                        createdAt: DateTime.now(),
                      );
                      await newClassroom!.saveClassroom();

                      await newClassroom!.joinClassroom(widget.userId, 'teacher');

                      setState(() {
                        isSubmitting = false;
                      });

                      Navigator.pop(context);  // Close the dialog

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Classroom added successfully')),
                      );
                    } catch (e) {
                      setState(() {
                        isSubmitting = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add classroom: $e')),
                      );
                    }
                  },
                  child: isSubmitting
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newClassroom != null) {
      setState(() {
        classrooms.add(newClassroom!);
      });
    }
  }

  Future<void> _joinClassroomDialog() async {
    final TextEditingController classroomIdController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Join Classroom'),
          content: TextField(
            controller: classroomIdController,
            decoration: const InputDecoration(
              labelText: 'Enter Classroom Code',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final classroomId = classroomIdController.text.trim();
                if (classroomId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Classroom code cannot be empty')),
                  );
                  return;
                }
                try {
                  ClassroomData? classroom = await ClassroomData.loadClassroomData(classroomId);
                  if (classroom != null) {
                    print(1);
                    await classroom.joinClassroom(widget.userId, 'student');
                    setState(() {
                      classrooms.add(classroom);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Joined classroom successfully')),
                    );
                    Navigator.pop(context);
                  } else {
                    print(2);
                    const SnackBar(content: Text('No classroom found'));
                  }

                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to join classroom: $e')),
                  );
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom List'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : classrooms.isEmpty
          ? const Center(
        child: Text(
          'No classrooms available.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
      )
          : ListView.builder(
        itemCount: classrooms.length,
        itemBuilder: (context, index) {
          final classroom = classrooms[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(classroom.classroomName),
              subtitle: Text('Created on: ${classroom.createdAt}\ncode: ${classroom.classroomId}'),
              trailing: PopupMenuButton<int>(
                onSelected: (value) {
                  if (value == 1) {
                    _deleteClassroom(index);
                  } else {
                    _leaveClassroom(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 1, child: Text('Delete')),
                  const PopupMenuItem(value: 2, child: Text('Leave')),
                ],
              ),
              onTap: () {
                ClassroomDataHolder.data = classroom;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestListPage(classroomData: classroom),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _addClassroomDialog,
            tooltip: 'Add Classroom',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _joinClassroomDialog,
            tooltip: 'Join Classroom',
            child: const Icon(Icons.group_add),
          ),
        ],
      ),
    );
  }
}