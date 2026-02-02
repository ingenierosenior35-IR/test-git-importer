import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/scroll_picker.dart';
import '../../core/constants/app_colors.dart';
import 'weight_screen.dart';

class HeightScreen extends StatefulWidget {
  final List<String> selectedSports;
  final String selectedGender;

  const HeightScreen({
    Key? key,
    required this.selectedSports,
    required this.selectedGender,
  }) : super(key: key);

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  // Height - only metric (cm)
  int _heightCm = 170;

  // Generate height options (100-250 cm for inclusivity)
  List<int> get _heightOptions => List.generate(151, (index) => 100 + index);

  void _onHeightChanged(int value) {
    setState(() {
      _heightCm = value;
    });
  }

  void _continue() {
    // Prepare height data
    Map<String, dynamic> height = {
      'value': _heightCm.toDouble(),
      'unit': 'cm',
    };

    Get.to(() => WeightScreen(
      selectedSports: widget.selectedSports,
      selectedGender: widget.selectedGender,
      height: height,
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
                        '¿Cuál es tu altura?',
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
                        'Estos números ayudan a calibrar tu avatar.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Central icon (ruler/height) - now yellow
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
                          Icons.straighten,
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Height Picker (more compact)
                      ScrollPicker(
                        items: _heightOptions,
                        initialItem: _heightCm,
                        suffix: ' cm',
                        onSelectedItemChanged: _onHeightChanged,
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
