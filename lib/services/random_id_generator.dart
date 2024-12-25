import 'dart:math';

import 'package:uuid/uuid.dart';

class RandomIdGenerator {
  static const Uuid _uuid = Uuid();
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  static String generateClassroomId({int length = 6}) {
    final Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => _chars.codeUnitAt(random.nextInt(_chars.length)),
      ),
    );
  }

  static String generateId() {
    String id = _uuid.v4();
    return id;
  }
}
