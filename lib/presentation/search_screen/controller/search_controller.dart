import 'package:Rival/core/app_export.dart';import 'package:Rival/presentation/search_screen/models/search_model.dart';/// A controller class for the SearchScreen.
///
/// This class manages the state of the SearchScreen, including the
/// current searchModelObj
class SearchController extends GetxController {Rx<SearchModel> searchModelObj = SearchModel().obs;

 }
