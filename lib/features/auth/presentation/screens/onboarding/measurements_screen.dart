import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/scroll_picker.dart';
import 'photo_upload_screen.dart';

class MeasurementsScreen extends StatefulWidget {
  final List<String> selectedSports;
  final String selectedGender;

  const MeasurementsScreen({
    Key? key,
    required this.selectedSports,
    required this.selectedGender,
  }) : super(key: key);

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  // Weight
  String _weightUnit = 'kg';
  int _weightKg = 70;
  
  // Height  
  int _heightCm = 170;

  // Generate weight options based on unit
  List<int> get _weightOptions {
    if (_weightUnit == 'kg') {
      return List.generate(171, (index) => 30 + index); // 30-200 kg
    } else {
      return List.generate(376, (index) => 66 + index); // 66-440 lbs (30-200 kg converted)
    }
  }
  
  // Generate height options (100-250 cm for inclusivity)
  List<int> get _heightOptions => List.generate(151, (index) => 100 + index);
  
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
    // Prepare data
    Map<String, dynamic> height = {
      'value': _heightCm.toDouble(),
      'unit': 'cm',
    };

    Map<String, dynamic> weight = {
      'value': _weightKg.toDouble(),
      'unit': 'kg',
    };

    Get.to(() => PhotoUploadScreen(
      selectedSports: widget.selectedSports,
      selectedGender: widget.selectedGender,
      height: height,
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
                        'Tus atributos de juego',
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

                      const SizedBox(height: 32),

                      // Central icon (balance/scale)
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

                      const SizedBox(height: 40),

                      // Weight Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "What's your weight",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Weight Picker
                      ScrollPicker(
                        items: _weightOptions,
                        initialItem: _currentWeight,
                        suffix: _weightUnit == 'kg' ? ' kg' : ' lb',
                        onSelectedItemChanged: _onWeightChanged,
                      ),

                      const SizedBox(height: 16),

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

                      // Height Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Altura',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Height Picker
                      ScrollPicker(
                        items: _heightOptions,
                        initialItem: _heightCm,
                        suffix: ' cm',
                        onSelectedItemChanged: (value) {
                          setState(() {
                            _heightCm = value;
                          });
                        },
                      ),

                      const SizedBox(height: 32),

                      // Microcopy
                      Text(
                        'Cada jugador tiene sus números.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: CustomButton(
                text: 'Continue',
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
        width: 60,
        height: 60,
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
