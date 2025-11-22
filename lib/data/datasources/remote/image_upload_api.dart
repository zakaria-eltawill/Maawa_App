import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maawa_project/core/network/dio_client.dart';

/// Response DTO for image upload
class ImageUploadResponse {
  final String url;
  final String? id;
  final String? filename;

  ImageUploadResponse({
    required this.url,
    this.id,
    this.filename,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    // Handle different response formats
    // Format 1: { "url": "https://..." }
    // Format 2: { "data": { "url": "https://..." } }
    // Format 3: { "url": "...", "id": "...", "filename": "..." }
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;
    
    return ImageUploadResponse(
      url: data['url'] as String,
      id: data['id'] as String?,
      filename: data['filename'] as String?,
    );
  }
}

class ImageUploadApi {
  final DioClient _dioClient;

  ImageUploadApi(this._dioClient);

  /// Upload a single image file
  /// 
  /// Returns the URL of the uploaded image
  /// 
  /// Expected backend endpoint: POST /upload or POST /files
  /// Expected response format: { "url": "https://..." } or { "data": { "url": "https://..." } }
  Future<String> uploadImage(File imageFile, {String? folder}) async {
    if (kDebugMode) {
      final baseUrl = _dioClient.dio.options.baseUrl;
      debugPrint('📤 ImageUploadApi.uploadImage: Calling $baseUrl/upload');
      debugPrint('📁 File: ${imageFile.path}');
      debugPrint('📏 Size: ${await imageFile.length()} bytes');
    }

    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        if (folder != null) 'folder': folder,
      });

      // Don't override headers - let Dio set Content-Type automatically for multipart
      // The AuthInterceptor will add the Authorization header and remove Content-Type for FormData
      final response = await _dioClient.dio.post(
        '/upload', // Backend endpoint - adjust if different
        data: formData,
        // Explicitly set options to ensure Content-Type is not overridden
        options: Options(
          // Don't set Content-Type - Dio will set it automatically with boundary for multipart
          // The AuthInterceptor will remove any default Content-Type header
          headers: {
            // Don't set Content-Type here - let Dio handle it
          },
        ),
      );

      if (kDebugMode) {
        debugPrint('✅ ImageUploadApi.uploadImage: Success - Status ${response.statusCode}');
        debugPrint('📦 Response: ${response.data}');
      }

      final uploadResponse = ImageUploadResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return uploadResponse.url;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ImageUploadApi.uploadImage: Error - $e');
        if (e is DioException) {
          debugPrint('❌ Status Code: ${e.response?.statusCode}');
          debugPrint('❌ Response Data: ${e.response?.data}');
          debugPrint('❌ Request URL: ${e.requestOptions.uri}');
        }
      }
      rethrow;
    }
  }

  /// Upload multiple images
  /// 
  /// Returns a list of URLs in the same order as the input files
  Future<List<String>> uploadImages(List<File> imageFiles, {String? folder}) async {
    if (kDebugMode) {
      debugPrint('📤 ImageUploadApi.uploadImages: Uploading ${imageFiles.length} images');
    }

    try {
      final urls = <String>[];
      
      // Upload images sequentially to avoid overwhelming the server
      for (int i = 0; i < imageFiles.length; i++) {
        if (kDebugMode) {
          debugPrint('📤 Uploading image ${i + 1}/${imageFiles.length}');
        }
        
        final url = await uploadImage(imageFiles[i], folder: folder);
        urls.add(url);
      }

      if (kDebugMode) {
        debugPrint('✅ ImageUploadApi.uploadImages: All ${urls.length} images uploaded successfully');
      }

      return urls;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ImageUploadApi.uploadImages: Error - $e');
      }
      rethrow;
    }
  }
}

