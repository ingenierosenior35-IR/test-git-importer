import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:Rival/core/app_export.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/core/constants/strings.dart';
import '../../data/models/fixture_model.dart';
import '../../data/datasources/fixtures_mock_data.dart';

class FixturesScreen extends StatefulWidget {
  const FixturesScreen({Key? key}) : super(key: key);

  @override
  State<FixturesScreen> createState() => _FixturesScreenState();
}

class _FixturesScreenState extends State<FixturesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Fixture> _allFixtures = FixturesMockData.getMockFixtures();
  late final DateFormat _dateFormat;
  late final DateFormat _timeFormat;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dateFormat = DateFormat('dd MMM', 'es');
    _timeFormat = DateFormat('HH:mm');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Fixture> get _upcomingFixtures {
    return _allFixtures
        .where((f) => f.isScheduled)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Fixture> get _finishedFixtures {
    return _allFixtures
        .where((f) => f.isFinished)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  @override
  Widget build(BuildContext context) {
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
          'RESULTADOS Y FIXTURES',
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'PRÓXIMOS'),
            Tab(text: 'RESULTADOS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFixturesList(_upcomingFixtures, isUpcoming: true),
          _buildFixturesList(_finishedFixtures, isUpcoming: false),
        ],
      ),
    );
  }

  Widget _buildFixturesList(List<Fixture> fixtures, {required bool isUpcoming}) {
    if (fixtures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 64,
              color: AppColors.kGrey,
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No hay partidos programados' : 'No hay resultados',
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
      itemCount: fixtures.length,
      itemBuilder: (context, index) {
        return _buildFixtureCard(fixtures[index], isUpcoming: isUpcoming);
      },
    );
  }

  Widget _buildFixtureCard(Fixture fixture, {required bool isUpcoming}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with competition and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.kYellowAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  fixture.competition,
                  style: TextStyle(
                    color: AppColors.kYellowAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _dateFormat.format(fixture.dateTime),
                style: TextStyle(
                  color: AppColors.kGreyLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Teams and score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home team
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.kDarkSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sports_soccer,
                        color: AppColors.kYellowAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fixture.homeTeam,
                      style: TextStyle(
                        color: AppColors.kWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Score or time
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isUpcoming
                    ? Column(
                        children: [
                          Text(
                            _timeFormat.format(fixture.dateTime),
                            style: TextStyle(
                              color: AppColors.kYellowAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'VS',
                            style: TextStyle(
                              color: AppColors.kGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Text(
                            fixture.homeScore ?? '0',
                            style: TextStyle(
                              color: AppColors.kWhite,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '-',
                            style: TextStyle(
                              color: AppColors.kGrey,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            fixture.awayScore ?? '0',
                            style: TextStyle(
                              color: AppColors.kWhite,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              // Away team
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.kDarkSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sports_soccer,
                        color: AppColors.kYellowAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fixture.awayTeam,
                      style: TextStyle(
                        color: AppColors.kWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Venue
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: AppColors.kGrey, size: 16),
              const SizedBox(width: 4),
              Text(
                fixture.venue,
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
  }
}
