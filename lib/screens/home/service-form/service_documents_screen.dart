import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/widgets/file_upload_widget.dart';
import 'package:riderescue_services/constants/api_endpoints.dart';
import 'package:riderescue_services/models/document.dart';
import 'package:riderescue_services/models/service.dart';

class ServiceDocumentsScreen extends ConsumerStatefulWidget {
  final String serviceId; // ID of the registered service

  const ServiceDocumentsScreen({super.key, required this.serviceId});

  @override
  ConsumerState<ServiceDocumentsScreen> createState() =>
      _ServiceDocumentsScreenState();
}

class _ServiceDocumentsScreenState
    extends ConsumerState<ServiceDocumentsScreen> {
  final Map<String, String?> _documentUrls = {};
  final Map<String, String?> _documentUploadIds = {};
  final Map<String, String?> _documentServerIds =
      {}; // Store server document IDs
  final Map<String, bool> _documentSavedToServer = {};
  final Map<String, bool> _documentSavingToServer = {};
  bool _isLoading = true;
  bool _isMarkingAsPending = false;
  List<RequiredDocument> _requiredDocuments = [];
  List<Document> _existingDocuments = [];

  @override
  void initState() {
    super.initState();
    _loadServiceData();
  }

  Future<void> _loadServiceData() async {
    try {
      final network = ref.read(networkProvider);

      // Get service details to determine type with refresh=true
      final serviceResponse = await network.get(
        ApiEndpoints.serviceById.replaceAll('{id}', widget.serviceId),
        refresh: true,
      );

      if (serviceResponse.success && serviceResponse.data != null) {
        await _loadDocuments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading service data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDocuments() async {
    try {
      final network = ref.read(networkProvider);

      // Get documents and required documents for this service with refresh=true
      final documentsResponse = await network.get(
        ApiEndpoints.serviceDocuments.replaceAll(
          '{serviceId}',
          widget.serviceId,
        ),
        refresh: true,
      );

      if (documentsResponse.success && documentsResponse.data != null) {
        try {
          final documentData = DocumentResponse.fromJson(
            documentsResponse.data!,
          );

          setState(() {
            _requiredDocuments = documentData.requiredDocuments;
            _existingDocuments = documentData.documents;
          });

          // Pre-fill existing documents
          for (final doc in _existingDocuments) {
            _documentUrls[doc.type] = doc.url;
            _documentUploadIds[doc.type] = doc.id;
            _documentServerIds[doc.type] =
                doc.id; // Store server ID for updates
            _documentSavedToServer[doc.type] = true; // Already saved to server
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error parsing document data: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to load documents: ${documentsResponse.message}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading documents: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _autoSubmitDocument(
    RequiredDocument document,
    String url,
    String uploadId,
  ) async {
    setState(() {
      _documentSavingToServer[document.documentType] = true;
    });

    try {
      final network = ref.read(networkProvider);
      final authToken = ref.read(authTokenProvider);

      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      // Check if document already exists on server
      final existingServerId = _documentServerIds[document.documentType];

      if (existingServerId != null) {
        // Update existing document
        final documentData = {'name': document.name, 'url': url};

        final response = await network.submit(
          method: HttpMethod.put,
          path: '/services/documents/$existingServerId',
          body: documentData,
        );

        if (response.success && response.data != null) {
          setState(() {
            _documentSavedToServer[document.documentType] = true;
            _documentSavingToServer[document.documentType] = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${document.name} updated successfully!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          throw Exception(
            'Failed to update ${document.name}: ${response.message}',
          );
        }
      } else {
        // Create new document
        final documentData = {
          'type': document.documentType,
          'name': document.name,
          'url': url,
          'service': widget.serviceId,
          'document': document.id, // Required document ID
        };

        final response = await network.submit(
          method: HttpMethod.post,
          path: '/services/documents',
          body: documentData,
        );

        if (response.success && response.data != null) {
          // Store the server document ID for future updates
          final savedDocument = response.data!['document'];
          _documentServerIds[document.documentType] = savedDocument['_id'];

          setState(() {
            _documentSavedToServer[document.documentType] = true;
            _documentSavingToServer[document.documentType] = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${document.name} saved successfully!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          throw Exception(
            'Failed to save ${document.name}: ${response.message}',
          );
        }
      }

      // Refresh the documents list to get updated data
      await _refreshDocuments();
    } catch (e) {
      setState(() {
        _documentSavingToServer[document.documentType] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save ${document.name}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _refreshDocuments() async {
    await _loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: const Text(
          'Verify',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              'Step 3 of 3',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  ..._requiredDocuments.map(
                    (doc) => _buildDocumentSection(doc),
                  ),
                  const SizedBox(height: 32),
                  _buildTermsAndConditions(),
                  const SizedBox(height: 24),
                  _buildDoneButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Submit your certification details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload the necessary documents to complete your certification process.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentSection(RequiredDocument document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'Upload ${document.name}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (document.required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: FileUploadWidget(
            initialUrl: _documentUrls[document.documentType],
            initialUploadId: _documentUploadIds[document.documentType],
            onFileUploaded: (url, uploadId) async {
              setState(() {
                _documentUrls[document.documentType] = url;
                _documentUploadIds[document.documentType] = uploadId;
                _documentSavedToServer[document.documentType] = false;
              });
              await _autoSubmitDocument(document, url, uploadId);
            },
            onFileDeleted: () {
              setState(() {
                _documentUrls[document.documentType] = null;
                _documentUploadIds[document.documentType] = null;
                _documentSavedToServer[document.documentType] = false;
                _documentSavingToServer[document.documentType] = false;
              });
            },
            maxWidth: 800,
            maxHeight: 400,
            imageQuality: 80,
            uploadPrompt: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  style: BorderStyle.solid,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 20,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.6),
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
            ),
          ),
        ),
      ],
    );
  }

  bool _areAllDocumentsUploaded() {
    return _requiredDocuments.every(
      (doc) =>
          _documentUrls[doc.documentType] != null &&
          _documentSavedToServer[doc.documentType] == true,
    );
  }

  Widget _buildTermsAndConditions() {
    final allDocumentsUploaded = _areAllDocumentsUploaded();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'Terms & Conditions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: allDocumentsUploaded
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: allDocumentsUploaded,
              onChanged: allDocumentsUploaded ? (value) {} : null,
              activeColor: Theme.of(context).colorScheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: Text(
                'I agree to the terms and conditions of certification',
                style: TextStyle(
                  color: allDocumentsUploaded
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (!allDocumentsUploaded) ...[
          const SizedBox(height: 8),
          Text(
            'Please upload all required documents to proceed',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error.withOpacity(0.7),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDoneButton() {
    final allDocumentsUploaded = _areAllDocumentsUploaded();
    final isButtonEnabled = allDocumentsUploaded && !_isMarkingAsPending;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isButtonEnabled
            ? () async {
                await _markServiceAsPendingApproval();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isMarkingAsPending
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Marking as pending...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Text(
                allDocumentsUploaded
                    ? 'Done'
                    : 'Upload all documents to continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isButtonEnabled
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(
                          context,
                        ).colorScheme.onPrimary.withOpacity(0.7),
                ),
              ),
      ),
    );
  }

  Future<void> _markServiceAsPendingApproval() async {
    setState(() {
      _isMarkingAsPending = true;
    });

    try {
      final network = ref.read(networkProvider);

      // Call the pending approval endpoint
      final response = await network.submit(
        method: HttpMethod.patch,
        path: ApiEndpoints.servicePendingApproval.replaceAll(
          '{id}',
          widget.serviceId,
        ),
        body: {}, // Empty body as per the endpoint specification
      );

      if (response.success) {
        // Update app provider with the updated service data
        if (response.data != null && response.data!['service'] != null) {
          final updatedServiceData = response.data!['service'];

          // Create Service object from the updated data
          final updatedService = Service.fromJson(updatedServiceData);

          // Update the service in app provider
          await _updateServiceInAppProvider(updatedService);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service marked as pending approval successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Close current page and navigate to home
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        throw Exception(
          'Failed to mark service as pending approval: ${response.message}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error marking service as pending approval: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAsPending = false;
        });
      }
    }
  }

  Future<void> _updateServiceInAppProvider(Service updatedService) async {
    try {
      final appNotifier = ref.read(appNotifierProvider.notifier);
      final currentServiceProfiles = ref.read(serviceProfilesProvider);
      final activeService = ref.read(activeServiceProvider);

      // Update the service in the service profiles list
      final updatedServiceProfiles = currentServiceProfiles.map((service) {
        if (service.id == updatedService.id) {
          return updatedService;
        }
        return service;
      }).toList();

      // Update service profiles in app provider
      await appNotifier.setServiceProfiles(updatedServiceProfiles);

      // If this is the active service, update it as well
      if (activeService != null && activeService.id == updatedService.id) {
        await appNotifier.setActiveService(updatedService);
      }

      // Refresh service profiles to ensure consistency
      await appNotifier.refreshServiceProfilesFresh();
    } catch (e) {
      // Log error but don't show to user as the main operation was successful
      print('Error updating service in app provider: $e');
    }
  }
}
