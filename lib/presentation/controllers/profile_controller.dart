import 'package:Rival/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../data/repositories/stats_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = FirestoreService();
  final StatsRepository _statsRepository = StatsRepository();
  final ImagePicker _imagePicker = ImagePicker();

  final isLoading = false.obs;
  final userName = ''.obs;
  final userPhotoUrl = ''.obs;
  final userEmail = ''.obs;
  final overallRating = 0.0.obs;
  final totalMatches = 0.obs;
  final aggregatedStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadStats();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _firestoreService.getUserData(user.uid);
        if (userData != null) {
          userName.value = userData['displayName'] ?? 'Jugador';
          userPhotoUrl.value = userData['photoURL'] ?? '';
          userEmail.value = user.email ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el perfil');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final stats = await _statsRepository.getAggregatedStats(user.uid);
        aggregatedStats.value = stats;
        
        if (stats.isNotEmpty) {
          totalMatches.value = stats['totalMatches'] ?? 0;
          overallRating.value = stats['avgImpactScore'] ?? 0.0;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las estadísticas');
    }
  }

  Future<void> updateProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        isLoading.value = true;
        final user = _authService.currentUser;
        if (user != null) {
          final file = File(image.path);
          final ref = FirebaseStorage.instance
              .ref()
              .child('profile_photos/${user.uid}.jpg');
          
          await ref.putFile(file);
          final photoUrl = await ref.getDownloadURL();

          await _firestoreService.updateUserProfile(
            uid: user.uid,
            photoURL: photoUrl,
          );

          userPhotoUrl.value = photoUrl;
          Get.snackbar('Éxito', 'Foto de perfil actualizada');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar la foto');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDisplayName(String newName) async {
    try {
      isLoading.value = true;
      final user = _authService.currentUser;
      if (user != null) {
        await _firestoreService.updateUserProfile(
          uid: user.uid,
          displayName: newName,
        );
        userName.value = newName;
        Get.back();
        Get.snackbar('Éxito', 'Nombre actualizado');
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el nombre');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToEditProfile() {
    Get.toNamed(AppRoutes.editProfileScreenNew);
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cerrar sesión');
    }
  }
}
