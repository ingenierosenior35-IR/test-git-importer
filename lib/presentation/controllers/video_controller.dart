import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/auth_service.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/models/video.dart';
import '../../data/models/match.dart';

class VideoController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final VideoRepository _videoRepository = VideoRepository();
  final MatchRepository _matchRepository = MatchRepository();

  final isLoading = false.obs;
  final videos = <Video>[].obs;
  final uploadProgress = 0.0.obs;
  final selectedMatchId = Rx<String?>(null);
  final availableMatches = <Match>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadVideos();
    loadAvailableMatches();
  }

  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      final user = _authService.currentUser;
      if (user != null) {
        final userVideos = await _videoRepository.getUserVideos(user.uid);
        videos.value = userVideos;
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los videos');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAvailableMatches() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final matches = await _matchRepository.getUserMatches(user.uid);
        availableMatches.value = matches
            .where((match) => match.status != MatchStatus.cancelled)
            .toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los partidos');
    }
  }

  Future<void> pickAndUploadVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        await uploadVideo(file);
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo seleccionar el video');
    }
  }

  Future<void> uploadVideo(File videoFile) async {
    if (selectedMatchId.value == null) {
      Get.snackbar('Error', 'Selecciona un partido primero');
      return;
    }

    try {
      uploadProgress.value = 0.0;
      final user = _authService.currentUser;
      if (user != null) {
        await _videoRepository.uploadVideo(
          videoFile: videoFile,
          matchId: selectedMatchId.value!,
          uploadedBy: user.uid,
          onProgress: (progress) {
            uploadProgress.value = progress;
          },
        );

        await _matchRepository.updateMatchVideo(
          selectedMatchId.value!,
          'video_url_placeholder',
        );

        Get.snackbar('Éxito', 'Video subido correctamente');
        await loadVideos();
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo subir el video');
    }
  }

  void selectMatch(String matchId) {
    selectedMatchId.value = matchId;
  }

  String getStatusText(VideoStatus status) {
    switch (status) {
      case VideoStatus.uploading:
        return 'Subiendo';
      case VideoStatus.processing:
        return 'Procesando';
      case VideoStatus.ready:
        return 'Listo';
      case VideoStatus.failed:
        return 'Error';
    }
  }
}
