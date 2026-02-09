import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button.dart';
import 'height_screen.dart';

class GenderSelectionScreen extends StatefulWidget {
  final List<String> selectedSports;

  const GenderSelectionScreen({
    Key? key,
    required this.selectedSports,
  }) : super(key: key);

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  final List<Map<String, dynamic>> _genders = [
    {
      'name': 'Male',
      'icon': Icons.male,
      'label': 'Masculino',
    },
    {
      'name': 'Female',
      'icon': Icons.female,
      'label': 'Femenino',
    },
    {
      'name': 'Other',
      'icon': Icons.person_outline,
      'label': 'Prefiero no decir',
    },
  ];

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _continue() {
    if (_selectedGender == null) {
      // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona tu género'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Get.to(() => HeightScreen(
      selectedSports: widget.selectedSports,
      selectedGender: _selectedGender!,
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
                        '¿Cómo compites?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Central avatar icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF3C3C3C),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          size: 48,
                          color: Color(0xFFCDFF4D),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Gender buttons - All 3 in a single horizontal row
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderButton(_genders[0]), // Male
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGenderButton(_genders[1]), // Female
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGenderButton(_genders[2]), // Prefer not to say
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Helper text
                      Text(
                        'Esto ayuda a calibrar tu avatar.',
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

  Widget _buildGenderButton(Map<String, dynamic> gender) {
    final isSelected = _selectedGender == gender['name'];
    
    return GestureDetector(
      onTap: () => _selectGender(gender['name']),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFCDFF4D).withOpacity(0.15)
              : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFCDFF4D)
                : const Color(0xFF3C3C3C),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFCDFF4D)
                    : const Color(0xFF3C3C3C),
                shape: BoxShape.circle,
              ),
              child: Icon(
                gender['icon'],
                size: 28,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Label
            Text(
              gender['label'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFFCDFF4D) : Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
