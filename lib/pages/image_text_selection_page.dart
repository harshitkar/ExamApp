import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr_app/models/test_data.dart';
import 'package:ocr_app/pages/test_options_page.dart';
import 'package:ocr_app/services/text_recognition_service.dart';
import 'package:ocr_app/widgets/image_crop_widget.dart';
import 'package:ocr_app/widgets/text_selection_panel.dart';

import '../models/question_data.dart';
import '../widgets/question_navigation_widget.dart';

class ImageTextSelectionPage extends StatefulWidget {
  const ImageTextSelectionPage({super.key});

  @override
  State<ImageTextSelectionPage> createState() => _ImageTextSelectionPageState();
}

class _ImageTextSelectionPageState extends State<ImageTextSelectionPage> {
  File? imageFile;
  final List<QuestionData> _questions = [QuestionData()];
  int _currentQuestionIndex = 0;
  int _currentOptionIndex = -1;
  final CropController _cropController = CropController();
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;
  bool _isCroppingEnabledForTextExtraction = false;
  bool _isCroppingEnabledForImageCapture = false;
  final ImagePicker _picker = ImagePicker();
  late List<TextEditingController> _textControllers;
  bool _isTextSyncInProgress = false;

  @override
  void initState() {
    super.initState();
    _initializeTextControllers();
  }

  void _initializeTextControllers() {
    _textControllers = [
      TextEditingController(text: _questions[_currentQuestionIndex].questionText)
        ..addListener(() {
          if (!_isTextSyncInProgress && !_isCroppingEnabledForTextExtraction) {
            _questions[_currentQuestionIndex].questionText = _textControllers[0].text;
          }
        }),
      for (int i = 0; i < _questions[_currentQuestionIndex].options.length; i++)
        TextEditingController(text: _questions[_currentQuestionIndex].options[i].optionText)
          ..addListener(() {
            if (!_isTextSyncInProgress && !_isCroppingEnabledForTextExtraction) {
              _questions[_currentQuestionIndex].options[i].optionText = _textControllers[i + 1].text;
            }
          }),
    ];
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add(QuestionData(
        questionNumber: _questions.length + 1,
      ));
      _currentQuestionIndex = _questions.length - 1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deleteCurrentQuestion() {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(_currentQuestionIndex);
        for (int i = _currentQuestionIndex; i < _questions.length; i++) {
          _questions[i].questionNumber--;
        }
        _currentQuestionIndex = (_currentQuestionIndex > 0)
            ? _currentQuestionIndex - 1
            : 0;
      });
    } else {
      setState(() {
        _questions[0] = QuestionData(
          questionNumber: 1,
        );
      });
    }
  }

  void _navigateToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      setState(() {
        _currentQuestionIndex = index;
      });
    }
  }

  Future<void> _onCropped(CropResult cropResult) async {
    if (cropResult is CropSuccess) {
      final Uint8List croppedImage = cropResult.croppedImage;
      final currentQuestion = _questions[_currentQuestionIndex];

      if (_isCroppingEnabledForImageCapture) {
        setState(() {
          if (_currentOptionIndex == -1) {
            currentQuestion.questionImage = croppedImage;
          } else {
            currentQuestion.options[_currentOptionIndex].image = croppedImage;
          }
        });
        _isCroppingEnabledForImageCapture = false;
      } else if (_isCroppingEnabledForTextExtraction) {
        final tempFile = File('${Directory.systemTemp.path}/cropped_image.jpg')
          ..writeAsBytesSync(croppedImage);

        final textBlocks = await TextRecognitionService.extractTextBlocks(tempFile);
        final extractedText = textBlocks.map((block) => block.text).join(' ');

        if (extractedText.isNotEmpty) {
          setState(() {
            _isTextSyncInProgress = true;  // Prevent syncing during text extraction
            if (_currentOptionIndex == -1) {
              currentQuestion.questionText = extractedText;
              _textControllers[0].text = extractedText;
            } else {
              currentQuestion.options[_currentOptionIndex].optionText = extractedText;
              _textControllers[_currentOptionIndex+1].text = extractedText;
            }
            _isTextSyncInProgress = false;  // Allow syncing again
          });
        } else {
          Fluttertoast.showToast(
            msg: "Try to select and maximize the area to extract text",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
        _isCroppingEnabledForTextExtraction = false;
      }
    }
    _currentOptionIndex = -1;
    setState(() => _isProcessing = false);
  }

  void _onCaptureImage(int optionIndex) {
    final currentQuestion = _questions[_currentQuestionIndex];

    if (optionIndex == -1) {
      if (currentQuestion.questionImage != null) {
        setState(() {
          currentQuestion.questionImage = null;
        });
      } else {
        _currentOptionIndex = optionIndex;
        setState(() {
          _isProcessing = true;
          _isCroppingEnabledForImageCapture = true;
          _cropController.crop();
        });
      }
    } else {
      final currentOption = currentQuestion.options[optionIndex];

      if (currentOption.image != null) {
        setState(() {
          currentOption.image = null;
        });
      } else {
        _currentOptionIndex = optionIndex;
        setState(() {
          _isProcessing = true;
          _isCroppingEnabledForImageCapture = true;
          _cropController.crop();
        });
      }
    }
  }

  void _onExtractText(int optionIndex) {
    _currentOptionIndex = optionIndex;
    setState(() {
      _isProcessing = true;
      _isCroppingEnabledForTextExtraction = true;
      _cropController.crop();
    });
  }

  void _onSave() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdditionalTestOptionsPage(testData: TestData(questions: _questions)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestionIndex + 1}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Question',
            onPressed: _deleteCurrentQuestion,
          ),
          IconButton(
            icon: const Icon(Icons.done),
            color: Colors.blue,
            onPressed: _onSave,
          ),
        ],
      ),
      body: Column(
        children: [
          QuestionNavigationPanel(
            currentQuestionIndex: _currentQuestionIndex,
            questions: List.generate(_questions.length, (index) => 'Q${index + 1}'),
            onNavigateToQuestion: _navigateToQuestion,
            onAddNewQuestion: _addNewQuestion,
            scrollController: _scrollController,
          ),
          Expanded(
            child: Stack(
              children: [
                (imageFile != null)
                    ? ImageCropWidget(
                  imageBytes: imageFile!.readAsBytesSync(),
                  cropController: _cropController,
                  onCropped: _onCropped,
                  isProcessing: _isProcessing,
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _getImage(ImageSource.camera),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A1D37),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Capture Image'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _getImage(ImageSource.gallery),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A1D37),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Pick from Gallery'),
                      ),
                    ],
                  ),
                ),
                TextSelectionPanelDrawer(
                  textControllers: _textControllers,
                  images: [
                    currentQuestion.questionImage,
                    ...currentQuestion.options.map((o) => o.image),
                  ],
                  onSelectTextCallbacks: List.generate(
                    5,
                        (i) => () => _onExtractText(i - 1),
                  ),
                  onCaptureImageCallbacks: List.generate(
                    5,
                        (i) => () => _onCaptureImage(i - 1),
                  ),
                  onTextChangedCallbacks: [
                        (newText) {
                      setState(() {
                        currentQuestion.questionText = newText;
                      });
                    },
                    ...List.generate(currentQuestion.options.length, (i) {
                      return (newText) {
                        setState(() {
                          currentQuestion.options[i].optionText = newText;
                        });
                      };
                    }),
                  ],
                  questionIndex: _currentQuestionIndex,
                ),
                if (imageFile != null)
                  ElevatedButton(
                    onPressed: () => {
                      setState(() {
                        imageFile = null;
                      })
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A1D37),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Remove Image'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}