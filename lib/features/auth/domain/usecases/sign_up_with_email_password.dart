import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailPassword {
  final AuthRepository repository;

  SignUpWithEmailPassword(this.repository);

  Future<Either<Failure, UserCredential>> call(
    String email,
    String password,
    String displayName,
  ) async {
    return await repository.signUpWithEmailPassword(email, password, displayName);
  }
}
