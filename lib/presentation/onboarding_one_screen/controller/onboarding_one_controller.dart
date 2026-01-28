import 'package:flutter/cupertino.dart';
import 'package:Rival/core/app_export.dart';
import 'package:Rival/presentation/onboarding_one_screen/models/onboarding_one_model.dart';

import '../models/workoutanywhere_item_model.dart';

/// A controller class for the OnboardingOneScreen.
///
/// This class manages the state of the OnboardingOneScreen, including the
/// current onboardingOneModelObj
class OnboardingOneController extends GetxController {
 PageController pageController = PageController();
 List<WorkoutanywhereItemModel> getOnboarding = OnboardingOneModel.getOnboasdingData();
 Rx<int> sliderIndex = 0.obs;
 int currentPage = 0;

 void setCurrentPage(int value) {
  currentPage = value;
  update();
 }
}
