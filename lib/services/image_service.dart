import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static Future<String?> pickAndSaveImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);
      if (image == null) return null;

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final savedImage =
          await File(image.path).copy('${directory.path}/$fileName');

      return savedImage.path;
    } catch (e) {
      return null;
    }
  }
}