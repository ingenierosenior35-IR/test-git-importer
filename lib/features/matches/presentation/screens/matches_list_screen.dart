import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/match_model.dart';
import '../../data/repositories/matches_firestore_repository.dart';

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({Key? key}) : super(key: key);

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = MatchesFirestoreRepository();
  List<Match> _upcomingMatches = [];
  List<Match> _completedMatches = [];
  bool _loading = true;

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

  Future<void> _loadMatches() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final matches = await _repository.getMatchesForUser(user.uid);
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _upcomingMatches = matches
            .where((m) => m.status == MatchStatus.upcoming || m.dateTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
        _completedMatches = matches
            .where((m) => m.status == MatchStatus.completed)
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
        _loading = false;
      });
    }
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
          'Mis Partidos',
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
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.kYellowAccent),
            )
          : RefreshIndicator(
              color: AppColors.kYellowAccent,
              onRefresh: _loadMatches,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMatchesList(_upcomingMatches, isUpcoming: true),
                  _buildMatchesList(_completedMatches, isUpcoming: false),
                ],
              ),
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
              isUpcoming
                  ? 'No hay partidos próximos.\nCrea uno con el botón +'
                  : 'No hay partidos completados.',
              style: TextStyle(color: AppColors.kGrey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) => _buildMatchCard(matches[index]),
    );
  }

  Widget _buildMatchCard(Match match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: match.matchType == MatchType.versus
                            ? AppColors.kYellowAccent.withOpacity(0.2)
                            : AppColors.kGrey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        match.matchType == MatchType.versus
                            ? 'VERSUS'
                            : 'LOCAL',
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
                const SizedBox(height: 12),
                Text(
                  match.name,
                  style: const TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (match.hasScore) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${match.homeScore} - ${match.awayScore}',
                    style: const TextStyle(
                      color: AppColors.kYellowAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(color: AppColors.kDarkSurface, height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: AppColors.kGrey),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd MMM yyyy', 'es').format(match.dateTime),
                      style:
                          const TextStyle(color: AppColors.kGrey, fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time,
                        size: 14, color: AppColors.kGrey),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('HH:mm').format(match.dateTime),
                      style:
                          const TextStyle(color: AppColors.kGrey, fontSize: 13),
                    ),
                  ],
                ),
                if (match.venue != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.kGrey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          match.venue!,
                          style: const TextStyle(
                              color: AppColors.kGrey, fontSize: 13),
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
