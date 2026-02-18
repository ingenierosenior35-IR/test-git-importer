import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/team_model.dart';
import '../../data/datasources/teams_mock_data.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({Key? key}) : super(key: key);

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedSport = 'Fútbol';
  final List<String> _sports = ['Fútbol', 'Baloncesto', 'Voleibol', 'Tenis', 'Pádel'];
  
  Team? _existingTeam;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _existingTeam = Get.arguments as Team?;
    if (_existingTeam != null) {
      _isEditMode = true;
      _nameController.text = _existingTeam!.name;
      _descriptionController.text = _existingTeam!.description ?? '';
      _selectedSport = _existingTeam!.sport;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTeam() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      if (_isEditMode && _existingTeam != null) {
        final updatedTeam = _existingTeam!.copyWith(
          name: _nameController.text.trim(),
          sport: _selectedSport,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
        );
        TeamsMockData.updateTeam(updatedTeam);
        
        Get.back();
        Get.snackbar(
          'Éxito',
          'Equipo actualizado correctamente',
          backgroundColor: AppColors.kGreen.withOpacity(0.8),
          colorText: AppColors.kWhite,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final inviteCode = TeamsMockData.generateInviteCode(_nameController.text.trim());
        
        final newTeam = Team(
          id: 'team${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          sport: _selectedSport,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          creatorId: 'user1',
          createdAt: DateTime.now(),
          playerIds: [],
          inviteCode: inviteCode,
        );
        
        TeamsMockData.addTeam(newTeam);
        
        Get.back();
        Get.snackbar(
          'Éxito',
          'Equipo creado correctamente',
          backgroundColor: AppColors.kGreen.withOpacity(0.8),
          colorText: AppColors.kWhite,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar el equipo',
        backgroundColor: AppColors.kRed.withOpacity(0.8),
        colorText: AppColors.kWhite,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _isEditMode ? 'Editar Equipo' : 'Crear Equipo',
          style: const TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogoSection(),
                const SizedBox(height: 24),
                const Text(
                  'Información del Equipo',
                  style: TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.kWhite),
                  decoration: InputDecoration(
                    labelText: 'Nombre del Equipo',
                    labelStyle: const TextStyle(color: AppColors.kGrey),
                    hintText: 'Los Tigres FC',
                    hintStyle: TextStyle(color: AppColors.kGrey.withOpacity(0.5)),
                    filled: true,
                    fillColor: AppColors.kDarkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.shield, color: AppColors.kYellowAccent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el nombre del equipo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Deporte',
                  style: TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.kDarkCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSport,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.kYellowAccent),
                      dropdownColor: AppColors.kDarkCard,
                      style: const TextStyle(color: AppColors.kWhite, fontSize: 16),
                      items: _sports.map((String sport) {
                        return DropdownMenuItem<String>(
                          value: sport,
                          child: Row(
                            children: [
                              Icon(
                                _getSportIcon(sport),
                                color: AppColors.kYellowAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(sport),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSport = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: AppColors.kWhite),
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Descripción (Opcional)',
                    labelStyle: const TextStyle(color: AppColors.kGrey),
                    hintText: 'Equipo de amigos del barrio...',
                    hintStyle: TextStyle(color: AppColors.kGrey.withOpacity(0.5)),
                    filled: true,
                    fillColor: AppColors.kDarkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTeam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kYellowAccent,
                      foregroundColor: AppColors.kBlack,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isEditMode ? 'Guardar Cambios' : 'Crear Equipo',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.kYellowAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.kYellowAccent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.shield,
              color: AppColors.kYellowAccent,
              size: 60,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              Get.snackbar(
                'Próximamente',
                'Función de subir logo en desarrollo',
                backgroundColor: AppColors.kOrange.withOpacity(0.8),
                colorText: AppColors.kWhite,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.camera_alt, color: AppColors.kYellowAccent, size: 20),
            label: const Text(
              'Agregar Logo',
              style: TextStyle(
                color: AppColors.kYellowAccent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'Fútbol':
        return Icons.sports_soccer;
      case 'Baloncesto':
        return Icons.sports_basketball;
      case 'Voleibol':
        return Icons.sports_volleyball;
      case 'Tenis':
        return Icons.sports_tennis;
      case 'Pádel':
        return Icons.sports_handball;
      default:
        return Icons.sports;
    }
  }
}
