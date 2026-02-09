import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignInWithFacebook {
  final AuthRepository repository;

  SignInWithFacebook(this.repository);

  Future<Either<Failure, UserCredential>> call() async {
    return await repository.signInWithFacebook();
  }
}
