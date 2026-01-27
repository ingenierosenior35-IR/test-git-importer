import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import '../../services/auth_service.dart';
import '../onboarding/sport_selection_screen.dart';
import '../../routes/app_routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = Get.put(AuthService());
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (userCredential != null) {
        bool onboardingCompleted = await _authService.checkOnboardingStatus();
        
        Get.snackbar(
          'Success',
          'Signed in successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        if (onboardingCompleted) {
          Get.offAllNamed(AppRoutes.homeContainerScreen);
        } else {
          Get.offAll(() => const SportSelectionScreen());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      Get.snackbar(
        'Error',
        'Failed to sign in with Google: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithFacebook();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (userCredential != null) {
        bool onboardingCompleted = await _authService.checkOnboardingStatus();
        
        Get.snackbar(
          'Success',
          'Signed in successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        if (onboardingCompleted) {
          Get.offAllNamed(AppRoutes.homeContainerScreen);
        } else {
          Get.offAll(() => const SportSelectionScreen());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      Get.snackbar(
        'Error',
        'Failed to sign in with Facebook: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                
                // Illustration/Image placeholder (you can add your custom image here)
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.credit_card,
                      size: 80,
                      color: Color(0xFFCDFF4D),
                    ),
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Title
                Text(
                  'Welcome to airfly ✈️',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 12),
                
                // Subtitle
                Text(
                  'If you already have airfly account, enter your email below.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 32),
                
                // Continue with Email button
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => SignInScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCDFF4D),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Continue with Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Divider with text
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[800],
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Sign in with',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[800],
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Google button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E1E1E),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomImageView(
                        svgPath: ImageConstant.imgGooglepay1,
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Facebook button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleFacebookSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E1E1E),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.facebook, color: Colors.blue, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Continue with Facebook',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Apple button
                ElevatedButton(
                  onPressed: null, // Apple sign-in not implemented yet
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E1E1E),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apple, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Continue with Apple',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => SignUpScreen());
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Color(0xFFCDFF4D),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
