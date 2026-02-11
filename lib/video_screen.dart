import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:object_detection_poc/yolo_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final picker = ImagePicker();
  final yolo = YoloService();
  VideoPlayerController? controller;
  List results = [];

  @override
  void initState() {
    super.initState();

    yolo.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Detection')),
      body: Column(
        children: [
          ElevatedButton(onPressed: pickVideo, child: Text("Upload Video")),

          if (controller != null)
            AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: Stack(
                children: [
                    VideoPlayer(controller!),
                    ...results.map((r) => Positioned(
                        left: r['x'] * 300,
                        top: r['y'] * 300,
                        child: Container(
                            color: Colors.blue,
                            child: Text(r['label']),
                        ),
                    ))
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future pickVideo() async {
    final file = await picker.pickVideo(source: ImageSource.gallery);

    if (file == null) return;

    controller = VideoPlayerController.file(File(file.path));
    await controller!.initialize();
    controller!.play();
    setState(() {});
    processFrames(file.path);
  }

  Future processFrames(String path) async {
    final dir = await getTemporaryDirectory();

    for (int i = 0; i < 10; i++) {
      final thumb = await VideoThumbnail.thumbnailFile(
        video: path,
        thumbnailPath: dir.path,
        timeMs: i * 500,
        imageFormat: ImageFormat.PNG,
      );

      if (thumb == null) continue;

      final bytes = File(thumb).readAsBytesSync();
      final image = img.decodeImage(bytes)!;
      results = await yolo.detect(image);
      setState(() {});
      await Future.delayed(Duration(milliseconds: 500));
    }
  }
}
