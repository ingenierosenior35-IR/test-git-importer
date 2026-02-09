import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  
  Future<bool> sendPhoneVerificationCode(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  });
  
  Future<UserCredential> verifyOTP(String otp, String verificationId);
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInWithFacebook();
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  );
  Future<UserCredential> signInWithEmailPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  
  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  @override
  User? get currentUser => firebaseAuth.currentUser;

  @override
  Future<bool> sendPhoneVerificationCode(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await firebaseAuth.signInWithCredential(credential);
          } catch (e) {
            debugPrint('Error in auto-verification: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
        },
      );
      return true;
    } catch (e) {
      onError(e.toString());
      throw AuthException('Failed to send verification code: $e');
    }
  }

  @override
  Future<UserCredential> verifyOTP(String otp, String verificationId) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      throw AuthException('Failed to verify OTP: $e');
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw AuthException('Google sign in was cancelled');
      }
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      return await firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      throw AuthException('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status != LoginStatus.success) {
        throw AuthException('Facebook sign in was cancelled or failed');
      }
      
      final OAuthCredential facebookAuthCredential = 
          FacebookAuthProvider.credential(result.accessToken!.tokenString);
      
      return await firebaseAuth.signInWithCredential(facebookAuthCredential);
    } catch (e) {
      debugPrint('Error signing in with Facebook: $e');
      throw AuthException('Failed to sign in with Facebook: $e');
    }
  }

  @override
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential userCredential = 
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await userCredential.user?.updateDisplayName(displayName);
      
      return userCredential;
    } catch (e) {
      debugPrint('Error signing up with email/password: $e');
      throw AuthException('Failed to sign up: $e');
    }
  }

  @override
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error signing in with email/password: $e');
      throw AuthException('Failed to sign in: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      throw AuthException('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
      
      try {
        await googleSignIn.signOut();
      } catch (e) {
        debugPrint('Error signing out from Google: $e');
      }
      
      try {
        await FacebookAuth.instance.logOut();
      } catch (e) {
        debugPrint('Error signing out from Facebook: $e');
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
      throw AuthException('Failed to sign out: $e');
    }
  }
}
