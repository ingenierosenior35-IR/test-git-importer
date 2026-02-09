import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SendPhoneVerificationCode {
  final AuthRepository repository;

  SendPhoneVerificationCode(this.repository);

  Future<Either<Failure, bool>> call(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    return await repository.sendPhoneVerificationCode(
      phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }
}
