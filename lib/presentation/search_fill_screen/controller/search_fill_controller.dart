import 'package:flutter/material.dart';

/// A controller class for the SearchFillScreen.
import 'package:Rival/core/app_export.dart';
import 'package:Rival/presentation/search_fill_screen/models/search_fill_model.dart';

import '../models/search_model_data.dart';

///
/// This class manages the state of the SearchFillScreen, including the
/// current searchFillModelObj
class SearchFillController extends GetxController {
  TextEditingController exercisevalueController = TextEditingController();



  List<SearchFillModel> searchData = SearchData.getSearchData();

}
