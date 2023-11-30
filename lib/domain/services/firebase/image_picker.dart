import 'package:image_picker/image_picker.dart';

ImagePicker imagePicker = ImagePicker();

Future<XFile?> pickVideoFromCamera() {
  return imagePicker.pickVideo(source: ImageSource.camera);
}

Future<XFile?> pickVideoFromGalery() {
  return imagePicker.pickVideo(source: ImageSource.gallery);
}
