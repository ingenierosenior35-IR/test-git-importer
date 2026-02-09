import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../domain/usecases/send_phone_verification_code.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_in_with_facebook.dart';
import '../../domain/usecases/sign_in_with_email_password.dart';
import '../../domain/usecases/sign_up_with_email_password.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final SendPhoneVerificationCode sendPhoneVerificationCodeUseCase;
  final VerifyOTP verifyOTPUseCase;
  final SignInWithGoogle signInWithGoogleUseCase;
  final SignInWithFacebook signInWithFacebookUseCase;
  final SignInWithEmailPassword signInWithEmailPasswordUseCase;
  final SignUpWithEmailPassword signUpWithEmailPasswordUseCase;
  final SignOut signOutUseCase;
  final AuthRepository authRepository;

  AuthController({
    required this.sendPhoneVerificationCodeUseCase,
    required this.verifyOTPUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithFacebookUseCase,
    required this.signInWithEmailPasswordUseCase,
    required this.signUpWithEmailPasswordUseCase,
    required this.signOutUseCase,
    required this.authRepository,
  });

  // Observable user
  final Rx<User?> user = Rx<User?>(null);
  
  // Verification ID for phone authentication
  String? verificationId;
  
  // Loading states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(authRepository.authStateChanges);
  }

  // Get current user
  User? get currentUser => authRepository.currentUser;

  // Phone Authentication - Send OTP
  Future<bool> sendPhoneVerificationCode(String phoneNumber) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final result = await sendPhoneVerificationCodeUseCase.call(
      phoneNumber,
      onCodeSent: (verificationId) {
        this.verificationId = verificationId;
        debugPrint('Code sent, verification ID: $verificationId');
      },
      onError: (error) {
        errorMessage.value = error;
        debugPrint('Error: $error');
      },
    );
    
    isLoading.value = false;
    
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        return false;
      },
      (success) => success,
    );
  }

  // Verify OTP and Sign In/Sign Up
  Future<UserCredential?> verifyOTP(String otp) async {
    if (verificationId == null) {
      errorMessage.value = 'Verification ID not found';
      return null;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    final result = await verifyOTPUseCase.call(otp, verificationId!);
    
    isLoading.value = false;
    
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        return null;
      },
      (userCredential) => userCredential,
    );
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final result = await signInWithGoogleUseCase.call();
    
    isLoading.value = false;
    
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        return null;
      },
      (userCredential) => userCredential,
    );
  }

  // Facebook Sign In
  Future<UserCredential?> signInWithFacebook() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final result = await signInWithFacebookUseCase.call();
    
    isLoading.value = false;
    
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        return null;
      },
      (userCredential) => userCredential,
    );
  }

  // Email/Password Sign Up
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final result = await signUpWithEmailPasswordUseCase.call(
      email,
      password,
      displayName,
    );
    
    isLoading.value = false;
    
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        return null;
      },
      (userCredential) => userCredential,
    );
  }

  // Email/Password Sign In
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final result = await signInWithEmailPasswordUseCase.call(email, password);
    
    isLoading.value = false;
    
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        return null;
      },
      (userCredential) => userCredential,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final result = await signOutUseCase.call();
    
    isLoading.value = false;
    
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        debugPrint('Sign out error: ${failure.message}');
      },
      (_) {
        debugPrint('✅ User signed out successfully');
      },
    );
  }

  // Check if phone number is registered
  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    final result = await authRepository.isPhoneNumberRegistered(phoneNumber);
    return result.fold(
      (failure) => false,
      (isRegistered) => isRegistered,
    );
  }

  // Check onboarding status
  Future<bool> checkOnboardingStatus() async {
    final result = await authRepository.checkOnboardingStatus();
    return result.fold(
      (failure) => false,
      (isCompleted) => isCompleted,
    );
  }
}
