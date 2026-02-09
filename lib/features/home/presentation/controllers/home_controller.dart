import 'package:Rival/core/app_export.dart';
import 'package:Rival/features/home/data/models/home_model.dart';
import 'package:flutter/material.dart';
///
/// This class manages the state of the HomePage, including the
/// current homeModelObj
class HomeController extends GetxController {HomeController(this.homeModelObj);

TextEditingController searchController = TextEditingController();

Rx<HomeModel> homeModelObj;

@override void onClose() { super.onClose(); searchController.dispose(); } 
 }
