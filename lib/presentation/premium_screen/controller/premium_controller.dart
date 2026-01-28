import 'package:Rival/core/app_export.dart';
import 'package:Rival/presentation/premium_screen/models/premium_model.dart';

import '../models/subscriptionpla_item_model.dart';

/// A controller class for the PremiumScreen.
///
/// This class manages the state of the PremiumScreen, including the
/// current premiumModelObj
class PremiumController extends GetxController {
 List<SubscriptionplaItemModel> premiumData =  PremiumModel.getPremiumItem();

  int currentPremiumId = 1;
}
