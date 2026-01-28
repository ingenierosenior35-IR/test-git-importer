import 'package:Rival/core/app_export.dart';
import 'package:Rival/presentation/select_payment_method_screen/models/select_payment_method_model.dart';

class PaymentMethosData{
  static List<SelectPaymentMethodModel> getPaymentMethodData(){
    return [
      SelectPaymentMethodModel("Google pay",ImageConstant.imgGooglepay1,1),
      SelectPaymentMethodModel("Apple pay",ImageConstant.imgApplepay1,2),
      SelectPaymentMethodModel("Paypal",ImageConstant.imgGroup4148,3),
    ];
  }
}