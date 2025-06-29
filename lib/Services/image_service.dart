import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage(BuildContext context) async {
    final source = await _showImageSourceDialog(context);
    if (source == null) return null;
    final pickedFile = await _picker.pickImage(source: source);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  static Future<ImageSource?> _showImageSourceDialog(
    BuildContext context,
  ) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    );
  }
}
