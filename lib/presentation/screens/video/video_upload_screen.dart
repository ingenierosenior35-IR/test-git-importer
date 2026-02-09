import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../controllers/video_controller.dart';

class VideoUploadScreen extends StatelessWidget {
  const VideoUploadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoController());

    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.video,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kWhite,
                ),
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.uploadProgress.value > 0 && 
                    controller.uploadProgress.value < 1) {
                  return _buildUploadProgress(controller);
                }
                return _buildUploadCard(controller);
              }),
              const SizedBox(height: 24),
              Text(
                'Mis Videos',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kWhite,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.kYellowAccent,
                      ),
                    );
                  }

                  if (controller.videos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_off_rounded,
                            size: 64,
                            color: AppColors.kGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay videos',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.kGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.videos.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final video = controller.videos[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.kDarkCard,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.kDarkSurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.play_circle_outline_rounded,
                                color: AppColors.kYellowAccent,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Video ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.kWhite,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.getStatusText(video.status),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.kGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusIcon(video.status),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard(VideoController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.kYellowAccent.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.kYellowAccent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload_rounded,
              color: AppColors.kYellowAccent,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.uploadVideo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.kWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sube el video de tu partido para análisis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.kGrey,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedMatchId.value,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.kDarkSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Seleccionar partido',
              hintStyle: TextStyle(color: AppColors.kGrey),
            ),
            dropdownColor: AppColors.kDarkCard,
            style: const TextStyle(color: AppColors.kWhite),
            items: controller.availableMatches.map((match) {
              return DropdownMenuItem(
                value: match.id,
                child: Text(match.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectMatch(value);
              }
            },
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.pickAndUploadVideo,
              icon: const Icon(Icons.videocam_rounded),
              label: Text(AppStrings.selectFile),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kYellowAccent,
                foregroundColor: AppColors.kBlack,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress(VideoController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Subiendo video...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.kWhite,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: controller.uploadProgress.value,
            backgroundColor: AppColors.kDarkSurface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.kYellowAccent),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(
            '${(controller.uploadProgress.value * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.kYellowAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(dynamic status) {
    IconData icon;
    Color color;

    switch (status.toString()) {
      case 'VideoStatus.ready':
        icon = Icons.check_circle_rounded;
        color = AppColors.kGreen;
        break;
      case 'VideoStatus.processing':
        icon = Icons.hourglass_empty_rounded;
        color = Colors.orange;
        break;
      case 'VideoStatus.failed':
        icon = Icons.error_rounded;
        color = AppColors.kRed;
        break;
      default:
        icon = Icons.cloud_upload_rounded;
        color = AppColors.kGrey;
    }

    return Icon(icon, color: color, size: 24);
  }
}
