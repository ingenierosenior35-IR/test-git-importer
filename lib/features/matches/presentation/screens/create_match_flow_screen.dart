import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/match_model.dart';
import '../../data/datasources/matches_mock_data.dart';
import '../../../teams/data/models/team_model.dart';
import '../../../teams/data/datasources/teams_mock_data.dart';
import '../../../courts/data/models/court_model.dart';
import '../../../courts/data/datasources/courts_mock_data.dart';

class CreateMatchFlowScreen extends StatefulWidget {
  const CreateMatchFlowScreen({Key? key}) : super(key: key);

  @override
  State<CreateMatchFlowScreen> createState() => _CreateMatchFlowScreenState();
}

class _CreateMatchFlowScreenState extends State<CreateMatchFlowScreen> {
  int _currentStep = 0;
  
  MatchType _selectedMatchType = MatchType.local;
  Team? _selectedHomeTeam;
  Team? _selectedAwayTeam;
  final _matchNameController = TextEditingController();
  Court? _selectedCourt;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  List<Team> _teams = [];
  List<Court> _courts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _teams = TeamsMockData.getAllTeams();
      _courts = CourtsMockData.getAllCourts();
    });
  }

  @override
  void dispose() {
    _matchNameController.dispose();
    super.dispose();
  }

  void _createMatch() {
    try {
      final matchDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newMatch = Match(
        id: 'match${DateTime.now().millisecondsSinceEpoch}',
        name: _matchNameController.text.trim(),
        dateTime: matchDateTime,
        venue: _selectedCourt?.name,
        matchType: _selectedMatchType,
        status: MatchStatus.upcoming,
        homeTeamId: _selectedHomeTeam?.id,
        awayTeamId: _selectedAwayTeam?.id,
        createdBy: 'user1',
        createdAt: DateTime.now(),
      );

      MatchesMockData.addMatch(newMatch);

      Get.back();
      Get.snackbar(
        'Éxito',
        'Partido creado correctamente',
        backgroundColor: AppColors.kGreen.withOpacity(0.8),
        colorText: AppColors.kWhite,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el partido',
        backgroundColor: AppColors.kRed.withOpacity(0.8),
        colorText: AppColors.kWhite,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        if (_selectedMatchType == MatchType.versus) {
          return _selectedHomeTeam != null && _selectedAwayTeam != null;
        }
        return true;
      case 2:
        return _matchNameController.text.trim().isNotEmpty;
      case 3:
        return _selectedCourt != null;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_canContinue()) {
      if (_currentStep < 5) {
        setState(() {
          _currentStep++;
        });
      } else {
        _createMatch();
      }
    } else {
      Get.snackbar(
        'Atención',
        'Completa todos los campos requeridos',
        backgroundColor: AppColors.kOrange.withOpacity(0.8),
        colorText: AppColors.kWhite,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
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
        title: const Text(
          'Crear Partido',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: AppColors.kDarkCard,
      child: Row(
        children: List.generate(6, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent 
                          ? AppColors.kYellowAccent 
                          : AppColors.kGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 5)
                  const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildMatchTypeStep();
      case 1:
        return _buildTeamSelectionStep();
      case 2:
        return _buildMatchNameStep();
      case 3:
        return _buildCourtSelectionStep();
      case 4:
        return _buildDateTimeStep();
      case 5:
        return _buildConfirmationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMatchTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Partido',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona el tipo de partido que deseas crear',
          style: TextStyle(
            color: AppColors.kGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        _buildMatchTypeCard(
          MatchType.local,
          'Partido Local',
          'Entre amigos sin equipos registrados',
          Icons.people,
        ),
        const SizedBox(height: 16),
        _buildMatchTypeCard(
          MatchType.versus,
          'Partido Versus',
          'Entre equipos registrados',
          Icons.shield,
        ),
      ],
    );
  }

  Widget _buildMatchTypeCard(
    MatchType type,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedMatchType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMatchType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.kYellowAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.kYellowAccent.withOpacity(isSelected ? 0.3 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.kYellowAccent,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.kGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.kYellowAccent,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelectionStep() {
    if (_selectedMatchType == MatchType.local) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Equipos',
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No es necesario seleccionar equipos para un partido local',
            style: TextStyle(
              color: AppColors.kGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.kDarkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.people,
                  size: 80,
                  color: AppColors.kYellowAccent.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Partido entre amigos',
                  style: TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los jugadores se agregarán directamente al partido',
                  style: TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar Equipos',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona el equipo local y visitante',
          style: TextStyle(
            color: AppColors.kGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Equipo Local',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildTeamDropdown(_selectedHomeTeam, (team) {
          setState(() {
            _selectedHomeTeam = team;
          });
        }),
        const SizedBox(height: 24),
        const Text(
          'Equipo Visitante',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildTeamDropdown(_selectedAwayTeam, (team) {
          setState(() {
            _selectedAwayTeam = team;
          });
        }),
      ],
    );
  }

  Widget _buildTeamDropdown(Team? selectedTeam, Function(Team?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Team>(
          value: selectedTeam,
          isExpanded: true,
          hint: const Text(
            'Selecciona un equipo',
            style: TextStyle(color: AppColors.kGrey),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.kYellowAccent),
          dropdownColor: AppColors.kDarkCard,
          style: const TextStyle(color: AppColors.kWhite, fontSize: 16),
          items: _teams.map((Team team) {
            return DropdownMenuItem<Team>(
              value: team,
              child: Row(
                children: [
                  const Icon(Icons.shield, color: AppColors.kYellowAccent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(team.name),
                  ),
                  Text(
                    team.sport,
                    style: TextStyle(
                      color: AppColors.kGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMatchNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre del Partido',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Dale un nombre descriptivo a tu partido',
          style: TextStyle(
            color: AppColors.kGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _matchNameController,
          style: const TextStyle(color: AppColors.kWhite),
          decoration: InputDecoration(
            labelText: 'Nombre del Partido',
            labelStyle: const TextStyle(color: AppColors.kGrey),
            hintText: _selectedMatchType == MatchType.versus
                ? '${_selectedHomeTeam?.name ?? "Equipo Local"} vs ${_selectedAwayTeam?.name ?? "Equipo Visitante"}'
                : 'Partido de Amigos',
            hintStyle: TextStyle(color: AppColors.kGrey.withOpacity(0.5)),
            filled: true,
            fillColor: AppColors.kDarkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.sports_soccer, color: AppColors.kYellowAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildCourtSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar Cancha',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Elige dónde se jugará el partido',
          style: TextStyle(
            color: AppColors.kGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _courts.length,
          itemBuilder: (context, index) {
            return _buildCourtCard(_courts[index]);
          },
        ),
      ],
    );
  }

  Widget _buildCourtCard(Court court) {
    final isSelected = _selectedCourt?.id == court.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCourt = court;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.kYellowAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    court.name,
                    style: const TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.kYellowAccent,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.kGrey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    court.address,
                    style: TextStyle(
                      color: AppColors.kGrey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.kYellowAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    court.surfaceType,
                    style: const TextStyle(
                      color: AppColors.kYellowAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '€${court.pricePerHour.toStringAsFixed(0)}/hora',
                  style: const TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha y Hora',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cuándo se jugará el partido',
          style: TextStyle(
            color: AppColors.kGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: _selectDate,
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
                      Text(
                        'Fecha',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.kGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMMM yyyy', 'es').format(_selectedDate),
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
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.kDarkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.kYellowAccent,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hora',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.kGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedTime.format(context),
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
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
        _selectedTime = picked;
      });
    }
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirmación',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Revisa los detalles del partido antes de crear',
          style: TextStyle(
            color: AppColors.kGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        _buildConfirmationCard(
          'Tipo de Partido',
          _selectedMatchType == MatchType.local ? 'Local' : 'Versus',
          Icons.sports_soccer,
        ),
        if (_selectedMatchType == MatchType.versus) ...[
          const SizedBox(height: 12),
          _buildConfirmationCard(
            'Equipos',
            '${_selectedHomeTeam?.name ?? "N/A"} vs ${_selectedAwayTeam?.name ?? "N/A"}',
            Icons.shield,
          ),
        ],
        const SizedBox(height: 12),
        _buildConfirmationCard(
          'Nombre',
          _matchNameController.text.trim(),
          Icons.label,
        ),
        const SizedBox(height: 12),
        _buildConfirmationCard(
          'Cancha',
          _selectedCourt?.name ?? 'No seleccionada',
          Icons.place,
        ),
        const SizedBox(height: 12),
        _buildConfirmationCard(
          'Fecha y Hora',
          '${DateFormat('dd/MM/yyyy').format(_selectedDate)} - ${_selectedTime.format(context)}',
          Icons.event,
        ),
      ],
    );
  }

  Widget _buildConfirmationCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.kYellowAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.kBlack.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.kYellowAccent),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Anterior',
                  style: TextStyle(
                    color: AppColors.kYellowAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0)
            const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _canContinue() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kYellowAccent,
                foregroundColor: AppColors.kBlack,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: AppColors.kGrey.withOpacity(0.3),
              ),
              child: Text(
                _currentStep == 5 ? 'Crear Partido' : 'Siguiente',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
