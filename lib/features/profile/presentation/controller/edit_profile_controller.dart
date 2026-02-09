import 'package:Rival/core/app_export.dart';import 'package:Rival/presentation/edit_profile_screen/models/edit_profile_model.dart';import 'package:flutter/material.dart';/// A controller class for the EditProfileScreen.
///
/// This class manages the state of the EditProfileScreen, including the
/// current editProfileModelObj
class EditProfileController extends GetxController {TextEditingController firstNameController = TextEditingController();

TextEditingController lastNameController = TextEditingController();

TextEditingController emailController = TextEditingController();

Rx<EditProfileModel> editProfileModelObj = EditProfileModel().obs;

@override void onClose() { super.onClose(); firstNameController.dispose(); lastNameController.dispose(); emailController.dispose(); } 
 }
