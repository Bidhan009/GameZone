import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImagePickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery or camera
  static Future<File?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      print('Starting image pick from source: $source'); // Debug log
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
      );

      print('Picked file: ${pickedFile?.path}'); // Debug log

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        print('Returning file: ${file.path}'); // Debug log
        return file;
      }
      
      print('No file picked'); // Debug log
      return null;
    } catch (e) {
      print('Error picking image: $e'); // Debug log
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Pick image from gallery
  static Future<File?> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    return pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  // Pick image from camera
  static Future<File?> pickFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    return pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  // Show image source selection dialog
  static Future<File?> showImageSourceDialog(
    BuildContext context, {
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    // Show a simple bottom sheet for source selection
    return showModalBottomSheet<File?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickFromGallery(
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  );
                  // Return to caller by completing the modal
                  if (context.mounted) {
                    Navigator.of(context).pop(file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickFromCamera(
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  );
                  // Return to caller by completing the modal
                  if (context.mounted) {
                    Navigator.of(context).pop(file);
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Save image to app directory for temporary storage
  static Future<String?> saveImageTemporarily(File imageFile) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final savedImage = await imageFile.copy('${directory.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image temporarily: $e');
      return null;
    }
  }

  // Get image file size in MB
  static double getImageFileSize(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024); // Convert to MB
  }

  // Validate image file
  static bool isValidImageFile(File file) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final extension = path.extension(file.path).toLowerCase();
    return validExtensions.contains(extension);
  }

  // Compress image if needed
  static Future<File?> compressImageIfNeeded(
    File imageFile, {
    double maxSizeMB = 2.0,
    int quality = 85,
  }) async {
    try {
      final fileSize = getImageFileSize(imageFile);
      
      if (fileSize <= maxSizeMB) {
        return imageFile; // No compression needed
      }

      // Compress the image
      final compressedFile = await pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: quality,
      );

      if (compressedFile != null) {
        // Replace original with compressed
        await imageFile.delete();
        return compressedFile;
      }

      return imageFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return imageFile;
    }
  }
}
