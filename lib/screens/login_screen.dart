import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:student_task_manager/screens/forgot_password_screen.dart';
import 'package:student_task_manager/screens/home_screen.dart';
import 'package:student_task_manager/screens/signup_screen.dart';
import 'package:student_task_manager/services/auth_service.dart';
import 'package:student_task_manager/widgets/custom_text_field.dart';
import 'package:student_task_manager/widgets/theme_toggle.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _googleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // EMAIL / PASSWORD LOGIN
  // ============================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await AuthService.login(
        email,
        password,
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        HomeScreen.routeName,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // GOOGLE SIGN-IN
  // ============================================================

  Future<void> _signInWithGoogle() async {
    if (_googleLoading) return;

    setState(() {
      _googleLoading = true;
    });

    try {
      UserCredential userCredential;

      // ==========================================================
      // WEB / CHROME
      // ==========================================================

      if (kIsWeb) {
        final GoogleAuthProvider provider = GoogleAuthProvider();

        provider.addScope(
          'https://www.googleapis.com/auth/userinfo.email',
        );

        provider.addScope(
          'https://www.googleapis.com/auth/userinfo.profile',
        );

        userCredential =
            await FirebaseAuth.instance.signInWithPopup(provider);
      }

      // ==========================================================
      // ANDROID / IOS
      // ==========================================================

      else {
        final GoogleSignIn googleSignIn =
            GoogleSignIn.instance;

        await googleSignIn.initialize();

        final GoogleSignInAccount googleUser =
            await googleSignIn.authenticate();

        final GoogleSignInAuthentication googleAuth =
            googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential =
            await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }

      if (!mounted) return;

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception(
          'Unable to get Google user information.',
        );
      }

      // ==========================================================
      // SUCCESS
      // ==========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome ${user.displayName ?? user.email ?? 'User'}!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        HomeScreen.routeName,
      );
    }

    // ============================================================
    // FIREBASE AUTH ERROR
    // ============================================================

    on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'popup-closed-by-user':
          message = 'Google Sign-In was cancelled.';
          break;

        case 'popup-blocked':
          message =
              'Google Sign-In popup was blocked by the browser.';
          break;

        case 'network-request-failed':
          message =
              'Network error. Please check your internet connection.';
          break;

        case 'account-exists-with-different-credential':
          message =
              'An account already exists with a different sign-in method.';
          break;

        case 'operation-not-allowed':
          message =
              'Google Sign-In is not enabled in Firebase Authentication.';
          break;

        default:
          message =
              e.message ?? 'Google Sign-In failed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }

    // ============================================================
    // GENERAL ERROR
    // ============================================================

    catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign-In failed: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    finally {
      if (mounted) {
        setState(() {
          _googleLoading = false;
        });
      }
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    if (!RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+',
    ).hasMatch(value.trim())) {
      return 'Enter a valid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0A0A0F),
                    Color(0xFF1A1A2E),
                  ]
                : const [
                    Color(0xFFF8F9FE),
                    Color(0xFFE8ECFF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==================================================
                    // THEME TOGGLE
                    // ==================================================

                    const Align(
                      alignment: Alignment.topRight,
                      child: ThemeToggle(),
                    ),

                    const SizedBox(height: 40),

                    // ==================================================
                    // LOGO
                    // ==================================================

                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6C63FF),
                            Color(0xFF00D2FF),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF)
                                .withAlpha(60),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    Text(
                      'Welcome Back!',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to continue managing your tasks',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),

                    const SizedBox(height: 40),

                    // ==================================================
                    // LOGIN FORM
                    // ==================================================

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // EMAIL
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            keyboardType:
                                TextInputType.emailAddress,
                            validator: _validateEmail,
                            prefixIcon:
                                Icons.email_outlined,
                          ),

                          const SizedBox(height: 16),

                          // PASSWORD
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            obscureText:
                                _obscurePassword,
                            validator:
                                _validatePassword,
                            prefixIcon:
                                Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons
                                        .visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },
                            ),
                          ),

                          // FORGOT PASSWORD
                          const SizedBox(height: 8),

                          Align(
                            alignment:
                                Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  ForgotPasswordScreen
                                      .routeName,
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // SIGN IN BUTTON
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (_loading ||
                                          _googleLoading)
                                      ? null
                                      : _login,
                              style: ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFF6C63FF,
                                ),
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 18,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(14),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color:
                                            Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // OR DIVIDER
                          // ==================================================

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Theme.of(
                                    context,
                                  )
                                      .colorScheme
                                      .outline
                                      .withOpacity(0.4),
                                ),
                              ),

                              Padding(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    )
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Divider(
                                  color: Theme.of(
                                    context,
                                  )
                                      .colorScheme
                                      .outline
                                      .withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // GOOGLE SIGN-IN BUTTON
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed:
                                  (_loading ||
                                          _googleLoading)
                                      ? null
                                      : _signInWithGoogle,
                              style: OutlinedButton
                                  .styleFrom(
                                side: BorderSide(
                                  color: Theme.of(
                                    context,
                                  )
                                      .colorScheme
                                      .outline,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(14),
                                ),
                              ),
                              child: _googleLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        // Google "G"
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration:
                                              BoxDecoration(
                                            shape: BoxShape
                                                .circle,
                                            color: Theme.of(
                                              context,
                                            )
                                                .colorScheme
                                                .surface,
                                          ),
                                          alignment:
                                              Alignment
                                                  .center,
                                          child: const Text(
                                            'G',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  Color(
                                                0xFF4285F4,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                          width: 12,
                                        ),

                                        Text(
                                          'Continue with Google',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                            color: Theme.of(
                                              context,
                                            )
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ==================================================
                    // SIGN UP
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium,
                        ),

                        const SizedBox(width: 6),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              SignupScreen.routeName,
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}