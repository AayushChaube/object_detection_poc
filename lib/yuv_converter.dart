import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

img.Image convertYUV420(CameraImage image) {
  final width = image.width;
  final height = image.height;
  final img.Image imgImage = img.Image(width: width, height: height);

  final yPlane = image.planes[0].bytes;
  final uPlane = image.planes[1].bytes;
  final vPlane = image.planes[2].bytes;

  int yIndex = 0;
  int uvIndex = 0;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final yValue = yPlane[yIndex++];

      final uvOffset = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);
      final uValue = uPlane[uvOffset];
      final vValue = vPlane[uvOffset];

      int r = (yValue + 1.403 * (vValue - 128)).round();
      int g = (yValue - 0.344 * (uValue - 128) - 0.714 * (vValue - 128))
          .round();
      int b = (yValue + 1.770 * (uValue - 128)).round();

      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);
      imgImage.setPixelRgba(x, y, r, g, b, 0);
    }
  }

  return imgImage;
}
