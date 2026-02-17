import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Rival/core/app_export.dart';
import 'package:Rival/core/constants/colors.dart';
import '../../data/models/poll_model.dart';
import '../../data/datasources/polls_mock_data.dart';

class PollDetailScreen extends StatefulWidget {
  final String pollId;
  
  const PollDetailScreen({Key? key, required this.pollId}) : super(key: key);

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Poll? _poll;
  late List<PollStanding> _standings;
  late List<PollPrediction> _predictions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPollData();
  }

  void _loadPollData() {
    _poll = PollsMockData.getPollById(widget.pollId);
    _standings = PollsMockData.getMockStandings(widget.pollId);
    _predictions = PollsMockData.getMockPredictions(widget.pollId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _predictions.length,
      itemBuilder: (context, index) {
        final prediction = _predictions[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.kDarkCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Real Madrid vs Barcelona',
                    style: TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (prediction.points != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.kYellowAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${prediction.points} pts',
                        style: TextStyle(
                          color: AppColors.kYellowAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    prediction.homeTeamPrediction,
                    style: TextStyle(
                      color: AppColors.kYellowAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '-',
                    style: TextStyle(
                      color: AppColors.kGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    prediction.awayTeamPrediction,
                    style: TextStyle(
                      color: AppColors.kYellowAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, color: AppColors.kGrey, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    prediction.userName,
                    style: TextStyle(
                      color: AppColors.kGreyLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
