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
  // Height
  String _heightUnit = 'cm';
  int _heightCm = 170;

  // Generate height options (100-250 cm for inclusivity)
  List<int> get _heightOptions => List.generate(151, (index) => 100 + index);

  // Get current height value in the selected unit
  int get _currentHeight {
    if (_heightUnit == 'cm') {
      return _heightCm;
    } else {
      // Convert cm to feet/inches (displayed as total inches)
      return (_heightCm / 2.54).round();
    }
  }

  void _toggleHeightUnit() {
    setState(() {
      if (_heightUnit == 'cm') {
        _heightUnit = 'ft';
      } else {
        _heightUnit = 'cm';
      }
    });
  }

  void _onHeightChanged(int value) {
    setState(() {
      if (_heightUnit == 'cm') {
        _heightCm = value;
      } else {
        _heightCm = (value * 2.54).round(); // Convert inches to cm
      }
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
                        child: Icon(
                          Icons.straighten,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Height Picker
                      ScrollPicker(
                        items: _heightOptions,
                        initialItem: _currentHeight,
                        suffix: _heightUnit == 'cm' ? ' cm' : ' in',
                        onSelectedItemChanged: _onHeightChanged,
                      ),

                      const SizedBox(height: 24),

                      // Cm/Ft Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildUnitToggle('Metros', _heightUnit == 'cm'),
                          const SizedBox(width: 12),
                          _buildUnitToggle('Pies', _heightUnit == 'ft'),
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
      onTap: _toggleHeightUnit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFCDFF4D) 
              : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFCDFF4D) 
                : const Color(0xFF3C3C3C),
            width: 2,
          ),
        ),
        child: Text(
          unit,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
