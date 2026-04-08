import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:riderescue_services/constants/api_endpoints.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });
  }

  bool _validateForm() {
    _clearErrors();
    bool isValid = true;

    // Validate current password
    if (_currentPasswordController.text.trim().isEmpty) {
      setState(() => _currentPasswordError = 'Current password is required');
      isValid = false;
    }

    // Validate new password
    final newPassword = _newPasswordController.text.trim();
    if (newPassword.isEmpty) {
      setState(() => _newPasswordError = 'New password is required');
      isValid = false;
    } else if (newPassword.length < 8) {
      setState(
        () => _newPasswordError = 'Password must be at least 8 characters',
      );
      isValid = false;
    } else if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
    ).hasMatch(newPassword)) {
      setState(
        () => _newPasswordError =
            'Password must contain uppercase, lowercase, and number',
      );
      isValid = false;
    }

    // Validate confirm password
    final confirmPassword = _confirmPasswordController.text.trim();
    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your password');
      isValid = false;
    } else if (newPassword != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      isValid = false;
    }

    // Check if new password is same as current
    if (newPassword == _currentPasswordController.text.trim()) {
      setState(
        () => _newPasswordError =
            'New password must be different from current password',
      );
      isValid = false;
    }

    return isValid;
  }

  Future<void> _changePassword() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    final network = ref.read(networkProvider);

    final body = {
      'currentPassword': _currentPasswordController.text.trim(),
      'newPassword': _newPasswordController.text.trim(),
    };

    final response = await network.submit(
      method: HttpMethod.put,
      path: ApiEndpoints.changePassword,
      body: body,
    );

    setState(() => _isLoading = false);

    if (response.success) {
      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Success!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Password changed successfully!',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const SpinKitThreeBounce(color: Colors.green, size: 20),
                const SizedBox(height: 8),
                const Text(
                  'Returning to profile...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );

        // Auto navigate after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(); // Close dialog
            context.pop();
          }
        });
      }
    } else {
      // Handle specific error cases
      String errorMessage = response.message ?? 'Failed to change password';

      if (response.message?.toLowerCase().contains('current password') ==
          true) {
        setState(() => _currentPasswordError = 'Current password is incorrect');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SpinKitThreeBounce(color: Colors.grey, size: 20),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Security Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: colors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Enter your current password and choose a new one',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Current Password
              TextFormField(
                controller: _currentPasswordController,
                enabled: !_isLoading,
                obscureText: !_showCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter your current password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _currentPasswordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showCurrentPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () {
                      setState(
                        () => _showCurrentPassword = !_showCurrentPassword,
                      );
                    },
                  ),
                ),
                onChanged: (_) => _clearErrors(),
              ),

              const SizedBox(height: 16),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                enabled: !_isLoading,
                obscureText: !_showNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter your new password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _newPasswordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () {
                      setState(() => _showNewPassword = !_showNewPassword);
                    },
                  ),
                ),
                onChanged: (_) => _clearErrors(),
              ),

              const SizedBox(height: 8),

              // Password requirements
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outline.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Requirements:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildRequirement(
                      'At least 8 characters',
                      _newPasswordController.text.length >= 8,
                    ),
                    _buildRequirement(
                      'One uppercase letter',
                      RegExp(r'[A-Z]').hasMatch(_newPasswordController.text),
                    ),
                    _buildRequirement(
                      'One lowercase letter',
                      RegExp(r'[a-z]').hasMatch(_newPasswordController.text),
                    ),
                    _buildRequirement(
                      'One number',
                      RegExp(r'\d').hasMatch(_newPasswordController.text),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                enabled: !_isLoading,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  hintText: 'Confirm your new password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _confirmPasswordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () {
                      setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      );
                    },
                  ),
                ),
                onChanged: (_) => _clearErrors(),
              ),

              const SizedBox(height: 32),

              // Change Password Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                      : const Text(
                          'CHANGE PASSWORD',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.onSurface,
                    side: BorderSide(color: colors.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : colors.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : colors.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
