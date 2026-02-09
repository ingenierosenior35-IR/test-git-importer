import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  User? get currentUser => remoteDataSource.currentUser;

  @override
  Future<Either<Failure, bool>> sendPhoneVerificationCode(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      final result = await remoteDataSource.sendPhoneVerificationCode(
        phoneNumber,
        onCodeSent: onCodeSent,
        onError: onError,
      );
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to send verification code'));
    }
  }

  @override
  Future<Either<Failure, UserCredential>> verifyOTP(
    String otp,
    String verificationId,
  ) async {
    try {
      final userCredential = await remoteDataSource.verifyOTP(otp, verificationId);
      
      if (userCredential.user != null) {
        localDataSource.createOrUpdateUser(
          uid: userCredential.user!.uid,
          phoneNumber: userCredential.user!.phoneNumber,
          provider: 'phone',
        ).catchError((e) {
          debugPrint('Error creating user in Firestore: $e');
        });
      }
      
      return Right(userCredential);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to verify OTP'));
    }
  }

  @override
  Future<Either<Failure, UserCredential>> signInWithGoogle() async {
    try {
      final userCredential = await remoteDataSource.signInWithGoogle();
      
      if (userCredential.user != null) {
        localDataSource.createOrUpdateUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          displayName: userCredential.user!.displayName,
          photoURL: userCredential.user!.photoURL,
          provider: 'google',
        ).catchError((e) {
          debugPrint('Error creating user in Firestore: $e');
        });
      }
      
      return Right(userCredential);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to sign in with Google'));
    }
  }

  @override
  Future<Either<Failure, UserCredential>> signInWithFacebook() async {
    try {
      final userCredential = await remoteDataSource.signInWithFacebook();
      
      if (userCredential.user != null) {
        localDataSource.createOrUpdateUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          displayName: userCredential.user!.displayName,
          photoURL: userCredential.user!.photoURL,
          provider: 'facebook',
        ).catchError((e) {
          debugPrint('Error creating user in Firestore: $e');
        });
      }
      
      return Right(userCredential);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to sign in with Facebook'));
    }
  }

  @override
  Future<Either<Failure, UserCredential>> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userCredential = await remoteDataSource.signUpWithEmailPassword(
        email,
        password,
        displayName,
      );
      
      if (userCredential.user != null) {
        localDataSource.createOrUpdateUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          displayName: displayName,
          provider: 'email',
        ).catchError((e) {
          debugPrint('Error creating user in Firestore: $e');
        });
      }
      
      return Right(userCredential);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to sign up'));
    }
  }

  @override
  Future<Either<Failure, UserCredential>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await remoteDataSource.signInWithEmailPassword(
        email,
        password,
      );
      
      if (userCredential.user != null) {
        localDataSource.createOrUpdateUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          displayName: userCredential.user!.displayName,
          provider: 'email',
        ).catchError((e) {
          debugPrint('Error updating user in Firestore: $e');
        });
      }
      
      return Right(userCredential);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to sign in'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to send password reset email'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to sign out'));
    }
  }

  @override
  Future<Either<Failure, bool>> isPhoneNumberRegistered(
    String phoneNumber,
  ) async {
    try {
      final result = await localDataSource.isPhoneNumberRegistered(phoneNumber);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to check phone number'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkOnboardingStatus() async {
    try {
      final user = currentUser;
      if (user == null) {
        return const Right(false);
      }
      final result = await localDataSource.isOnboardingCompleted(user.uid);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to check onboarding status'));
    }
  }
}
