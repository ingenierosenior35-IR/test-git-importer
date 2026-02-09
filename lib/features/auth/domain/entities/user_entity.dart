import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoURL;
  final String provider;
  final bool isOnboardingCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
    required this.provider,
    this.isOnboardingCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        phoneNumber,
        photoURL,
        provider,
        isOnboardingCompleted,
        createdAt,
        updatedAt,
      ];
}
