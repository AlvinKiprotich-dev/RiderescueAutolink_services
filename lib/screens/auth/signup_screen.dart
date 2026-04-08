import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:riderescue_services/constants/route_names.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/models/user.dart';
import 'package:riderescue_services/plugins/theme/constants.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String? _formError;
  String? _formSuccess;

  void _clearFormMessages() {
    setState(() {
      _formError = null;
      _formSuccess = null;
    });
  }

  Future<void> _signup() async {
    if (!_agreedToTerms) return;
    if (!_formKey.currentState!.validate()) return;

    _clearFormMessages();
    setState(() => _isLoading = true);
    final network = ref.read(networkProvider);
    final app = ref.read(appNotifierProvider.notifier);

    final response = await network.submit(
      method: HttpMethod.post,
      path: '/auth/signup',
      body: {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      },
    );

    setState(() => _isLoading = false);

    if (response.success && response.data != null) {
      final token = response.data?['token'] as String?;
      final userMap = response.data?['user'] as Map<String, dynamic>?;
      if (token != null && userMap != null) {
        setState(() {
          _formSuccess = 'Account created successfully! Redirecting...';
        });

        await app.login(token: token, user: User.fromJson(userMap));

        if (mounted) {
          // Show success message briefly before redirecting
          await Future.delayed(const Duration(seconds: 1));
          context.go(Routes.home);
        }
      } else {
        setState(() {
          _formError = response.message ?? 'Invalid response from server';
        });
      }
    } else {
      setState(() {
        _formError = response.message ?? 'Signup failed. Please try again.';
      });
    }
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
                // Title
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Create an account to get started',
                    style: TextStyle(color: onPrimary, fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
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

                              // Name field
                              TextFormField(
                                controller: _nameController,
                                enabled: !_isLoading,
                                autofillHints: const [AutofillHints.name],
                                onChanged: (_) => _clearFormMessages(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Full name is required';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  hintText: 'Enter your full name',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: onSurface.withOpacity(0.6),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Phone field
                              TextFormField(
                                controller: _phoneController,
                                enabled: !_isLoading,
                                keyboardType: TextInputType.phone,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber,
                                ],
                                onChanged: (_) => _clearFormMessages(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  if (!RegExp(
                                    r'^[0-9+\-() ]{7,}$',
                                  ).hasMatch(value)) {
                                    return 'Enter a valid phone number';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Phone',
                                  hintText: 'Enter your phone number',
                                  prefixIcon: Icon(
                                    Icons.phone_outlined,
                                    color: onSurface.withOpacity(0.6),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                enabled: !_isLoading,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                onChanged: (_) => _clearFormMessages(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Enter your email',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: onSurface.withOpacity(0.6),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                enabled: !_isLoading,
                                obscureText: true,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onChanged: (_) => _clearFormMessages(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: onSurface.withOpacity(0.6),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Confirm Password field
                              TextFormField(
                                controller: _confirmController,
                                enabled: !_isLoading,
                                obscureText: true,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onChanged: (_) => _clearFormMessages(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  hintText: 'Re-enter your password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: onSurface.withOpacity(0.6),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      appBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Terms and conditions checkbox
                              InkWell(
                                onTap: _isLoading
                                    ? null
                                    : () => setState(
                                        () => _agreedToTerms = !_agreedToTerms,
                                      ),
                                borderRadius: BorderRadius.circular(8),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _agreedToTerms,
                                      onChanged: _isLoading
                                          ? null
                                          : (v) => setState(
                                              () => _agreedToTerms = v ?? false,
                                            ),
                                      activeColor: primary,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'I agree to the Terms and Conditions',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: (!_agreedToTerms || _isLoading)
                                      ? null
                                      : _signup,
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
                                    'SIGN UP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 100),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(color: onSurface),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.pop(),
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
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  'By signing up, you confirm that you agree to our Terms and Conditions, and have read and understood our Privacy Policy',
                                  style: TextStyle(
                                    color: onSurface.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
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
