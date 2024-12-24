import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

class ImageCropWidget extends StatelessWidget {
  final Uint8List imageBytes;
  final CropController cropController;
  final Function(CropResult) onCropped;
  final bool isProcessing;

  const ImageCropWidget({
    super.key,
    required this.imageBytes,
    required this.cropController,
    required this.onCropped,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return !isProcessing
        ? Crop(
      controller: cropController,
      image: imageBytes,
      onCropped: onCropped,
      interactive: true,
      maskColor: Colors.black45,
      initialRectBuilder: InitialRectBuilder.withArea(
        const Rect.fromLTWH(100, 250, 200, 200),
      ),
      cornerDotBuilder: (size, edge) => DotControl(
        color: {
          EdgeAlignment.topLeft: Colors.white,
          EdgeAlignment.topRight: Colors.white,
          EdgeAlignment.bottomRight: Colors.white,
          EdgeAlignment.bottomLeft: Colors.white,
        }[edge]!,
      ),
      willUpdateScale: (scale) => true,
      filterQuality: FilterQuality.high,
    ) :
    const Column(
      children: [
        SizedBox(height: 40),
        Align(
          alignment: Alignment.topCenter,
          child: CircularProgressIndicator()
        ),
      ],
    );
  }
}