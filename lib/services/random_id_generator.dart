import 'package:uuid/uuid.dart';

class RandomIdGenerator {
  static const Uuid _uuid = Uuid();

  static String generateId() {
    String questionId = _uuid.v4();
    return questionId;
  }
}
