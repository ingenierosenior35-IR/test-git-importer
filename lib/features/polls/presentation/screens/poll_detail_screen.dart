import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:Rival/core/app_export.dart';
import 'package:Rival/core/constants/colors.dart';
import '../../data/models/poll_model.dart';
import '../../data/models/espn_models.dart';
import '../../data/repositories/polls_firebase_repository.dart';

class PollDetailScreen extends StatefulWidget {
  final String pollId;
  
  const PollDetailScreen({Key? key, required this.pollId}) : super(key: key);

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = PollsFirebaseRepository();
  Poll? _poll;
  bool _loading = true;
  List<PollStanding> _standings = [];
  List<Map<String, dynamic>> _rawPredictions = [];
  final _predControllers = <String, Map<String, TextEditingController>>{};
  late final DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _dateFormat = DateFormat('EEE dd MMM, HH:mm', 'es');
    _loadPollData();
  }

  Future<void> _loadPollData() async {
    setState(() => _loading = true);
    try {
      final poll = await _repository.getPollById(widget.pollId);
      final rawPredictions = await _repository.getPredictions(widget.pollId);

      if (mounted) {
        setState(() {
          _poll = poll;
          _rawPredictions = rawPredictions;
          _standings = _computeStandings(rawPredictions);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('PollDetailScreen._loadPollData error: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<PollStanding> _computeStandings(List<Map<String, dynamic>> predictions) {
    final scores = <String, PollStanding>{};
    for (final p in predictions) {
      final uid = p['userId'] as String? ?? '';
      final name = p['userName'] as String? ?? 'Usuario';
      final existing = scores[uid] ?? PollStanding(
        userId: uid,
        userName: name,
        points: 0,
        correctPredictions: 0,
        totalPredictions: 0,
      );
      scores[uid] = PollStanding(
        userId: uid,
        userName: name,
        points: existing.points + ((p['points'] as int?) ?? 0),
        correctPredictions: existing.correctPredictions + (((p['points'] as int?) ?? 0) > 0 ? 1 : 0),
        totalPredictions: existing.totalPredictions + 1,
      );
    }
    return scores.values.toList()..sort((a, b) => b.points.compareTo(a.points));
  }

  TextEditingController _getController(String fixtureId, String side) {
    _predControllers[fixtureId] ??= {};
    _predControllers[fixtureId]![side] ??= TextEditingController();
    return _predControllers[fixtureId]![side]!;
  }

  Future<void> _savePrediction(EspnEvent event) async {
    final homeCtrl = _getController(event.id, 'home');
    final awayCtrl = _getController(event.id, 'away');
    final homeScore = homeCtrl.text.trim();
    final awayScore = awayCtrl.text.trim();

    if (homeScore.isEmpty || awayScore.isEmpty) {
      Get.snackbar('Completa el marcador', 'Ingresa el resultado para ambos equipos.',
          backgroundColor: AppColors.kDarkCard,
          colorText: AppColors.kWhite,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _repository.savePrediction(
        pollId: _poll!.id,
        userId: user.uid,
        userName: user.displayName ?? user.email ?? 'Usuario',
        fixtureId: event.id,
        homeScore: homeScore,
        awayScore: awayScore,
      );
      if (!mounted) return;
      Get.snackbar(
        '¡Predicción guardada!',
        '${event.homeTeam.displayName} $homeScore - $awayScore ${event.awayTeam.displayName}',
        backgroundColor: AppColors.kYellowAccent.withOpacity(0.95),
        colorText: AppColors.kBlack,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', 'No se pudo guardar la predicción.',
          backgroundColor: AppColors.kError,
          colorText: AppColors.kWhite,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final m in _predControllers.values) {
      for (final c in m.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.kDarkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.kDarkCard,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.kWhite),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.kYellowAccent),
        ),
      );
    }

    if (_poll == null) {
      return Scaffold(
        backgroundColor: AppColors.kDarkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.kDarkCard,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.kWhite),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Text(
            'Polla no encontrada',
            style: TextStyle(color: AppColors.kGrey, fontSize: 16),
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
          icon: const Icon(Icons.arrow_back, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _poll!.name.toUpperCase(),
          style: const TextStyle(
            color: AppColors.kWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          if (_poll!.joinCode != null)
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.kYellowAccent),
              onPressed: () {
                Get.snackbar(
                  'Código de invitación',
                  _poll!.joinCode!,
                  backgroundColor: AppColors.kDarkCard,
                  colorText: AppColors.kYellowAccent,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 5),
                );
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.kYellowAccent,
          labelColor: AppColors.kYellowAccent,
          unselectedLabelColor: AppColors.kGrey,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'TABLA'),
            Tab(text: 'PARTIDOS'),
            Tab(text: 'PARTICIPANTES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStandingsTab(),
          _buildMatchesTab(),
          _buildParticipantsTab(),
        ],
      ),
    );
  }

  Widget _buildStandingsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _standings.length,
      itemBuilder: (context, index) {
        final standing = _standings[index];
        final position = index + 1;
        
        Color positionColor;
        if (position == 1) {
          positionColor = AppColors.kYellowAccent;
        } else if (position == 2) {
          positionColor = AppColors.kGreyLight;
        } else if (position == 3) {
          positionColor = AppColors.kOrange;
        } else {
          positionColor = AppColors.kGrey;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.kDarkCard,
            borderRadius: BorderRadius.circular(12),
            border: position <= 3
                ? Border.all(color: positionColor.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              // Position
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: positionColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$position',
                    style: TextStyle(
                      color: positionColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      standing.userName,
                      style: TextStyle(
                        color: AppColors.kWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${standing.correctPredictions}/${standing.totalPredictions} aciertos',
                      style: TextStyle(
                        color: AppColors.kGreyLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Points
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.kYellowAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${standing.points} pts',
                  style: TextStyle(
                    color: AppColors.kYellowAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchesTab() {
    final fixtures = _poll!.fixtures;
    if (fixtures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_soccer, size: 64, color: AppColors.kGrey),
            const SizedBox(height: 16),
            Text(
              'No hay partidos disponibles',
              style: TextStyle(color: AppColors.kGrey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fixtures.length,
      itemBuilder: (context, index) {
        return _buildFixturePredictionCard(fixtures[index]);
      },
    );
  }

  Widget _buildFixturePredictionCard(EspnEvent event) {
    final homeCtrl = _getController(event.id, 'home');
    final awayCtrl = _getController(event.id, 'away');
    final canPredict = event.isScheduled;

    Color statusColor;
    String statusLabel;
    if (event.isLive) {
      statusColor = AppColors.kGreen;
      statusLabel = 'EN VIVO';
    } else if (event.isFinished) {
      statusColor = AppColors.kGrey;
      statusLabel = 'FINALIZADO';
    } else {
      statusColor = AppColors.kYellowAccent;
      statusLabel = _dateFormat.format(event.date.toLocal());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event.isLive ? AppColors.kGreen.withOpacity(0.4) : AppColors.kDarkSurface,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              if (event.week != null)
                Text('Jornada ${event.week}',
                    style: TextStyle(color: AppColors.kGrey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          // Teams
          Row(
            children: [
              Expanded(
                child: Text(
                  event.homeTeam.displayName,
                  style: const TextStyle(color: AppColors.kWhite, fontSize: 14, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              // Score (actual or input)
              if (event.isFinished || event.isLive)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${event.homeScore ?? '-'}  :  ${event.awayScore ?? '-'}',
                    style: const TextStyle(
                      color: AppColors.kYellowAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildScoreInput(homeCtrl, canPredict),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(':', style: TextStyle(color: AppColors.kGrey, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildScoreInput(awayCtrl, canPredict),
                    ],
                  ),
                ),
              Expanded(
                child: Text(
                  event.awayTeam.displayName,
                  style: const TextStyle(color: AppColors.kWhite, fontSize: 14, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          if (canPredict) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _savePrediction(event),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kYellowAccent,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'GUARDAR PREDICCIÓN',
                  style: TextStyle(color: AppColors.kBlack, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreInput(TextEditingController controller, bool enabled) {
    return SizedBox(
      width: 44,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.kWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: const TextStyle(color: AppColors.kGrey),
          filled: true,
          fillColor: AppColors.kDarkSurface,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _poll!.participantIds.length,
      itemBuilder: (context, index) {
        final participantId = _poll!.participantIds[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.kDarkCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.kDarkSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.kYellowAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Participante ${index + 1}',
                  style: TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (participantId == _poll!.creatorId)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.kYellowAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'CREADOR',
                    style: TextStyle(
                      color: AppColors.kYellowAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
