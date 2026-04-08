import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../plugins/utils/upload_service.dart';

class FileUploadWidget extends ConsumerStatefulWidget {
  final String? initialUrl;
  final String? initialUploadId;
  final Function(String url, String uploadId)? onFileUploaded;
  final Function()? onFileDeleted;
  final double? maxWidth;
  final double? maxHeight;
  final int? imageQuality;
  final bool showPreview;
  final IconData? customIcon;

  // Custom UI props
  final Widget? uploadPrompt;
  final Widget? uploadArea;
  final double? height;
  final double? width;

  const FileUploadWidget({
    super.key,
    this.initialUrl,
    this.initialUploadId,
    this.onFileUploaded,
    this.onFileDeleted,
    this.maxWidth,
    this.maxHeight,
    this.imageQuality,
    this.showPreview = true,
    this.customIcon,
    this.uploadPrompt,
    this.uploadArea,
    this.height,
    this.width,
  });

  @override
  ConsumerState<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends ConsumerState<FileUploadWidget> {
  String? _currentUrl;
  String? _currentUploadId;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _currentUploadId = widget.initialUploadId;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.uploadArea != null) {
      return GestureDetector(
        onTap: _showImageSourceDialog,
        child: widget.uploadArea!,
      );
    }

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: _buildUploadArea(),
    );
  }

  // Public method to trigger upload dialog
  void triggerUpload() {
    _showImageSourceDialog();
  }

  Widget _buildUploadArea() {
    return Stack(
      children: [
        if (_currentUrl != null && widget.showPreview) _buildFilePreview(),
        if (_isUploading) _buildUploadProgress(),
        if (_currentUrl != null && !_isUploading) _buildDeleteButton(),
        // Upload prompt - use custom or default
        if (_currentUrl == null)
          Positioned.fill(
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: widget.uploadPrompt ?? _buildDefaultUploadPrompt(),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultUploadPrompt() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 13,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Click to upload',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' or drag and drop'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'SVG, PNG, JPG or GIF (max. 800x400px)',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(_currentUrl!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: _uploadProgress,
              strokeWidth: 4,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Uploading... ${(_uploadProgress * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Please wait while we upload your file',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: _showDeleteConfirmation,
          icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Choose Image Source',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select from your photo library'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Take Photo'),
                subtitle: const Text('Use camera to take a new photo'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadImage(ImageSource source) async {
    if (!mounted) return;

    // Check if there's already a file and ask for confirmation
    if (_currentUploadId != null) {
      final shouldReplace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Replace File'),
          content: const Text('Do you want to replace the current file?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );

      if (shouldReplace != true) return;

      // Delete current file first (will handle backend failures gracefully)
      await _deleteFile();
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final uploadService = ref.read(uploadServiceProvider);

      final result = await uploadService.uploadImage(
        source: source,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
            });
          }
        },
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality: widget.imageQuality,
      );

      if (mounted) {
        setState(() {
          _currentUrl = result['url'] as String?;
          _currentUploadId = result['uploadId'] as String?;
          _isUploading = false;
          _uploadProgress = 1.0;
        });

        widget.onFileUploaded?.call(_currentUrl!, _currentUploadId!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete File'),
        content: const Text(
          'Are you sure you want to delete this file? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFile();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile() async {
    if (_currentUploadId == null) return;

    setState(() {});

    try {
      final uploadService = ref.read(uploadServiceProvider);
      final success = await uploadService.deleteFile(
        uploadId: _currentUploadId!,
      );

      // Always clear the local state regardless of backend success
      if (mounted) {
        setState(() {
          _currentUrl = null;
          _currentUploadId = null;
          _isUploading = false;
          _uploadProgress = 0.0;
        });

        widget.onFileDeleted?.call();

        // Show warning if backend deletion failed but allow user to continue
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'File removed locally. Backend cleanup may be delayed.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Even if deletion fails, clear local state and allow new uploads
      if (mounted) {
        setState(() {
          _currentUrl = null;
          _currentUploadId = null;
          _isUploading = false;
          _uploadProgress = 0.0;
        });

        widget.onFileDeleted?.call();

        // Show warning but don't block the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File removed locally. You can upload a new file. Error: ${e.toString()}',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
