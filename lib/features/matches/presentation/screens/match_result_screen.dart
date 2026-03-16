import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/match_model.dart';
import '../../../teams/data/models/team_model.dart';
import '../../../teams/data/models/player_model.dart';

class MatchResultScreen extends StatefulWidget {
  const MatchResultScreen({Key? key}) : super(key: key);

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  Match? match;
  List<MatchEvent> events = [];
  Team? homeTeam;
  Team? awayTeam;
  Player? mvpPlayer;

  @override
  void initState() {
    super.initState();
    match = Get.arguments as Match?;
    if (match != null) {
      _loadMatchData();
    }
  }

  void _loadMatchData() {
    setState(() {
      events = [];
      homeTeam = null;
      awayTeam = null;
      mvpPlayer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (match == null) {
      return Scaffold(
        backgroundColor: AppColors.kDarkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.kDarkCard,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.kWhite),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: Text(
            'Partido no encontrado',
            style: TextStyle(color: AppColors.kWhite),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.kBlack,
      appBar: AppBar(
        backgroundColor: AppColors.kBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
        title: Text(
          match!.name,
          style: const TextStyle(
            color: AppColors.kWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.kWhite),
            onPressed: () {
              Get.snackbar(
                'Compartir',
                'Función de compartir en desarrollo',
                backgroundColor: AppColors.kOrange.withOpacity(0.8),
                colorText: AppColors.kWhite,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (match!.videoThumbnail != null) _buildVideoSection(),
            _buildScoreSection(),
            if (mvpPlayer != null) _buildMVPSection(),
            _buildTimelineSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppColors.kBlack,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            match!.videoThumbnail!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.kDarkCard,
                child: Icon(
                  Icons.videocam_off,
                  size: 60,
                  color: AppColors.kGrey.withOpacity(0.5),
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.kBlack.withOpacity(0.3),
                  AppColors.kBlack.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.kYellowAccent.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.kBlack,
                size: 40,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.kBlack.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Highlights',
                style: TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.kDarkBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.kGrey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'FINALIZADO',
            style: TextStyle(
              color: AppColors.kGrey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeamScore(
                homeTeam?.name ?? 'Equipo Local',
                match!.homeScore ?? 0,
                homeTeam?.logoUrl,
                true,
              ),
              Column(
                children: [
                  Text(
                    'VS',
                    style: TextStyle(
                      color: AppColors.kGrey.withOpacity(0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.kDarkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getMatchResult(),
                      style: TextStyle(
                        color: _getMatchResultColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              _buildTeamScore(
                awayTeam?.name ?? 'Equipo Visitante',
                match!.awayScore ?? 0,
                awayTeam?.logoUrl,
                false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (match!.venue != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.place,
                  size: 16,
                  color: AppColors.kGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  match!.venue!,
                  style: TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamScore(String teamName, int score, String? logoUrl, bool isHome) {
    final isWinner = isHome 
        ? (match!.homeScore ?? 0) > (match!.awayScore ?? 0)
        : (match!.awayScore ?? 0) > (match!.homeScore ?? 0);
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.kDarkCard,
              shape: BoxShape.circle,
              border: isWinner
                  ? Border.all(color: AppColors.kYellowAccent, width: 3)
                  : null,
            ),
            child: logoUrl != null
                ? ClipOval(
                    child: Image.network(
                      logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.shield,
                          color: AppColors.kYellowAccent,
                          size: 40,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.shield,
                    color: AppColors.kYellowAccent,
                    size: 40,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            teamName,
            style: const TextStyle(
              color: AppColors.kWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            score.toString(),
            style: TextStyle(
              color: isWinner ? AppColors.kYellowAccent : AppColors.kWhite,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getMatchResult() {
    if (match!.homeScore == match!.awayScore) {
      return 'EMPATE';
    }
    return (match!.homeScore ?? 0) > (match!.awayScore ?? 0) 
        ? 'LOCAL GANA' 
        : 'VISITANTE GANA';
  }

  Color _getMatchResultColor() {
    if (match!.homeScore == match!.awayScore) {
      return AppColors.kOrange;
    }
    return AppColors.kGreen;
  }

  Widget _buildMVPSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.kYellowAccent.withOpacity(0.2),
            AppColors.kYellowAccent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.kYellowAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.kYellowAccent,
                width: 2,
              ),
            ),
            child: mvpPlayer!.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      mvpPlayer!.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            mvpPlayer!.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.kYellowAccent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      mvpPlayer!.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.kYellowAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: AppColors.kYellowAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'JUGADOR MVP',
                      style: TextStyle(
                        color: AppColors.kYellowAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  mvpPlayer!.name,
                  style: const TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (mvpPlayer!.position != null)
                  Text(
                    mvpPlayer!.position!,
                    style: TextStyle(
                      color: AppColors.kGrey,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (mvpPlayer!.stats != null)
            Column(
              children: [
                Text(
                  mvpPlayer!.stats!.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.kYellowAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rating',
                  style: TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.kYellowAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cronología del Partido',
                style: TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (events.isEmpty)
            _buildEmptyTimeline()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return _buildEventItem(events[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyTimeline() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline,
            size: 60,
            color: AppColors.kGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay eventos registrados',
            style: TextStyle(
              color: AppColors.kGrey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(MatchEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getEventColor(event.type).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getEventColor(event.type),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                event.minute.toString(),
                style: TextStyle(
                  color: _getEventColor(event.type),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.kDarkCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    event.eventIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.playerName ?? 'Desconocido',
                          style: const TextStyle(
                            color: AppColors.kWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getEventTypeLabel(event.type),
                          style: TextStyle(
                            color: AppColors.kGrey,
                            fontSize: 14,
                          ),
                        ),
                        if (event.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            event.description!,
                            style: TextStyle(
                              color: AppColors.kGreyLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEventColor(event.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${event.minute}'",
                      style: TextStyle(
                        color: _getEventColor(event.type),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(MatchEventType type) {
    switch (type) {
      case MatchEventType.goal:
      case MatchEventType.penalty:
        return AppColors.kGreen;
      case MatchEventType.yellowCard:
        return AppColors.kOrange;
      case MatchEventType.redCard:
      case MatchEventType.ownGoal:
        return AppColors.kRed;
      case MatchEventType.substitution:
        return AppColors.kYellowAccent;
    }
  }

  String _getEventTypeLabel(MatchEventType type) {
    switch (type) {
      case MatchEventType.goal:
        return 'Gol';
      case MatchEventType.yellowCard:
        return 'Tarjeta Amarilla';
      case MatchEventType.redCard:
        return 'Tarjeta Roja';
      case MatchEventType.substitution:
        return 'Sustitución';
      case MatchEventType.penalty:
        return 'Penalti';
      case MatchEventType.ownGoal:
        return 'Autogol';
    }
  }
}
