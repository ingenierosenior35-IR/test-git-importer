import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/match_model.dart';
import '../../data/datasources/matches_mock_data.dart';
import '../../../teams/data/datasources/teams_mock_data.dart';

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({Key? key}) : super(key: key);

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Match> upcomingMatches = [];
  List<Match> completedMatches = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMatches() {
    setState(() {
      upcomingMatches = MatchesMockData.getUpcomingMatches();
      completedMatches = MatchesMockData.getCompletedMatches();
    });
  }

  void _createMatch() {
    Get.toNamed('/create_match_flow_screen')?.then((_) => _loadMatches());
  }

  void _viewMatchDetail(Match match) {
    if (match.status == MatchStatus.completed) {
      Get.toNamed('/match_result_screen', arguments: match);
    } else {
      Get.toNamed('/match_detail_info_screen', arguments: match);
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
          'Partidos',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.kYellowAccent),
            onPressed: _createMatch,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.kYellowAccent,
          labelColor: AppColors.kYellowAccent,
          unselectedLabelColor: AppColors.kGrey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'PRÓXIMOS'),
            Tab(text: 'COMPLETADOS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMatchesList(upcomingMatches, isUpcoming: true),
          _buildMatchesList(completedMatches, isUpcoming: false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMatch,
        backgroundColor: AppColors.kYellowAccent,
        child: const Icon(Icons.add, color: AppColors.kBlack),
      ),
    );
  }

  Widget _buildMatchesList(List<Match> matches, {required bool isUpcoming}) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 80,
              color: AppColors.kGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No hay partidos próximos' : 'No hay partidos completados',
              style: TextStyle(
                color: AppColors.kGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return _buildMatchCard(matches[index]);
      },
    );
  }

  Widget _buildMatchCard(Match match) {
    final homeTeam = match.homeTeamId != null 
        ? TeamsMockData.getTeamById(match.homeTeamId!)
        : null;
    final awayTeam = match.awayTeamId != null
        ? TeamsMockData.getTeamById(match.awayTeamId!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.kBlack.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewMatchDetail(match),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Match Type Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: match.matchType == MatchType.versus
                            ? AppColors.kYellowAccent.withOpacity(0.2)
                            : AppColors.kGrey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        match.matchType == MatchType.versus ? 'VERSUS' : 'LOCAL',
                        style: TextStyle(
                          color: match.matchType == MatchType.versus
                              ? AppColors.kYellowAccent
                              : AppColors.kGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (match.status == MatchStatus.completed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.kGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'FINALIZADO',
                          style: TextStyle(
                            color: AppColors.kGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Teams or Match Name
                if (match.isVersus && homeTeam != null && awayTeam != null)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.shield, color: AppColors.kYellowAccent, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              homeTeam.name,
                              style: const TextStyle(
                                color: AppColors.kWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            if (match.hasScore)
                              Text(
                                '${match.homeScore} - ${match.awayScore}',
                                style: const TextStyle(
                                  color: AppColors.kYellowAccent,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              Text(
                                'VS',
                                style: TextStyle(
                                  color: AppColors.kGrey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.shield, color: AppColors.kGrey, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              awayTeam.name,
                              style: const TextStyle(
                                color: AppColors.kWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    match.name,
                    style: const TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                
                const SizedBox(height: 16),
                const Divider(color: AppColors.kDarkSurface, height: 1),
                const SizedBox(height: 12),
                
                // Match Details
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.kGrey),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy', 'es').format(match.dateTime),
                      style: TextStyle(color: AppColors.kGrey, fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: AppColors.kGrey),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('HH:mm').format(match.dateTime),
                      style: TextStyle(color: AppColors.kGrey, fontSize: 13),
                    ),
                  ],
                ),
                if (match.venue != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.kGrey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          match.venue!,
                          style: TextStyle(color: AppColors.kGrey, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
                if (match.reservationId != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.confirmation_number, size: 16, color: AppColors.kYellowAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Reserva: ${match.reservationId}',
                        style: const TextStyle(
                          color: AppColors.kYellowAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
