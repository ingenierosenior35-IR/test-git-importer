import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/scroll_picker.dart';
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
  // Weight
  String _weightUnit = 'kg';
  int _weightKg = 70;

  // Generate weight options based on unit
  List<int> get _weightOptions {
    if (_weightUnit == 'kg') {
      return List.generate(171, (index) => 30 + index); // 30-200 kg
    } else {
      return List.generate(376, (index) => 66 + index); // 66-440 lbs (30-200 kg converted)
    }
  }

  // Get current weight value in the selected unit
  int get _currentWeight {
    if (_weightUnit == 'kg') {
      return _weightKg;
    } else {
      return (_weightKg * 2.20462).round(); // Convert kg to lbs
    }
  }

  void _toggleWeightUnit() {
    setState(() {
      if (_weightUnit == 'kg') {
        _weightUnit = 'lb';
      } else {
        _weightUnit = 'kg';
      }
    });
  }

  void _onWeightChanged(int value) {
    setState(() {
      if (_weightUnit == 'kg') {
        _weightKg = value;
      } else {
        _weightKg = (value / 2.20462).round(); // Convert lbs to kg
      }
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
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Cada jugador tiene sus números.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Central icon (scale/weight)
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
                          Icons.monitor_weight_outlined,
                          size: 40,
                          color: Color(0xFFCDFF4D),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Weight Picker (minimalist design)
                      ScrollPicker(
                        items: _weightOptions,
                        initialItem: _currentWeight,
                        suffix: _weightUnit == 'kg' ? ' kg' : ' lb',
                        onSelectedItemChanged: _onWeightChanged,
                        itemHeight: 40.0, // Reduced from default 50
                        visibleItemCount: 5,
                      ),

                      const SizedBox(height: 24),

                      // Kg/Lb Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildUnitToggle('Kg', _weightUnit == 'kg'),
                          const SizedBox(width: 12),
                          _buildUnitToggle('Lb', _weightUnit == 'lb'),
                        ],
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

  Widget _buildUnitToggle(String unit, bool isSelected) {
    return GestureDetector(
      onTap: _toggleWeightUnit,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFCDFF4D) 
              : const Color(0xFF2C2C2C),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFCDFF4D) 
                : const Color(0xFF3C3C3C),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            unit,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
