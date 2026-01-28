import 'package:flutter/material.dart';

/// A controller class for the SignupPage.
import 'package:Rival/core/app_export.dart';
import 'package:Rival/presentation/signup_page/models/signup_model.dart';

///
/// This class manages the state of the SignupPage, including the
/// current signupModelObj
class SignupController extends GetxController {
  SignupController(this.signupModelObj);

  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  Rx<SignupModel> signupModelObj;

  Rx<bool> isShowPassword = true.obs;


}
