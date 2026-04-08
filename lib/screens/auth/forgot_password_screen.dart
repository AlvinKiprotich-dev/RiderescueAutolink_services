import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/constants/route_names.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:riderescue_services/plugins/theme/constants.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _formError;
  String? _formSuccess;

  void _clearFormMessages() {
    setState(() {
      _formError = null;
      _formSuccess = null;
    });
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    _clearFormMessages();
    setState(() => _isLoading = true);
    final network = ref.read(networkProvider);

    final response = await network.submit(
      method: HttpMethod.post,
      path: '/auth/forgot-password',
      body: {'email': _emailController.text.trim()},
    );

    setState(() => _isLoading = false);

    if (response.success) {
      if (mounted) {
        setState(() {
          _formSuccess =
              response.message ??
              'Password reset email sent successfully! Check your inbox.';
        });

        // Show success message briefly before redirecting
        await Future.delayed(const Duration(seconds: 2));
        context.go(Routes.login);
      }
    } else {
      setState(() {
        _formError =
            response.message ?? 'Failed to send reset email. Please try again.';
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.close, color: onPrimary),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary.withOpacity(0.8), primary],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Back button and title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 16),

                    Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: onPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 8),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Enter your email address and we\'ll send you a link to reset your password',
                    style: TextStyle(color: onPrimary, fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(appRadius),
                        topRight: Radius.circular(appRadius),
                      ),
                    ),
                    elevation: appElevation,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 48),

                              // Form error alert
                              if (_formError != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.error.withOpacity(0.1),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _formError!,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Form success alert
                              if (_formSuccess != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _formSuccess!,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Email field
                              TextFormField(
                                controller: _emailController,
                                enabled: !_isLoading,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (_) => _clearFormMessages(),
                                validator: _validateEmail,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Enter your email address',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: onSurface.withOpacity(0.6),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Reset password button
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _resetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        appBorderRadius,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'SEND RESET LINK',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Back to login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Remember your password? ',
                                    style: TextStyle(color: onSurface),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go(Routes.login),
                                    child: Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        color: primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Info card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: primary.withAlpha(10),
                                  border: Border.all(
                                    width: 1,
                                    color: primary.withAlpha(15),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    appBorderRadius,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'What happens next?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '• Check your email inbox (and spam folder)\n• Click the reset link in the email\n• Create a new password\n• Login with your new password',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: onSurface.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: SpinKitThreeBounce(color: primary, size: 30),
              ),
            ),
        ],
      ),
    );
  }
}
