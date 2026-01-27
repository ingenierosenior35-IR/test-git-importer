import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import '../../services/auth_service.dart';
import '../onboarding/sport_selection_screen.dart';
import '../../routes/app_routes.dart';
import 'otp_verification_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = Get.put(AuthService());
  final TextEditingController _identityController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identityController.dispose();
    super.dispose();
  }

  bool _isEmail(String input) {
    // More robust email validation
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(input);
  }

  bool _isPhone(String input) {
    // Remove spaces, dashes, parentheses and other formatting characters
    String cleaned = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned);
  }

  Future<void> _handleContinue() async {
    String identity = _identityController.text.trim();
    
    if (identity.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor ingresa tu teléfono o correo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_isEmail(identity)) {
      // Email flow - navigate to sign in screen with email pre-filled
      Get.to(() => SignInScreen());
    } else if (_isPhone(identity)) {
      // Phone flow - send OTP
      setState(() {
        _isLoading = true;
      });

      // Clean phone number and format with country code
      String cleanedPhone = identity.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      String phoneNumber = cleanedPhone.startsWith('+') ? cleanedPhone : '+$cleanedPhone';

      await _authService.sendPhoneVerificationCode(
        phoneNumber,
        onCodeSent: (verificationId) {
          setState(() {
            _isLoading = false;
          });
          Get.to(() => OTPVerificationScreen(
            phoneNumber: phoneNumber,
            verificationId: verificationId,
          ));
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
          });
          Get.snackbar(
            'Error',
            error,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      );
    } else {
      Get.snackbar(
        'Error',
        'Por favor ingresa un correo o teléfono válido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

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
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signed in successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in with Google: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signed in successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in with Facebook: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                
                // RIVAL Logo
                Text(
                  'RIVAL',
                  style: TextStyle(
                    color: Color(0xFFCDFF4D),
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 60),
                
                // Main Label: "Crea tu identidad"
                Text(
                  'Crea tu identidad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 32),
                
                // Single input field for phone or email
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _identityController,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Teléfono o correo',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // "Comenzar" button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCDFF4D),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size.fromHeight(56),
                  ),
                  child: Text(
                    _isLoading ? 'CARGANDO...' : 'Comenzar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                
                SizedBox(height: 32),
                
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
                        'O continuar con',
                        style: TextStyle(
                          color: Color(0xFF666666),
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
                    backgroundColor: Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size.fromHeight(56),
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
                
                SizedBox(height: 12),
                
                // Facebook button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleFacebookSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size.fromHeight(56),
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
                
                SizedBox(height: 12),
                
                // Apple button
                ElevatedButton(
                  onPressed: null, // Apple sign-in not implemented yet
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Color(0xFF2C2C2C).withOpacity(0.5),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size.fromHeight(56),
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
                
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
