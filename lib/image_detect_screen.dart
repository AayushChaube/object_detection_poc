import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:object_detection_poc/yolo_service.dart';

class ImageDetectScreen extends StatefulWidget {
  const ImageDetectScreen({super.key});

  @override
  State<ImageDetectScreen> createState() => _ImageDetectScreenState();
}

class _ImageDetectScreenState extends State<ImageDetectScreen> {
  final picker = ImagePicker();
  final yolo = YoloService();
  List results = [];
  File? imageFile;

  @override
  void initState() {
    super.initState();

    yolo.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Detection')),
      body: Column(
        children: [
          ElevatedButton(onPressed: pickImage, child: Text("Upload Image")),

          if (imageFile != null)
            Stack(
              children: [
                Image.file(imageFile!),
                ...results.map((r) => Positioned(
                  left: r['x'] * 300,
                  top: r['y'] * 300,
                   child: Container(
                    padding: EdgeInsets.all(4),
                    color: Colors.red,
                    child: Text(r['label'])
                   ),
                ))
              ],
            )
        ],
      ),
    );
  }

  Future pickImage() async {
    final imgPicked = await picker.pickImage(source: ImageSource.gallery);

    if (imgPicked == null) return;

    imageFile = File(imgPicked.path);
    final bytes = await imageFile!.readAsBytes();
    final decoded = img.decodeImage(bytes)!;
    results = await yolo.detect(decoded);
    setState(() {});
  }
}
