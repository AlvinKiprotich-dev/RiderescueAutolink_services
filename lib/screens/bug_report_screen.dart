import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/plugins/theme/colors.dart';

class BugReportScreen extends ConsumerStatefulWidget {
  const BugReportScreen({super.key});

  @override
  ConsumerState<BugReportScreen> createState() => _BugReportScreenState();
}

class _BugReportScreenState extends ConsumerState<BugReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();

  String _selectedCategory = 'ui_ux';
  String _selectedSeverity = 'medium';
  List<String> _stepsToReproduce = [];
  List<String> _attachments = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final List<Map<String, String>> _categories = [
    {'value': 'ui_ux', 'label': 'UI/UX Issue'},
    {'value': 'functionality', 'label': 'Functionality Problem'},
    {'value': 'performance', 'label': 'Performance Issue'},
    {'value': 'crash', 'label': 'App Crash'},
    {'value': 'feature_request', 'label': 'Feature Request'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, String>> _severities = [
    {'value': 'low', 'label': 'Low'},
    {'value': 'medium', 'label': 'Medium'},
    {'value': 'high', 'label': 'High'},
    {'value': 'critical', 'label': 'Critical'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  void _addStep() {
    if (_stepsController.text.trim().isNotEmpty) {
      setState(() {
        _stepsToReproduce.add(_stepsController.text.trim());
        _stepsController.clear();
      });
    }
  }

  void _removeStep(int index) {
    setState(() {
      _stepsToReproduce.removeAt(index);
    });
  }

  void _clearMessages() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _submitBugReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final user = ref.read(userProvider);
      if (user == null) throw Exception('User not found');

      final bugReportData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'severity': _selectedSeverity,
        'deviceInfo': {
          'platform': 'mobile',
          'version': '1.0.0', // You can get this from device info
          'model': 'Mobile Device',
          'os': 'Mobile OS',
        },
        'appVersion': '1.0.0',
        'stepsToReproduce': _stepsToReproduce,
        'attachments': _attachments,
      };

      final response = await ref
          .read(networkProvider)
          .submit(method: HttpMethod.post, path: '/bugs', body: bugReportData);

      if (response.success) {
        setState(() {
          _successMessage = 'Bug report submitted successfully!';
        });

        // Clear form after successful submission
        _titleController.clear();
        _descriptionController.clear();
        _stepsToReproduce.clear();
        _attachments.clear();
        _selectedCategory = 'ui_ux';
        _selectedSeverity = 'medium';

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pop();
          }
        });
      } else {
        throw Exception(response.message ?? 'Failed to submit bug report');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit bug report: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Report a Bug'),
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Error/Success Messages
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red, size: 16),
                      onPressed: _clearMessages,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            if (_successMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.green, size: 16),
                      onPressed: _clearMessages,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Bug Title',
                        hintText: 'Brief description of the issue',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.bug_report,
                          color: colors.primary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.trim().length < 5) {
                          return 'Title must be at least 5 characters';
                        }
                        return null;
                      },
                      onChanged: (_) => _clearMessages(),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Detailed description of the bug...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.description,
                          color: colors.primary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                      onChanged: (_) => _clearMessages(),
                    ),
                    const SizedBox(height: 16),

                    // Category
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.category, color: colors.primary),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category['value'],
                          child: Text(category['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Severity
                    DropdownButtonFormField<String>(
                      value: _selectedSeverity,
                      decoration: InputDecoration(
                        labelText: 'Severity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.priority_high,
                          color: colors.primary,
                        ),
                      ),
                      items: _severities.map((severity) {
                        return DropdownMenuItem(
                          value: severity['value'],
                          child: Text(severity['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSeverity = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Steps to Reproduce
                    Text(
                      'Steps to Reproduce',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stepsController,
                            decoration: InputDecoration(
                              hintText: 'Add a step to reproduce...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.list,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Steps List
                    if (_stepsToReproduce.isNotEmpty) ...[
                      ..._stepsToReproduce.asMap().entries.map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(step)),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => _removeStep(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 24),

                    // Attachments
                    Text(
                      'Attachments (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 48,
                            color: colors.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image upload feature coming soon',
                            style: TextStyle(
                              color: colors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _attachments.map((url) {
                          return Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(url),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _attachments.remove(url);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBugReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Submit Bug Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
