import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Stream of current user
  Stream<User?> get authStateChanges;
  
  // Get current user
  User? get currentUser;
  
  // Phone authentication
  Future<Either<Failure, bool>> sendPhoneVerificationCode(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  });
  
  Future<Either<Failure, UserCredential>> verifyOTP(
    String otp,
    String verificationId,
  );
  
  // Google Sign In
  Future<Either<Failure, UserCredential>> signInWithGoogle();
  
  // Facebook Sign In
  Future<Either<Failure, UserCredential>> signInWithFacebook();
  
  // Email/Password authentication
  Future<Either<Failure, UserCredential>> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  );
  
  Future<Either<Failure, UserCredential>> signInWithEmailPassword(
    String email,
    String password,
  );
  
  // Password Reset
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  
  // Sign Out
  Future<Either<Failure, void>> signOut();
  
  // Check phone number registration
  Future<Either<Failure, bool>> isPhoneNumberRegistered(String phoneNumber);
  
  // Check onboarding status
  Future<Either<Failure, bool>> checkOnboardingStatus();
}
