import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riderescue_services/constants/api_endpoints.dart';
import '../providers/app_provider.dart';
import '../constants/network_constant.dart' show baseUrl;
import 'error_handler.dart';

// Upload state management
class UploadState {
  final bool isUploading;
  final double progress;
  final String? uploadedUrl;
  final String? uploadId;
  final String? error;
  final Map<String, dynamic>? uploadData;

  const UploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.uploadedUrl,
    this.uploadId,
    this.error,
    this.uploadData,
  });

  UploadState copyWith({
    bool? isUploading,
    double? progress,
    String? uploadedUrl,
    String? uploadId,
    String? error,
    Map<String, dynamic>? uploadData,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      uploadId: uploadId ?? this.uploadId,
      error: error,
      uploadData: uploadData ?? this.uploadData,
    );
  }
}

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier() : super(const UploadState());

  void startUpload() {
    state = state.copyWith(isUploading: true, progress: 0.0, error: null);
  }

  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  void completeUpload({
    required String url,
    required String uploadId,
    Map<String, dynamic>? uploadData,
  }) {
    state = state.copyWith(
      isUploading: false,
      progress: 1.0,
      uploadedUrl: url,
      uploadId: uploadId,
      uploadData: uploadData,
      error: null,
    );
  }

  void setError(String error) {
    state = state.copyWith(isUploading: false, error: error);
  }

  void clearState() {
    state = const UploadState();
  }
}

class UploadService {
  final String? authToken;
  final bool isConnected;

  UploadService({this.authToken, required this.isConnected});

  Map<String, String> get _headers {
    final headers = <String, String>{};

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  /// Simulate upload progress based on file size
  Future<void> _simulateProgress(File file, Function(double) onProgress) async {
    final fileSize = await file.length();
    final totalSteps = (fileSize / 1024).ceil(); // 1KB chunks
    final stepDelay = (5000 / totalSteps)
        .clamp(50, 500)
        .toInt(); // 5 seconds total, min 50ms, max 500ms

    for (int i = 0; i <= totalSteps; i++) {
      final progress = i / totalSteps;
      onProgress(progress);
      await Future.delayed(Duration(milliseconds: stepDelay));
    }
  }

  /// Upload a file to Cloudinary and save to database (Basic)
  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required Function(double) onProgress,
  }) async {
    return await catchError<Map<String, dynamic>>(
      operation: () async {
    if (!await file.exists()) {
      throw Exception('File does not exist');
    }

    final fileSize = await file.length();
    if (fileSize == 0) {
      throw Exception('File is empty');
    }

    if (!isConnected) {
      throw Exception('No internet connection');
    }

        // Simulate upload progress based on file size
        await _simulateProgress(file, onProgress);

      // Create multipart request to Cloudinary endpoint
      final url = '$baseUrl${ApiEndpoints.cloudinaryUpload}';
      final request = http.MultipartRequest('POST', Uri.parse(url));

        // Add headers
      request.headers.addAll(_headers);
      request.headers['Content-Type'] = 'multipart/form-data';

        // Add file with proper filename and MIME type
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final filename = file.path.split('/').last;
      final extension = filename.split('.').last.toLowerCase();

      String mimeType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'application/octet-stream';
      }

      final multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);

        // Send request
        final response = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Upload timeout'),
        );

      // Parse response
        final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        final errorMessage = responseData['message'] ?? 'Upload failed';
        String specificError;

        switch (response.statusCode) {
          case 400:
            specificError = 'Bad request - check file format and size';
            break;
          case 401:
            specificError = 'Unauthorized - check authentication token';
            break;
          case 403:
            specificError = 'Forbidden - insufficient permissions';
            break;
          case 413:
            specificError = 'File too large';
            break;
          case 500:
            specificError = 'Server error - please try again later';
            break;
          default:
            specificError = errorMessage;
        }

        throw Exception(specificError);
      }
      },
      onError: (error) {
        throw Exception('Upload failed: $error');
      },
    );
  }

  /// Upload image from gallery or camera (Basic)
  Future<Map<String, dynamic>> uploadImage({
    required ImageSource source,
    required Function(double) onProgress,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    return await catchError<Map<String, dynamic>>(
      operation: () async {
    if (!isConnected) {
      throw Exception('No internet connection');
    }

      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 80,
      );

      if (pickedFile == null) {
        throw Exception('No image selected');
      }

      final file = File(pickedFile.path);
      return await uploadFile(file: file, onProgress: onProgress);
      },
      onError: (error) {
        throw Exception('Image upload failed: $error');
      },
    );
  }

  /// Delete uploaded file
  Future<bool> deleteFile({required String uploadId}) async {
    return await catchErrorBool<Map<String, dynamic>>(
      operation: () async {
    if (!isConnected) {
      throw Exception('No internet connection');
    }

      final url = '$baseUrl/uploads/$uploadId';
      final response = await http.delete(Uri.parse(url), headers: _headers);

        final responseData = json.decode(response.body) as Map<String, dynamic>;
      final success =
          response.statusCode == 200 &&
            (responseData['success'] == true ||
                responseData['deleted'] == true);

        if (!success) {
          throw Exception('Delete operation failed');
        }

        return responseData;
      },
      onError: (error) {
        throw Exception('Delete failed: $error');
      },
    );
  }

  /// Force clear local file state (for when backend deletion fails but user wants to upload new file)
  void forceClearLocalState() {
    // This method is used by the UI to clear local state
    // when backend deletion fails but we want to allow new uploads
  }

  /// Get file information
  Future<Map<String, dynamic>> getFileInfo({required String uploadId}) async {
    return await catchError<Map<String, dynamic>>(
      operation: () async {
    if (!isConnected) {
      throw Exception('No internet connection');
    }

      final url = '$baseUrl/uploads/$uploadId';
      final response = await http.get(Uri.parse(url), headers: _headers);

        final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return responseData;
      } else {
        final errorMessage =
            responseData['message'] ?? 'Failed to get file info';
        throw Exception(errorMessage);
      }
      },
      onError: (error) {
        throw Exception('Get file info failed: $error');
      },
    );
  }
}

// Providers
final uploadNotifierProvider =
    StateNotifierProvider<UploadNotifier, UploadState>((ref) {
      return UploadNotifier();
    });

final uploadServiceProvider = Provider<UploadService>((ref) {
  final appState = ref.watch(appNotifierProvider);
  return UploadService(
    authToken: appState.authToken,
    isConnected: appState.isInternetConnected,
  );
});

// Convenience providers for upload state
final isUploadingProvider = Provider<bool>((ref) {
  return ref.watch(uploadNotifierProvider).isUploading;
});

final uploadProgressProvider = Provider<double>((ref) {
  return ref.watch(uploadNotifierProvider).progress;
});

final uploadedUrlProvider = Provider<String?>((ref) {
  return ref.watch(uploadNotifierProvider).uploadedUrl;
});

final uploadErrorProvider = Provider<String?>((ref) {
  return ref.watch(uploadNotifierProvider).error;
});
