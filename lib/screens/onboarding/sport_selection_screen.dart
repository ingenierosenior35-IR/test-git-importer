import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/sport_card.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'gender_selection_screen.dart';

class SportSelectionScreen extends StatefulWidget {
  const SportSelectionScreen({Key? key}) : super(key: key);

  @override
  State<SportSelectionScreen> createState() => _SportSelectionScreenState();
}

class _SportSelectionScreenState extends State<SportSelectionScreen> {
  final List<String> _selectedSports = [];
  static const int maxSportsSelection = 5;

  final List<Map<String, dynamic>> _sports = [
    {'name': 'Correr', 'icon': Icons.directions_run},
    {'name': 'Trail Running', 'icon': Icons.hiking},
    {'name': 'Baloncesto', 'icon': Icons.sports_basketball},
    {'name': 'Béisbol', 'icon': Icons.sports_baseball},
    {'name': 'Patinaje', 'icon': Icons.roller_skating},
    {'name': 'Voleibol', 'icon': Icons.sports_volleyball},
    {'name': 'Natación', 'icon': Icons.pool},
    {'name': 'Escalada', 'icon': Icons.landscape},
    {'name': 'Fútbol', 'icon': Icons.sports_soccer},
    {'name': 'Tenis', 'icon': Icons.sports_tennis},
    {'name': 'Ciclismo', 'icon': Icons.directions_bike},
    {'name': 'Yoga', 'icon': Icons.self_improvement},
  ];

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final authService = Get.find<AuthService>();
      final onboardingCompleted = await authService.checkOnboardingStatus();
      
      if (onboardingCompleted && mounted) {
        debugPrint('✅ Onboarding already completed, redirecting to home');
        Get.offAllNamed(AppRoutes.homeContainerScreen);
      }
    } catch (e) {
      debugPrint('⚠️ Error checking onboarding status: $e');
    }
  }

  void _toggleSport(String sport) {
    setState(() {
      if (_selectedSports.contains(sport)) {
        _selectedSports.remove(sport);
      } else {
        if (_selectedSports.length < maxSportsSelection) {
          _selectedSports.add(sport);
        } else {
          Get.snackbar(
            'Límite alcanzado',
            'Puedes seleccionar hasta $maxSportsSelection deportes',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    });
  }

  void _continue() {
    if (_selectedSports.isEmpty) {
      Get.snackbar(
        'Selección requerida',
        'Por favor selecciona al menos un deporte',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    debugPrint('🔵 Selected sports: $_selectedSports');
    Get.to(() => GenderSelectionScreen(selectedSports: _selectedSports));
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        '¿Cuál es tu juego?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      const Text(
                        'Elige tu cancha.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Info text
                      Text(
                        'Puedes seleccionar hasta $maxSportsSelection',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Sports grid (2 columns with large square cards)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,  
                          crossAxisSpacing: 12,  
                          mainAxisSpacing: 12,  
                          childAspectRatio: 1.0, 
                        ),
                        itemCount: _sports.length,
                        itemBuilder: (context, index) {
                          final sport = _sports[index];
                          final isSelected = _selectedSports.contains(sport['name']);

                          return SportCard(
                            label: sport['name'],
                            icon: sport['icon'],
                            isSelected: isSelected,
                            onTap: () => _toggleSport(sport['name']),
                          );
                        },
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
}