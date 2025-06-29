import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker {
  static Future<XFile?> pickPhoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final option = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take Photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    );
    if (option != null) {
      final pickedFile = await picker.pickImage(source: option);
      return pickedFile;
    }
    return null;
  }
}
