import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/social_login_button.dart';
import 'sign_up_screen.dart';
import 'otp_verification_screen.dart';
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
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  bool isEmail(String input) {
    // More permissive email regex that supports longer TLDs
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(input);
  }

  bool isPhone(String input) {
    String cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }

  Future<void> handleBegin() async {
    String input = _inputController.text.trim();
    
    setState(() {
      _errorMessage = null;
    });
    
    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa tu teléfono o correo';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (isEmail(input)) {
        // Navigate to OTP verification screen with email
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        Get.to(() => OTPVerificationScreen(
          identifier: input,
          isPhone: false,
        ));
        return;
      } else if (isPhone(input)) {
        // Clean phone number and add + if not present
        String cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
        String phoneNumber = cleaned.startsWith('+') ? cleaned : '+$cleaned';
        
        // Send OTP via SMS
        await _authService.sendPhoneVerificationCode(
          phoneNumber,
          onCodeSent: (verificationId) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
            // Navigate to OTP verification screen
            Get.to(() => OTPVerificationScreen(
              identifier: phoneNumber,
              isPhone: true,
              verificationId: verificationId,
            ));
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _errorMessage = error;
                _isLoading = false;
              });
            }
          },
        );
        return;
      } else {
        setState(() {
          _errorMessage = 'Formato inválido. Ingresa un correo o teléfono válido';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
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
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo "Rival"
                Text(
                  'Rival',
                  style: GoogleFonts.urbanist(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCDFF4D),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 40),
                
                // Label "Crea tu identidad"
                Text(
                  'Crea tu identidad',
                  style: GoogleFonts.urbanist(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 40),
                
                // Single input field for phone or email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _inputController,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Teléfono o correo',
                      hintStyle: GoogleFonts.urbanist(
                        fontSize: 16,
                        color: Color(0xFF999999),
                      ),
                      filled: true,
                      fillColor: Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      errorText: _errorMessage,
                      errorStyle: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                
                SizedBox(height: 24),
                
                // "Comenzar" button
                PrimaryButton(
                  text: 'Comenzar',
                  onPressed: handleBegin,
                  isLoading: _isLoading,
                ),
                
                SizedBox(height: 24),
                
                // Divider with text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Color(0xFF333333),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'O continuar con',
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Color(0xFF333333),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Google button
                SocialLoginButton(
                  provider: SocialLoginProvider.google,
                  onPressed: _isLoading ? () {} : _handleGoogleSignIn,
                  isLoading: false,
                ),
                
                SizedBox(height: 12),
                
                // Facebook button
                SocialLoginButton(
                  provider: SocialLoginProvider.facebook,
                  onPressed: _isLoading ? () {} : _handleFacebookSignIn,
                  isLoading: false,
                ),
                
                SizedBox(height: 12),
                
                // Apple button
                SocialLoginButton(
                  provider: SocialLoginProvider.apple,
                  onPressed: null, // Apple sign-in not implemented yet
                  isLoading: false,
                ),
                
                SizedBox(height: 24),
                
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "¿No tienes cuenta? ",
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => SignUpScreen());
                      },
                      child: Text(
                        'Registrarse',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFCDFF4D),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
