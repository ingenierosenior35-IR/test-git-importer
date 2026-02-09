import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/scroll_picker.dart';
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
  // Height in cm only
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
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Estos números ayudan a calibrar tu avatar.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Central icon (ruler/height)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF3C3C3C),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.straighten,
                          size: 40,
                          color: Color(0xFFCDFF4D),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Height Picker (minimalist design)
                      ScrollPicker(
                        items: _heightOptions,
                        initialItem: _heightCm,
                        suffix: ' cm',
                        onSelectedItemChanged: _onHeightChanged,
                        itemHeight: 40.0, // Reduced from default 50
                        visibleItemCount: 5,
                      ),

                      const SizedBox(height: 24),

                      // Display selected unit label
                      Text(
                        'Metros',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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
