import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/match_model.dart';
import '../../../teams/data/models/team_model.dart';

class MatchDetailInfoScreen extends StatefulWidget {
  const MatchDetailInfoScreen({Key? key}) : super(key: key);

  @override
  State<MatchDetailInfoScreen> createState() => _MatchDetailInfoScreenState();
}

class _MatchDetailInfoScreenState extends State<MatchDetailInfoScreen> {
  Match? match;
  Team? homeTeam;
  Team? awayTeam;

  @override
  void initState() {
    super.initState();
    match = Get.arguments as Match?;
    if (match != null) {
      _loadTeams();
    }
  }

  void _loadTeams() {
    // Teams are Firestore objects; we don't have a sync lookup.
    // The match stores team IDs; team names can be shown from the match data.
    homeTeam = null;
    awayTeam = null;
  }

  @override
  Widget build(BuildContext context) {
    if (match == null) {
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
            'Detalle del Partido',
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'No se encontró información del partido',
            style: TextStyle(color: AppColors.kWhite),
          ),
        ),
      );
    }

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
          'Detalle del Partido',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.kYellowAccent),
            onPressed: _editMatch,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMatchHeader(),
              const SizedBox(height: 24),
              _buildMatchInfo(),
              const SizedBox(height: 24),
              if (match!.matchType == MatchType.versus) ...[
                _buildTeamsInfo(),
                const SizedBox(height: 24),
              ],
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(),
              style: TextStyle(
                color: _getStatusColor(),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            match!.name,
            style: const TextStyle(
              color: AppColors.kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getMatchTypeText(),
            style: TextStyle(
              color: AppColors.kGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          Icons.event,
          'Fecha',
          DateFormat('EEEE, dd MMMM yyyy', 'es').format(match!.dateTime),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          Icons.access_time,
          'Hora',
          DateFormat('HH:mm').format(match!.dateTime),
        ),
        if (match!.venue != null) ...[
          const SizedBox(height: 12),
          _buildInfoCard(
            Icons.place,
            'Cancha',
            match!.venue!,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
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

  Widget _buildTeamsInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Equipos',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTeamCard(homeTeam, 'Local'),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kDarkCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'VS',
                style: TextStyle(
                  color: AppColors.kYellowAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTeamCard(awayTeam, 'Visitante'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamCard(Team? team, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.kGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.kYellowAccent.withOpacity(0.2),
            child: team?.logoUrl != null
                ? ClipOval(
                    child: Image.network(
                      team!.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          team.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.kYellowAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  )
                : Text(
                    team?.name[0].toUpperCase() ?? 'T',
                    style: const TextStyle(
                      color: AppColors.kYellowAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            team?.name ?? 'Sin asignar',
            style: const TextStyle(
              color: AppColors.kWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startMatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kYellowAccent,
              foregroundColor: AppColors.kBlack,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Iniciar Partido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _cancelMatch,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.kRed,
              side: const BorderSide(color: AppColors.kRed),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancelar Partido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    switch (match!.status) {
      case MatchStatus.upcoming:
        return 'PRÓXIMO';
      case MatchStatus.ongoing:
        return 'EN CURSO';
      case MatchStatus.completed:
        return 'FINALIZADO';
      case MatchStatus.cancelled:
        return 'CANCELADO';
    }
  }

  Color _getStatusColor() {
    switch (match!.status) {
      case MatchStatus.upcoming:
        return AppColors.kYellowAccent;
      case MatchStatus.ongoing:
        return AppColors.kGreen;
      case MatchStatus.completed:
        return AppColors.kBlue;
      case MatchStatus.cancelled:
        return AppColors.kRed;
    }
  }

  String _getMatchTypeText() {
    switch (match!.matchType) {
      case MatchType.local:
        return 'Partido Local - Entre amigos';
      case MatchType.versus:
        return 'Partido Versus - Entre equipos';
    }
  }

  void _editMatch() {
    Get.snackbar(
      'Próximamente',
      'Función de editar partido en desarrollo',
      backgroundColor: AppColors.kDarkCard,
      colorText: AppColors.kWhite,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _startMatch() {
    Get.snackbar(
      'Próximamente',
      'Función de iniciar partido en desarrollo',
      backgroundColor: AppColors.kDarkCard,
      colorText: AppColors.kWhite,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _cancelMatch() {
    Get.defaultDialog(
      title: 'Cancelar Partido',
      titleStyle: const TextStyle(color: AppColors.kWhite),
      backgroundColor: AppColors.kDarkCard,
      middleText: '¿Estás seguro de que deseas cancelar este partido?',
      middleTextStyle: const TextStyle(color: AppColors.kGrey),
      textCancel: 'No',
      textConfirm: 'Sí, Cancelar',
      cancelTextColor: AppColors.kWhite,
      confirmTextColor: AppColors.kBlack,
      buttonColor: AppColors.kRed,
      onConfirm: () {
        Get.back();
        Get.back();
        Get.snackbar(
          'Partido Cancelado',
          'El partido ha sido cancelado',
          backgroundColor: AppColors.kRed.withOpacity(0.8),
          colorText: AppColors.kWhite,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
