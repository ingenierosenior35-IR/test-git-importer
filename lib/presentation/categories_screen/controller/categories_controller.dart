import 'package:Rival/core/app_export.dart';
import 'package:Rival/presentation/categories_screen/models/categories_model.dart';

import '../models/healthtips1_item_model.dart';

/// A controller class for the CategoriesScreen.
///
/// This class manages the state of the CategoriesScreen, including the
/// current categoriesModelObj
class CategoriesController extends GetxController {
 List<Healthtips1ItemModel> categoriesData = CategoriesModel.getCAtegoriesData();
}
