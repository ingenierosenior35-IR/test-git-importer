import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/scroll_picker.dart';
import '../../core/constants/app_colors.dart';
import 'photo_upload_screen.dart';

class WeightScreen extends StatefulWidget {
  final List<String> selectedSports;
  final String selectedGender;
  final Map<String, dynamic> height;

  const WeightScreen({
    Key? key,
    required this.selectedSports,
    required this.selectedGender,
    required this.height,
  }) : super(key: key);

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  // Weight - only metric (kg)
  int _weightKg = 70;

  // Generate weight options (30-200 kg)
  List<int> get _weightOptions => List.generate(171, (index) => 30 + index);

  void _onWeightChanged(int value) {
    setState(() {
      _weightKg = value;
    });
  }

  void _continue() {
    // Prepare weight data
    Map<String, dynamic> weight = {
      'value': _weightKg.toDouble(),
      'unit': 'kg',
    };

    Get.to(() => PhotoUploadScreen(
      selectedSports: widget.selectedSports,
      selectedGender: widget.selectedGender,
      height: widget.height,
      weight: weight,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      const Text(
                        '¿Cuál es tu peso?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Cada jugador tiene sus números.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Central icon (scale/weight) - now yellow
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDarker,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.borderGrey,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.monitor_weight_outlined,
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Weight Picker (more compact)
                      ScrollPicker(
                        items: _weightOptions,
                        initialItem: _weightKg,
                        suffix: ' kg',
                        onSelectedItemChanged: _onWeightChanged,
                        itemHeight: 40.0,
                        visibleItemCount: 5,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: CustomButton(
                text: 'Continuar',
                onPressed: _continue,
                height: 54,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
