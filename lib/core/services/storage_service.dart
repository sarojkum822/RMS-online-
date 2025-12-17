import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // 1. Pick Image
  Future<File?> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
    return null;
  }

  // 1b. Pick Multiple Images
  Future<List<File>> pickMultiImage() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    return pickedFiles.map((e) => File(e.path)).toList();
  }

  // 2. Compress Image
  // Targeted for mobile display (e.g. 800px width, 70% quality) to save bandwidth/storage
  Future<File?> compressImage(File file, {int minWidth = 800, int quality = 70}) async {
    final String targetPath = '${file.parent.path}/${_uuid.v4()}_compressed.jpg';
    
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: minWidth,
      quality: quality,
    );

    if (result != null) {
      return File(result.path);
    }
    return null;
  }

  // 3. Upload Image
  Future<String?> uploadImage(File file, String folderName) async {
    try {
      final String fileName = '${_uuid.v4()}${p.extension(file.path)}';
      final Reference ref = _storage.ref().child('$folderName/$fileName');
      
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Helper: Pick, Compress, and Upload in one go
  Future<String?> pickCompressAndUpload({
    required ImageSource source,
    required String folder, // e.g., 'properties', 'tenants', 'units'
  }) async {
    // 1. Pick
    final File? originalFile = await pickImage(source);
    if (originalFile == null) return null;

    // 2. Compress
    final File? compressedFile = await compressImage(originalFile);
    if (compressedFile == null) return null;

    // 3. Upload
    final String? url = await uploadImage(compressedFile, folder);
    
    // Cleanup compressed file if needed (usually cached in tmp)
    try {
      if (await compressedFile.exists()) {
        await compressedFile.delete();
      }
    } catch (_) {}

    return url;
  }
}
