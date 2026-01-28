import 'package:flutter/material.dart';
// Removed: import 'package:get/get.dart'; - unnecessary import
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../services/auth_service.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import 'otp_verification_screen.dart';
import '../onboarding/sport_selection_screen.dart';

/// DEPRECATED: This screen uses phone number authentication and is being replaced by WelcomeScreen.
/// The app flow now uses WelcomeScreen as the initial authentication screen.
/// This file is kept for backward compatibility but should not be actively used.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = Get.put(AuthService());
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  String _completePhoneNumber = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePhoneLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_completePhoneNumber.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor ingresa un número de teléfono válido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.sendPhoneVerificationCode(
        _completePhoneNumber,
        onCodeSent: (verificationId) {
          setState(() {
            _isLoading = false;
          });
          
          // Navigate to OTP verification screen with correct parameters
          Get.to(() => OTPVerificationScreen(
            identifier: _completePhoneNumber,  // Changed from phoneNumber to identifier
            isPhone: true,  // Added required parameter
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Error al enviar código de verificación: $e',
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
      
      setState(() {
        _isLoading = false;
      });

      if (userCredential != null) {
        // Check onboarding status
        bool onboardingCompleted = await _authService.checkOnboardingStatus();
        
        Get.snackbar(
          'Éxito',
          'Sesión iniciada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        if (onboardingCompleted) {
          Get.offAllNamed(AppRoutes.homeContainerScreen);
        } else {
          Get.offAll(() => const SportSelectionScreen());
        }
      } else {
        Get.snackbar(
          'Cancelado',
          'Inicio con Google cancelado',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Error al iniciar con Google: $e',
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
      
      setState(() {
        _isLoading = false;
      });

      if (userCredential != null) {
        // Check onboarding status
        bool onboardingCompleted = await _authService.checkOnboardingStatus();
        
        Get.snackbar(
          'Éxito',
          'Sesión iniciada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        if (onboardingCompleted) {
          Get.offAllNamed(AppRoutes.homeContainerScreen);
        } else {
          Get.offAll(() => const SportSelectionScreen());
        }
      } else {
        Get.snackbar(
          'Cancelado',
          'Inicio con Facebook cancelado',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Error al iniciar con Facebook: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.onErrorContainer,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: getPadding(all: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: getVerticalSize(60)),
                  
                  // Logo
                  Center(
                    child: CustomImageView(
                      svgPath: ImageConstant.imgGroup,
                      height: getSize(120),
                      width: getSize(120),
                    ),
                  ),
                  
                  SizedBox(height: getVerticalSize(40)),
                  
                  // Title
                  Text(
                    '¡Bienvenido de nuevo!',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: getVerticalSize(8)),
                  
                  Text(
                    'Inicia sesión para continuar',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: getVerticalSize(40)),
                  
                  // Phone number input
                  IntlPhoneField(
                    controller: _phoneController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Número de teléfono',
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    initialCountryCode: 'US',
                    dropdownTextStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    onChanged: (phone) {
                      _completePhoneNumber = phone.completeNumber;
                    },
                  ),
                  
                  SizedBox(height: getVerticalSize(24)),
                  
                  // Login button
                  CustomElevatedButton(
                    height: getVerticalSize(54),
                    text: _isLoading ? 'CARGANDO...' : 'INICIAR SESIÓN',
                    buttonStyle: CustomButtonStyles.fillPrimary,
                    buttonTextStyle: CustomTextStyles.bodyLargeUniformProExtraCondensedOnErrorContainer,
                    onTap: _isLoading ? null : _handlePhoneLogin,
                  ),
                  
                  SizedBox(height: getVerticalSize(30)),
                  
                  // Divider with text
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: getPadding(left: 16, right: 16),
                        child: Text(
                          'O continuar con',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: getVerticalSize(30)),
                  
                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Sign In Button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                          color: Colors.white,
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          icon: CustomImageView(
                            svgPath: ImageConstant.imgGooglepay1,
                            height: getSize(28),
                            width: getSize(28),
                          ),
                          iconSize: getSize(60),
                          padding: EdgeInsets.all(getSize(16)),
                        ),
                      ),
                      
                      SizedBox(width: getHorizontalSize(24)),
                      
                      // Facebook Sign In Button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                          color: Colors.white,
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : _handleFacebookSignIn,
                          icon: Icon(
                            Icons.facebook,
                            color: Colors.blue[800],
                            size: getSize(28),
                          ),
                          iconSize: getSize(60),
                          padding: EdgeInsets.all(getSize(16)),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: getVerticalSize(40)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}