import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/tournament_model.dart';
import '../../data/datasources/tournaments_mock_data.dart';

class TournamentFormScreen extends StatefulWidget {
  const TournamentFormScreen({Key? key}) : super(key: key);

  @override
  State<TournamentFormScreen> createState() => _TournamentFormScreenState();
}

class _TournamentFormScreenState extends State<TournamentFormScreen> {
  static const int _minTeams = 2;
  
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _sportController;
  late final TextEditingController _maxTeamsController;
  late final TextEditingController _locationController;
  late final TextEditingController _pointsWinController;
  late final TextEditingController _pointsDrawController;
  
  TournamentFormat _selectedFormat = TournamentFormat.league;
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime? _endDate;
  bool _isPublic = true;
  bool _isLoading = false;
  
  Tournament? _editingTournament;
  bool get _isEditMode => _editingTournament != null;

  @override
  void initState() {
    super.initState();
    
    _editingTournament = Get.arguments as Tournament?;
    
    _nameController = TextEditingController(text: _editingTournament?.name ?? '');
    _descriptionController = TextEditingController(text: _editingTournament?.description ?? '');
    _sportController = TextEditingController(text: _editingTournament?.sport ?? 'Fútbol');
    _maxTeamsController = TextEditingController(
      text: (_editingTournament?.maxTeams ?? 8).toString(),
    );
    _locationController = TextEditingController(text: _editingTournament?.location ?? '');
    _pointsWinController = TextEditingController(
      text: (_editingTournament?.pointsForWin ?? 3).toString(),
    );
    _pointsDrawController = TextEditingController(
      text: (_editingTournament?.pointsForDraw ?? 1).toString(),
    );
    
    if (_editingTournament != null) {
      _selectedFormat = _editingTournament!.format;
      _startDate = _editingTournament!.startDate;
      _endDate = _editingTournament!.endDate;
      _isPublic = _editingTournament!.isPublic;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sportController.dispose();
    _maxTeamsController.dispose();
    _locationController.dispose();
    _pointsWinController.dispose();
    _pointsDrawController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.kYellowAccent,
              onPrimary: AppColors.kBlack,
              surface: AppColors.kDarkCard,
              onSurface: AppColors.kWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.kYellowAccent,
              onPrimary: AppColors.kBlack,
              surface: AppColors.kDarkCard,
              onSurface: AppColors.kWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _clearEndDate() {
    setState(() {
      _endDate = null;
    });
  }

  Future<void> _saveTournament() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tournamentId = _editingTournament?.id ?? 
          'tournament_${DateTime.now().microsecondsSinceEpoch}_${DateTime.now().millisecondsSinceEpoch % 1000}';
      
      final tournament = Tournament(
        id: tournamentId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        format: _selectedFormat,
        status: _editingTournament?.status ?? TournamentStatus.upcoming,
        startDate: _startDate,
        endDate: _endDate,
        sport: _sportController.text.trim(),
        maxTeams: int.parse(_maxTeamsController.text),
        currentTeams: _editingTournament?.currentTeams ?? 0,
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        createdBy: _editingTournament?.createdBy ?? 'user1', // TODO: Replace with actual authenticated user ID
        createdAt: _editingTournament?.createdAt ?? DateTime.now(),
        pointsForWin: int.parse(_pointsWinController.text),
        pointsForDraw: int.parse(_pointsDrawController.text),
        pointsForLoss: 0,
        isPublic: _isPublic,
        joinCode: _editingTournament?.joinCode,
      );

      if (_isEditMode) {
        TournamentsMockData.updateTournament(tournament);
      } else {
        TournamentsMockData.addTournament(tournament);
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        _isEditMode 
            ? 'Torneo actualizado correctamente' 
            : 'Torneo creado correctamente',
        backgroundColor: AppColors.kGreen.withOpacity(0.8),
        colorText: AppColors.kWhite,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo ${_isEditMode ? "actualizar" : "crear"} el torneo',
        backgroundColor: AppColors.kRed.withOpacity(0.8),
        colorText: AppColors.kWhite,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          _isEditMode ? 'Editar Torneo' : 'Crear Torneo',
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
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.kWhite),
                  decoration: InputDecoration(
                    labelText: 'Nombre del torneo *',
                    labelStyle: const TextStyle(color: AppColors.kGrey),
                    filled: true,
                    fillColor: AppColors.kDarkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el nombre del torneo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: AppColors.kWhite),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: const TextStyle(color: AppColors.kGrey),
                    filled: true,
                    fillColor: AppColors.kDarkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.kDarkCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<TournamentFormat>(
                    value: _selectedFormat,
                    dropdownColor: AppColors.kDarkCard,
                    style: const TextStyle(color: AppColors.kWhite),
                    decoration: const InputDecoration(
                      labelText: 'Formato',
                      labelStyle: TextStyle(color: AppColors.kGrey),
                      border: InputBorder.none,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: TournamentFormat.league,
                        child: Text('Liga'),
                      ),
                      DropdownMenuItem(
                        value: TournamentFormat.knockout,
                        child: Text('Eliminación'),
                      ),
                      DropdownMenuItem(
                        value: TournamentFormat.groupsAndKnockout,
                        child: Text('Grupos + Eliminación'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFormat = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _sportController,
                  style: const TextStyle(color: AppColors.kWhite),
                  decoration: InputDecoration(
                    labelText: 'Deporte',
                    labelStyle: const TextStyle(color: AppColors.kGrey),
                    filled: true,
                    fillColor: AppColors.kDarkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _maxTeamsController,
                  style: const TextStyle(color: AppColors.kWhite),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Número máximo de equipos',
                    labelStyle: const TextStyle(color: AppColors.kGrey),
                    filled: true,
                    fillColor: AppColors.kDarkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el número máximo de equipos';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < _minTeams) {
                      return 'Mínimo $_minTeams equipos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                InkWell(
                  onTap: _selectStartDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.kDarkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.kYellowAccent,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fecha de inicio *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.kGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd/MM/yyyy').format(_startDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.kWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.kGrey,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                InkWell(
                  onTap: _selectEndDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.kDarkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_rounded,
                          color: AppColors.kYellowAccent,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fecha de fin (opcional)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.kGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _endDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                    : 'Sin fecha de fin',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _endDate != null 
                                      ? AppColors.kWhite 
                                      : AppColors.kGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_endDate != null)
                          IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: AppColors.kRed,
                              size: 20,
                            ),
                            onPressed: _clearEndDate,
                          )
                        else
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.kGrey,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _locationController,
                  style: const TextStyle(color: AppColors.kWhite),
                  decoration: InputDecoration(
                    labelText: 'Ubicación',
                    labelStyle: const TextStyle(color: AppColors.kGrey),
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: AppColors.kYellowAccent,
                    ),
                    filled: true,
                    fillColor: AppColors.kDarkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'Reglas de puntuación',
                  style: TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pointsWinController,
                        style: const TextStyle(color: AppColors.kWhite),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Puntos por victoria',
                          labelStyle: const TextStyle(color: AppColors.kGrey),
                          filled: true,
                          fillColor: AppColors.kDarkCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          final number = int.tryParse(value);
                          if (number == null || number < 0) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _pointsDrawController,
                        style: const TextStyle(color: AppColors.kWhite),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Puntos por empate',
                          labelStyle: const TextStyle(color: AppColors.kGrey),
                          filled: true,
                          fillColor: AppColors.kDarkCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          final number = int.tryParse(value);
                          if (number == null || number < 0) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.kDarkCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.public,
                        color: AppColors.kYellowAccent,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Torneo público',
                              style: TextStyle(
                                color: AppColors.kWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isPublic
                                  ? 'Cualquier equipo puede unirse'
                                  : 'Solo por invitación',
                              style: const TextStyle(
                                color: AppColors.kGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isPublic,
                        activeColor: AppColors.kYellowAccent,
                        onChanged: (value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTournament,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kYellowAccent,
                      foregroundColor: AppColors.kBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.kBlack,
                              ),
                            ),
                          )
                        : Text(
                            _isEditMode ? 'Actualizar Torneo' : 'Crear Torneo',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
