import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class TextRecognitionService {
  static Future<List<TextBlock>> extractTextBlocks(File imageFile) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.devanagiri);

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      return recognizedText.blocks;
    } catch (e) {
      return [];
    } finally {
      textRecognizer.close();
    }
  }
}
