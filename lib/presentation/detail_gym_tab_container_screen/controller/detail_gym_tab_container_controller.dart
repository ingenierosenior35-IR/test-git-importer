import 'package:flutter/material.dart';

/// A controller class for the DetailGymTabContainerScreen.
import 'package:Rival/core/app_export.dart';

///
/// This class manages the state of the DetailGymTabContainerScreen, including the
/// current detailGymTabContainerModelObj
class DetailGymTabContainerController extends GetxController
    with GetSingleTickerProviderStateMixin {
 PageController pageController = PageController();
 late TabController tabviewController =
 Get.put(TabController(vsync: this, length: 2));
}
