import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class YoloService {
  late Interpreter interpreter;
  late List<String> labels;

  Future init() async {
    InterpreterOptions()
      ..useMetalDelegateForIOS = true
      ..useNnApiForAndroid = true;
    interpreter = await Interpreter.fromAsset('models/yolov8n_float32.tflite');
    labels = await _loadLabels();
  }

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString('assets/labels.txt');

    return raw.split('\n');
  }

  Future<List<Map>> detect(img.Image image) async {
    final input = _preprocess(image);
    final output = List.generate(1, (_) => List.filled(25000 * 85, 0.0));
    // final output = List.generate(1, (_) => List.generate(84, (_) => List.filled(8400, 0.0)));

    interpreter.run(input, output);

    return _postProcess(output[0]);
  }

  Uint8List _preprocess(img.Image image) {
    final resized = img.copyResize(image, width: 640, height: 640);
    final input = Float32List(1 * 640 * 640 * 3);
    int i = 0;

    for (var y = 0; y < 640; y++) {
      for (var x = 0; x < 640; x++) {
        final pixel = resized.getPixel(x, y);
        input[i++] = pixel.r / 255;
        input[i++] = pixel.g / 255;
        input[i++] = pixel.b / 255;
      }
    }

    return input.buffer.asUint8List();
  }

  List<Map> _postProcess(List<double> output) {
    List<Map> results = [];

    for (int i = 0; i < 25200; i++) {
      final confidence = output[i * 85 + 4];

      if (confidence > 0.4) {
        final cls = output.sublist(i * 85 + 5, i * 85 + 85);
        final classId = cls.indexOf(cls.reduce((a, b) => a > b ? a : b));
        results.add({
          "label": labels[classId],
          "confidence": confidence,
          "x": output[i * 85],
          "y": output[i * 85 + 1],
          "w": output[i * 85 + 2],
          "h": output[i * 85 + 3],
        });
      }
    }

    return results;
  }
}
