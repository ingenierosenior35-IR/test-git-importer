import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Rival/core/constants/colors.dart';
import 'dart:io';

class VideoUploadController extends GetxController {
  final isLoading = false.obs;
  final uploadProgress = 0.0.obs;
  final Rx<File?> selectedVideo = Rx<File?>(null);
  final selectedMatchId = Rx<String?>(null);

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('matchId')) {
      selectedMatchId.value = args['matchId'] as String;
    }
  }

  Future<void> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 30),
      );

      if (video != null) {
        selectedVideo.value = File(video.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo seleccionar el video');
    }
  }

  Future<void> recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 30),
      );

      if (video != null) {
        selectedVideo.value = File(video.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo grabar el video');
    }
  }

  Future<void> uploadVideo() async {
    if (selectedVideo.value == null) {
      Get.snackbar('Error', 'Selecciona un video primero');
      return;
    }

    if (selectedMatchId.value == null) {
      Get.snackbar('Error', 'Selecciona un partido');
      return;
    }

    try {
      isLoading.value = true;
      
      // Simulate upload progress
      for (var i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        uploadProgress.value = i / 100;
      }

      // TODO: Implement actual Firebase Storage upload
      // final videoUrl = await _uploadToStorage(selectedVideo.value!);
      // await _matchRepository.updateMatchVideo(selectedMatchId.value!, videoUrl);

      Get.back();
      Get.snackbar(
        'Éxito',
        'Video subido correctamente',
        backgroundColor: AppColors.kGreen.withOpacity(0.8),
        colorText: AppColors.kWhite,
      );
    } catch (e) {
      Get.snackbar('Error', 'No se pudo subir el video');
    } finally {
      isLoading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  void removeVideo() {
    selectedVideo.value = null;
    uploadProgress.value = 0.0;
  }
}

class VideoUploadScreen extends StatelessWidget {
  const VideoUploadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoUploadController());

    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkBackground,
        title: const Text(
          'Subir Video',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final video = controller.selectedVideo.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (video == null) ...[
                _buildVideoSelectionSection(controller),
              ] else ...[
                _buildVideoPreviewSection(controller, video),
                const SizedBox(height: 24),
                if (controller.isLoading.value) ...[
                  _buildUploadProgress(controller),
                ] else ...[
                  _buildUploadButton(controller),
                ],
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildVideoSelectionSection(VideoUploadController controller) {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.kDarkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.kYellowAccent.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_rounded,
                  size: 64,
                  color: AppColors.kYellowAccent.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selecciona o graba un video',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.kGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          icon: Icons.photo_library_rounded,
          label: 'Seleccionar de galería',
          onTap: controller.pickVideoFromGallery,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.videocam_rounded,
          label: 'Grabar video',
          onTap: controller.recordVideo,
        ),
      ],
    );
  }

  Widget _buildVideoPreviewSection(VideoUploadController controller, File video) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_outline_rounded,
                  size: 64,
                  color: AppColors.kYellowAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  video.path.split('/').last,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.kGrey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: controller.removeVideo,
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.kWhite,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.kRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress(VideoUploadController controller) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: controller.uploadProgress.value,
          backgroundColor: AppColors.kDarkCard,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.kYellowAccent),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 12),
        Text(
          '${(controller.uploadProgress.value * 100).toInt()}% subido',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.kGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(VideoUploadController controller) {
    return ElevatedButton(
      onPressed: controller.uploadVideo,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.kYellowAccent,
        foregroundColor: AppColors.kBlack,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Subir video',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.kYellowAccent, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kWhite,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.kGrey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
