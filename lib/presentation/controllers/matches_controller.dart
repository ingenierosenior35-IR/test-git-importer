import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/models/match.dart';

class MatchesController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final MatchRepository _matchRepository = MatchRepository();

  final isLoading = false.obs;
  final matches = <Match>[].obs;
  final filteredMatches = <Match>[].obs;
  final selectedStatus = Rx<MatchStatus?>(null);

  @override
  void onInit() {
    super.onInit();
    loadMatches();
  }

  Future<void> loadMatches() async {
    try {
      isLoading.value = true;
      final user = _authService.currentUser;
      if (user != null) {
        final allMatches = await _matchRepository.getUserMatches(user.uid);
        matches.value = allMatches;
        applyFilter();
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los partidos');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter() {
    if (selectedStatus.value == null) {
      filteredMatches.value = matches;
    } else {
      filteredMatches.value = matches
          .where((match) => match.status == selectedStatus.value)
          .toList();
    }
  }

  void setFilter(MatchStatus? status) {
    selectedStatus.value = status;
    applyFilter();
  }

  void navigateToCreateMatch() {
    Get.toNamed(AppRoutes.createMatchScreen);
  }

  void navigateToMatchDetail(String matchId) {
    Get.toNamed('/match_detail', arguments: {'matchId': matchId});
  }

  Future<void> deleteMatch(String matchId) async {
    try {
      await _matchRepository.deleteMatch(matchId);
      await loadMatches();
      Get.snackbar('Éxito', 'Partido eliminado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar el partido');
    }
  }
}
