import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/constants/route_names.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:riderescue_services/plugins/theme/constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _formError;
  String? _formSuccess;

  // Flutter App
  String clientId =
      '571839014028-l8uj6mnuoqsjl9v1dkrf9hn3oi4stu0c.apps.googleusercontent.com';
  String serverClientId =
      '571839014028-15rjhmktqljreeuimgskuhm6hg1crj58.apps.googleusercontent.com';

  void _showGoogleLoaderDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: SpinKitThreeBounce(
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
        ),
      ),
    );
  }

  void _clearFormMessages() {
    setState(() {
      _formError = null;
      _formSuccess = null;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _clearFormMessages();
    setState(() => _isLoading = true);
    final network = ref.read(networkProvider);
    final app = ref.read(appNotifierProvider.notifier);

    final response = await network.submit(
      method: HttpMethod.post,
      path: '/auth/login',
      body: {
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
          _formSuccess = 'Login successful! Redirecting....';
        });

        await app.login(token: token, user: User.fromJson(userMap));

        if (mounted) {
          // Show success message briefly before redirecting
          //await Future.delayed(const Duration(seconds: 1));
          context.go(Routes.home);
        }
      } else {
        setState(() {
          _formError = response.message ?? 'Invalid response from server';
        });
      }
    } else {
      setState(() {
        _formError =
            response.message ??
            'Login failed. Please check your credentials and try again.';
      });
    }
  }

  Future<void> _continueWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    unawaited(
      googleSignIn
          .initialize(
            clientId:
                '571839014028-l8uj6mnuoqsjl9v1dkrf9hn3oi4stu0c.apps.googleusercontent.com',
            serverClientId:
                '571839014028-15rjhmktqljreeuimgskuhm6hg1crj58.apps.googleusercontent.com',
          )
          .then((_) {
            googleSignIn.authenticationEvents
                .listen(_handleAuthenticationEvent)
                .onError(_handleAuthenticationError);

            /// This example always uses the stream-based approach to determining
            /// which UI state to show, rather than using the future returned here,
            /// if any, to conditionally skip directly to the signed-in state.
            googleSignIn
                .authenticate()
                .then((account) async {
                  // Get authentication details from the account
                  final authentication = account.authentication;
                  final idToken = authentication.idToken;

                  if (idToken != null) {
                    _showGoogleLoaderDialog(context);
                    try {
                      final network = ref.read(networkProvider);
                      final app = ref.read(appNotifierProvider.notifier);

                      final response = await network.submit(
                        method: HttpMethod.post,
                        path: '/auth/google',
                        body: {'idToken': idToken},
                      );

                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pop(); // Close loader dialog

                      if (response.success && response.data != null) {
                        final token = response.data?['token'] as String?;
                        final userMap =
                            response.data?['user'] as Map<String, dynamic>?;
                        if (token != null && userMap != null) {
                          setState(() {
                            _formSuccess =
                                'Google sign-in successful! Redirecting...';
                          });

                          await app.login(
                            token: token,
                            user: User.fromJson(userMap),
                          );

                          if (mounted) {
                            // Show success message briefly before redirecting
                            await Future.delayed(const Duration(seconds: 1));
                            context.go(Routes.home);
                          }
                        } else {
                          setState(() {
                            _formError = 'Sign-in failed. Please try again.';
                          });
                        }
                      } else {
                        setState(() {
                          _formError = 'Sign-in failed. Please try again.';
                        });
                      }
                    } catch (e) {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pop(); // Close loader dialog
                      setState(() {
                        _formError = 'Sign-in failed. Please try again.';
                      });
                    }
                  } else {
                    setState(() {
                      _formError = 'Sign-in failed. Please try again.';
                    });
                  }
                })
                .catchError((error) {
                  // Handle Google sign-in cancellation and other errors
                  if (error.toString().contains('SIGN_IN_CANCELLED') ||
                      error.toString().contains('SIGN_IN_REQUIRED') ||
                      error.toString().contains('DEVELOPER_ERROR')) {
                    // Don't show error for user cancellation
                    return;
                  }

                  // For other errors, show a generic message
                  if (mounted) {
                    setState(() {
                      _formError = 'Sign-in failed. Please try again.';
                    });
                  }
                });
          }),
    );
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    // _showGoogleLoaderDialog(context);
  }

  void _handleAuthenticationError(Object error) {
    // Handle authentication errors here - show generic message only
    if (mounted) {
      setState(() {
        _formError = 'Sign-in failed. Please try again.';
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
                  'Welcome Back',
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
                    'Login to account to feel the whole experience of getting linked to the right people',
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
                                autofillHints: const [AutofillHints.password],
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
                                    Icons.lock_outlined,
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
                              // Remember me and Forgot Password
                              Row(
                                children: [
                                  Switch(
                                    value: _rememberMe,
                                    onChanged: _isLoading
                                        ? null
                                        : (v) =>
                                              setState(() => _rememberMe = v),
                                    activeColor: primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () => context.push(
                                            Routes.forgotPassword,
                                          ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: primary,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Forgot Password?'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Sign in button
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
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
                                    'SIGN IN',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Or sign in with
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: Colors.grey[300]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      'Or sign in with',
                                      style: TextStyle(
                                        color: onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: Colors.grey[300]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Sign in with Google button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _continueWithGoogle,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        appBorderRadius,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/google.png',
                                        height: 32,
                                        width: 32,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 100),
                              // Bottom text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Not a member? ',
                                    style: TextStyle(color: onSurface),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push(Routes.signup),
                                    child: Text(
                                      'SIGN UP',
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
                                  'By signing in, you confirm that you agree to our Terms and Conditions, and have read and understood our Privacy Policy',
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
