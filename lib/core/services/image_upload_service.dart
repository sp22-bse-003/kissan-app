import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Service to handle image uploads to Firebase Storage
class ImageUploadService {
  final FirebaseStorage _storage;

  ImageUploadService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  /// Upload an image file to Firebase Storage
  ///
  /// [file] - The image file to upload
  /// [path] - The storage path (e.g., 'products/product_123.jpg')
  /// [onProgress] - Optional callback for upload progress (0.0 to 1.0)
  ///
  /// Returns the download URL of the uploaded image
  Future<String> uploadImage(
    File file,
    String path, {
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((taskSnapshot) {
          final progress =
              taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      rethrow;
    }
  }

  /// Upload an image for a product
  ///
  /// [file] - The image file to upload
  /// [productId] - The product ID (used in the storage path)
  /// [onProgress] - Optional callback for upload progress
  ///
  /// Returns the download URL
  Future<String> uploadProductImage(
    File file,
    String productId, {
    Function(double)? onProgress,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    final path = 'products/${productId}_$timestamp.$extension';
    return uploadImage(file, path, onProgress: onProgress);
  }

  /// Upload a profile picture
  ///
  /// [file] - The image file to upload
  /// [userId] - The user ID (used in the storage path)
  /// [onProgress] - Optional callback for upload progress
  ///
  /// Returns the download URL
  Future<String> uploadProfileImage(
    File file,
    String userId, {
    Function(double)? onProgress,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    final path = 'profiles/${userId}_$timestamp.$extension';
    return uploadImage(file, path, onProgress: onProgress);
  }

  /// Delete an image from Firebase Storage
  ///
  /// [url] - The download URL of the image to delete
  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      rethrow;
    }
  }

  /// Delete a product image by URL
  Future<void> deleteProductImage(String url) async {
    return deleteImage(url);
  }

  /// Delete a profile image by URL
  Future<void> deleteProfileImage(String url) async {
    return deleteImage(url);
  }
}
