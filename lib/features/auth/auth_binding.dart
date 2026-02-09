import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './data/datasources/auth_local_datasource.dart';
import './data/datasources/auth_remote_datasource.dart';
import './data/repositories/auth_repository_impl.dart';
import './domain/repositories/auth_repository.dart';
import './domain/usecases/send_phone_verification_code.dart';
import './domain/usecases/verify_otp.dart';
import './domain/usecases/sign_in_with_google.dart';
import './domain/usecases/sign_in_with_facebook.dart';
import './domain/usecases/sign_in_with_email_password.dart';
import './domain/usecases/sign_up_with_email_password.dart';
import './domain/usecases/sign_out.dart';
import './presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // External dependencies
    Get.lazyPut<FirebaseAuth>(() => FirebaseAuth.instance);
    Get.lazyPut<GoogleSignIn>(() => GoogleSignIn());
    Get.lazyPut<FirebaseFirestore>(() => FirebaseFirestore.instance);

    // Data sources
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: Get.find<FirebaseAuth>(),
        googleSignIn: Get.find<GoogleSignIn>(),
      ),
    );

    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(
        firestore: Get.find<FirebaseFirestore>(),
      ),
    );

    // Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
      ),
    );

    // Use cases
    Get.lazyPut(() => SendPhoneVerificationCode(Get.find<AuthRepository>()));
    Get.lazyPut(() => VerifyOTP(Get.find<AuthRepository>()));
    Get.lazyPut(() => SignInWithGoogle(Get.find<AuthRepository>()));
    Get.lazyPut(() => SignInWithFacebook(Get.find<AuthRepository>()));
    Get.lazyPut(() => SignInWithEmailPassword(Get.find<AuthRepository>()));
    Get.lazyPut(() => SignUpWithEmailPassword(Get.find<AuthRepository>()));
    Get.lazyPut(() => SignOut(Get.find<AuthRepository>()));

    // Controller
    Get.lazyPut<AuthController>(
      () => AuthController(
        sendPhoneVerificationCodeUseCase: Get.find<SendPhoneVerificationCode>(),
        verifyOTPUseCase: Get.find<VerifyOTP>(),
        signInWithGoogleUseCase: Get.find<SignInWithGoogle>(),
        signInWithFacebookUseCase: Get.find<SignInWithFacebook>(),
        signInWithEmailPasswordUseCase: Get.find<SignInWithEmailPassword>(),
        signUpWithEmailPasswordUseCase: Get.find<SignUpWithEmailPassword>(),
        signOutUseCase: Get.find<SignOut>(),
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}
