import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection_poc/yolo_service.dart';
import 'package:object_detection_poc/yuv_converter.dart';

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  late CameraController camera;
  final yolo = YoloService();
  List results = [];

  @override
  void initState() {
    super.initState();

    initCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(camera),
          ...results.map((r) => Positioned(
            left: r['x'] * 400,
            top: r['y'] * 400,
            child: Container(
              color: Colors.green,
              child: Text(r['label']),
            ),
          ))
        ],
      ),
    );
  }

  Future initCamera() async {
    await yolo.init();
    final cams = await availableCameras();
    camera = CameraController(cams[0], ResolutionPreset.medium);
    await camera.initialize();
    camera.startImageStream((frame) async {
      final imgData = convertYUV420(frame);
      results = await yolo.detect(imgData);
      setState(() {});
    });
  }
}