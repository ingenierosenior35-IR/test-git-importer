import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/social_login_button.dart';
import 'sport_selection_screen.dart';

class IdentityScreen extends StatefulWidget {
  const IdentityScreen({Key? key}) : super(key: key);

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  final TextEditingController _phoneEmailController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;
  bool _isAppleLoading = false;

  @override
  void dispose() {
    _phoneEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleContinueWithPhoneEmail() async {
    final input = _phoneEmailController.text.trim();
    
    if (input.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter your phone number or email',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if input is email or phone
      if (input.contains('@')) {
        // Navigate to sign in/sign up screen with email
        Get.toNamed(AppRoutes.signInScreen, arguments: {'email': input});
      } else {
        // Navigate to phone verification
        Get.toNamed(AppRoutes.firebaseLoginScreen, arguments: {'phone': input});
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      UserCredential? userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null && userCredential.user != null) {
        // Check if onboarding is completed
        bool onboardingCompleted = await _authService.checkOnboardingStatus();
        
        if (onboardingCompleted) {
          // Navigate to home
          Get.offAllNamed(AppRoutes.homeContainerScreen);
        } else {
          // Navigate to sport selection (start onboarding)
          Get.off(() => const SportSelectionScreen());
        }
      } else {
        Get.snackbar(
          'Sign In Cancelled',
          'Google sign in was cancelled',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in with Google: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() {
      _isFacebookLoading = true;
    });

    try {
      UserCredential? userCredential = await _authService.signInWithFacebook();
      
      if (userCredential != null && userCredential.user != null) {
        // Check if onboarding is completed
        bool onboardingCompleted = await _authService.checkOnboardingStatus();
        
        if (onboardingCompleted) {
          // Navigate to home
          Get.offAllNamed(AppRoutes.homeContainerScreen);
        } else {
          // Navigate to sport selection (start onboarding)
          Get.off(() => const SportSelectionScreen());
        }
      } else {
        Get.snackbar(
          'Sign In Cancelled',
          'Facebook sign in was cancelled',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in with Facebook: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFacebookLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isAppleLoading = true;
    });

    try {
      // Apple Sign In not implemented yet
      Get.snackbar(
        'Coming Soon',
        'Apple Sign In will be available soon',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAppleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Blurred background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.95),
                ],
              ),
            ),
          ),
          // Modal sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        
                        // Logo "Rival"
                        const Text(
                          'RIVAL',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFCDFF4D),
                            letterSpacing: 4,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Title
                        const Text(
                          'Crea tu identidad',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Subtitle
                        const Text(
                          'Todo jugador tiene una historia.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Phone/Email Input Field
                        TextField(
                          controller: _phoneEmailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Teléfono o correo',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            filled: true,
                            fillColor: const Color(0xFF2C2C2C),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // "Comenzar" Button
                        CustomButton(
                          text: 'Comenzar',
                          onPressed: _handleContinueWithPhoneEmail,
                          isLoading: _isLoading,
                          height: 54,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Divider with "Sign in with"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[700],
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Sign in with',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[700],
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Google Sign In Button
                        SocialLoginButton(
                          provider: SocialLoginProvider.google,
                          onPressed: _handleGoogleSignIn,
                          isLoading: _isGoogleLoading,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Facebook Sign In Button
                        SocialLoginButton(
                          provider: SocialLoginProvider.facebook,
                          onPressed: _handleFacebookSignIn,
                          isLoading: _isFacebookLoading,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Apple Sign In Button
                        SocialLoginButton(
                          provider: SocialLoginProvider.apple,
                          onPressed: _handleAppleSignIn,
                          isLoading: _isAppleLoading,
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
