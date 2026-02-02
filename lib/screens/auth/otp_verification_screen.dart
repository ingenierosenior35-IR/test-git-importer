import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import '../onboarding/sport_selection_screen.dart';
import '../../routes/app_routes.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String identifier; // Can be phone number or email
  final bool isPhone; // true if phone, false if email
  final String? verificationId; // Only required for phone

  const OTPVerificationScreen({
    Key? key,
    required this.identifier,
    required this.isPhone,
    this.verificationId,
  }) : assert(
         !isPhone || verificationId != null,
         'verificationId is required when isPhone is true',
       ),
       super(key: key);

  // Legacy constructor for backward compatibility
  factory OTPVerificationScreen.phone({
    required String phoneNumber,
    required String verificationId,
  }) {
    return OTPVerificationScreen(
      identifier: phoneNumber,
      isPhone: true,
      verificationId: verificationId,
    );
  }

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final AuthService _authService = Get. find<AuthService>();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
  if (_otpController.text.length != 6) {
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un código de 6 dígitos válido'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    if (widget.isPhone && widget.verificationId != null) {
      // Phone verification
      final userCredential = await _authService.verifyOTP(
        _otpController.text,
        widget.verificationId!,
      );

      if (userCredential != null && userCredential.user != null) {
        // Check if user has completed onboarding
        User currentUser = userCredential.user!;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        bool onboardingCompleted = userDoc.exists && 
            userDoc.data() != null && 
            (userDoc.data() as Map<String, dynamic>).containsKey('onboarding_completed') &&
            (userDoc.data() as Map<String, dynamic>)['onboarding_completed'] == true;
        
        if (onboardingCompleted) {
          // User already completed onboarding - go to home
          Get.offAllNamed(AppRoutes.homeContainerScreen);
        } else {
          // User needs to complete onboarding
          Get.offAll(() => const SportSelectionScreen());
        }
        
        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 300), () {
          if (Get.context != null && Get.context!.mounted) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              const SnackBar(
                content: Text('Verificación exitosa'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código de verificación inválido'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      // Email verification (placeholder - implement as needed)
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verificación de correo no implementada aún'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verificación fallida: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

  Future<void> _resendOTP() async {
    if (!widget.isPhone) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reenvío de código por correo no implementado aún'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.sendPhoneVerificationCode(
        widget.identifier,
        onCodeSent: (verificationId) {
          setState(() {
            _isLoading = false;
          });
          
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Código de verificación enviado'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          
          // Navigate to new OTP screen with new verification ID
          Get.off(() => OTPVerificationScreen(
            identifier: widget.identifier,
            isPhone: true,
            verificationId: verificationId,
          ));
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
          });
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reenviar código: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black,  // ← Color del texto
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: theme.colorScheme. primary),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Colors.grey[100],
      ),
    );

    return Scaffold(
      backgroundColor: theme. colorScheme.onErrorContainer,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.onErrorContainer,
        elevation: 0,
        leading: IconButton(
          icon:  const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child:  Padding(
            padding: getPadding(all: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: getVerticalSize(40)),
                
                // Title
                Text(
                  'Código de Verificación',
                  style:  theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: getVerticalSize(16)),
                
                Text(
                  'Enviamos un código de verificación a',
                  style: theme.textTheme. bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: getVerticalSize(8)),
                
                Text(
                  widget.identifier,
                  style: theme. textTheme.bodyLarge?. copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign:  TextAlign.center,
                ),
                
                SizedBox(height: getVerticalSize(40)),
                
                // OTP Input
                Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  showCursor: true,
                  onCompleted: (pin) => _verifyOTP(),
                ),
                
                SizedBox(height: getVerticalSize(40)),
                
                // Verify button
                CustomElevatedButton(
                  height: getVerticalSize(54),
                  text: _isLoading ? 'VERIFICANDO.. .' : 'VERIFICAR',
                  buttonStyle: CustomButtonStyles.fillPrimary,
                  buttonTextStyle: CustomTextStyles.bodyLargeUniformProExtraCondensedOnErrorContainer,
                  onTap:  _isLoading ? null : _verifyOTP,
                ),
                
                SizedBox(height: getVerticalSize(24)),
                
                // Resend code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "¿No recibiste el código? ",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : _resendOTP,
                      child:  Text(
                        'Reenviar',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme. primary,
                          fontWeight:  FontWeight.bold,
                        ),
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
    );
  }
}