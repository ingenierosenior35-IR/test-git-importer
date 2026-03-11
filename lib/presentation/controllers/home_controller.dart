import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/models/match.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = FirestoreService();
  final MatchRepository _matchRepository = MatchRepository();

  final isLoading = false.obs;
  final userName = ''.obs;
  final userPhotoUrl = ''.obs;
  final upcomingMatches = <Match>[].obs;
  final recentMatches = <Match>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadMatches();
  }

  Future<void> loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _firestoreService.getUserData(user.uid);
        if (userData != null) {
          userName.value = userData['displayName'] ?? 'Jugador';
          userPhotoUrl.value = userData['photoURL'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar los datos del usuario');
    }
  }

  Future<void> loadMatches() async {
    try {
      isLoading.value = true;
      final user = _authService.currentUser;
      if (user != null) {
        final matches = await _matchRepository.getUserMatches(user.uid);
        final now = DateTime.now();
        
        upcomingMatches.value = matches
            .where((match) => match.dateTime.isAfter(now))
            .take(3)
            .toList();
        
        recentMatches.value = matches
            .where((match) => match.dateTime.isBefore(now))
            .take(3)
            .toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los partidos');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToCreateTournament() {
    Get.snackbar('Próximamente', 'Función de crear torneo en desarrollo');
  }

  void navigateToMatchDetail(String matchId) {
    Get.toNamed('/match_detail_screen', arguments: {'matchId': matchId});
  }
}
