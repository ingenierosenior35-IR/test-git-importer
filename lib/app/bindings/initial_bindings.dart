import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/utils/pref_utils.dart';
import '../../core/network/network_info.dart';
import '../../data/apiClient/api_client.dart';
import '../../features/auth/auth_binding.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core utilities
    Get.put(PrefUtils());
    Get.put(ApiClient());
    Connectivity connectivity = Connectivity();
    Get.put(NetworkInfo(connectivity));
    
    // Initialize Auth binding
    AuthBinding().dependencies();
  }
}
