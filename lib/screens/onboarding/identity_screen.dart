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
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa tu teléfono o correo'),
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
      // Check if input is email or phone
      if (input.contains('@')) {
        // Navigate to sign in/sign up screen with email
        Get.toNamed(AppRoutes.signInScreen, arguments: {'email': input});
      } else {
        // Navigate to phone verification
        Get.toNamed(AppRoutes.firebaseLoginScreen, arguments: {'phone': input});
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inicio con Google cancelado'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar con Google: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inicio con Facebook cancelado'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar con Facebook: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inicio con Apple estará disponible pronto'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Logo "Rival" at the top
                const Text(
                  'RIVAL',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCDFF4D),
                    letterSpacing: 4,
                  ),
                ),
                
                const SizedBox(height: 60),
                
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
                
                const SizedBox(height: 32),
                
                // Phone/Email Input Field
                TextField(
                  controller: _phoneEmailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Teléfono o correo',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
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
                
                // "Comenzar" Button - Large and prominent
                CustomButton(
                  text: 'Comenzar',
                  onPressed: _handleContinueWithPhoneEmail,
                  isLoading: _isLoading,
                  height: 56,
                ),
                
                const SizedBox(height: 40),
                
                // Divider with "O continuar con"
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
                        'O continuar con',
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
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
