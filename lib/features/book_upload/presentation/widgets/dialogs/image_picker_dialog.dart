import 'package:flutter/material.dart';
import 'package:flutter_library/features/book_upload/domain/entities/entities.dart';

/// Dialog widget for selecting image source (camera or gallery)
class ImagePickerDialog extends StatelessWidget {
  /// Callback function called when an image source is selected
  final Function(ImageSource source) onSourceSelected;

  const ImagePickerDialog({
    super.key,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Image'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSourceOption(
            context,
            icon: Icons.camera_alt,
            title: 'Take Photo',
            source: ImageSource.camera,
          ),
          _buildSourceOption(
            context,
            icon: Icons.photo_library,
            title: 'Choose from Gallery',
            source: ImageSource.gallery,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required ImageSource source,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onSourceSelected(source);
      },
    );
  }
}
