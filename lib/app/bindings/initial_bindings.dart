import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/utils/pref_utils.dart';
import '../../core/network/network_info.dart';
import '../../data/apiClient/api_client.dart';
import '../../features/auth/auth_binding.dart';

// AÑADE ESTOS:
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../data/repositories/match_repository.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core utilities
    Get.put(PrefUtils());
    Get.put(ApiClient());
    Connectivity connectivity = Connectivity();
    Get.put(NetworkInfo(connectivity));
    
    // Servicios globales
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<FirestoreService>(() => FirestoreService(), fenix: true);
    Get.lazyPut<MatchRepository>(() => MatchRepository(), fenix: true);

    // Initialize Auth binding (features/auth)
    AuthBinding().dependencies();
  }
}