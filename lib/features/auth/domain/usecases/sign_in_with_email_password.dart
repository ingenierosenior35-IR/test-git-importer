import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailPassword {
  final AuthRepository repository;

  SignInWithEmailPassword(this.repository);

  Future<Either<Failure, UserCredential>> call(
    String email,
    String password,
  ) async {
    return await repository.signInWithEmailPassword(email, password);
  }
}
