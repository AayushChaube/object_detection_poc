import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future requestAll() async {
    await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
      Permission.videos,
      Permission.microphone,
    ].request();
  }
}
