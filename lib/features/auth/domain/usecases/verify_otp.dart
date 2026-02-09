import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyOTP {
  final AuthRepository repository;

  VerifyOTP(this.repository);

  Future<Either<Failure, UserCredential>> call(
    String otp,
    String verificationId,
  ) async {
    return await repository.verifyOTP(otp, verificationId);
  }
}
