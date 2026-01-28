import 'package:Rival/core/app_export.dart';
import 'package:Rival/presentation/blog_detail_screen/models/blog_detail_model.dart';

/// A controller class for the BlogDetailScreen.
///
/// This class manages the state of the BlogDetailScreen, including the
/// current blogDetailModelObj
class BlogDetailController extends GetxController {
  Rx<BlogDetailModel> blogDetailModelObj = BlogDetailModel().obs;
}
