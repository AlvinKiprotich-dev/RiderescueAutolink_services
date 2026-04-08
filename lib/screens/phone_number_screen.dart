import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/plugins/theme/colors.dart';

class PhoneNumberScreen extends ConsumerStatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  ConsumerState<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isVerifying = false;
  bool _showOtpField = false;
  String? _errorMessage;
  String? _successMessage;
  String? _currentPhone;
  bool _isPhoneVerified = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPhone();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _loadCurrentPhone() {
    final user = ref.read(userProvider);
    if (user != null) {
      setState(() {
        _currentPhone = user.phone.isNotEmpty ? user.phone : null;
        _isPhoneVerified = user.phoneVerified ?? false;
      });
    }
  }

  void _clearMessages() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _updatePhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await ref
          .read(networkProvider)
          .submit(
            method: HttpMethod.put,
            path: '/users/profile',
            body: {'phone': _phoneController.text.trim()},
          );

      if (response.success) {
        setState(() {
          _successMessage = 'Phone number updated successfully!';
          _showOtpField = true;
        });

        // Refresh user data
        // await ref.read(appNotifierProvider.notifier).refreshUser();
        _loadCurrentPhone();
      } else {
        throw Exception(response.message ?? 'Failed to update phone number');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update phone number: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyPhoneNumber() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the verification code';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await ref
          .read(networkProvider)
          .submit(
            method: HttpMethod.post,
            path: '/auth/verify-phone',
            body: {
              'phone': _phoneController.text.trim(),
              'otp': _otpController.text.trim(),
            },
          );

      if (response.success) {
        setState(() {
          _successMessage = 'Phone number verified successfully!';
          _isPhoneVerified = true;
        });

        // Refresh user data
        // await ref.read(appNotifierProvider.notifier).refreshUser();
        _loadCurrentPhone();

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pop();
          }
        });
      } else {
        throw Exception(response.message ?? 'Failed to verify phone number');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify phone number: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ref
          .read(networkProvider)
          .submit(
            method: HttpMethod.post,
            path: '/auth/resend-otp',
            body: {'phone': _phoneController.text.trim()},
          );

      if (response.success) {
        setState(() {
          _successMessage = 'Verification code sent successfully!';
        });
      } else {
        throw Exception(response.message ?? 'Failed to send verification code');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send verification code: $e';
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
        title: const Text('Phone Number'),
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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

            // Current Phone Number Status
            if (_currentPhone != null) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone, color: colors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Current Phone Number',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentPhone!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _isPhoneVerified ? Icons.verified : Icons.warning,
                          color: _isPhoneVerified
                              ? Colors.green
                              : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isPhoneVerified ? 'Verified' : 'Not verified',
                          style: TextStyle(
                            color: _isPhoneVerified
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentPhone != null
                          ? 'Change Phone Number'
                          : 'Add Phone Number',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number Input
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.phone, color: colors.primary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a phone number';
                        }
                        // Basic phone number validation
                        if (value.trim().length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                      onChanged: (_) => _clearMessages(),
                    ),
                    const SizedBox(height: 16),

                    // Update Phone Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updatePhoneNumber,
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
                            : Text(
                                _currentPhone != null
                                    ? 'Update Phone Number'
                                    : 'Add Phone Number',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    // OTP Section
                    if (_showOtpField) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Verify Phone Number',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ve sent a verification code to your phone number. Please enter it below.',
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // OTP Input
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'Verification Code',
                          hintText: 'Enter 6-digit code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.security,
                            color: colors.primary,
                          ),
                          counterText: '',
                        ),
                        onChanged: (_) => _clearMessages(),
                      ),
                      const SizedBox(height: 16),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isVerifying ? null : _verifyPhoneNumber,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isVerifying
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
                                  'Verify Phone Number',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Resend OTP Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _resendOtp,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: colors.primary),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Resend Code',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
