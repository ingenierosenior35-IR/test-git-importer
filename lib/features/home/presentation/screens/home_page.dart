import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Rival/core/app_export.dart';
import 'package:Rival/core/constants/colors.dart';
import 'package:Rival/core/constants/strings.dart';
import 'package:Rival/shared/widgets/app_bar/appbar_edittext.dart';
import 'package:Rival/presentation/controllers/matches_controller.dart';
import 'package:Rival/data/models/match.dart';
import 'package:Rival/features/weather/domain/entities/weather_condition.dart';
import 'package:Rival/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:Rival/features/weather/data/datasources/sab_remote_data_source.dart';
import 'package:Rival/services/location_service.dart';
import 'package:Rival/services/auth_service.dart';
import 'package:Rival/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../controllers/home_controller.dart';
import '../../data/models/home_model.dart';

// Models for new sections
class FavoriteClub {
  final String name;
  final String status;
  final String logoUrl;
  
  FavoriteClub({required this.name, required this.status, required this.logoUrl});
}

class ToolItem {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback? onTap;
  
  ToolItem({
    required this.label,
    required this.icon,
    this.isPrimary = false,
    this.onTap,
  });
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController(HomeModel().obs));
  final MatchesController matchesController = Get.put(MatchesController());
  final LocationService locationService = LocationService();
  final AuthService authService = Get.find<AuthService>();
  final FirestoreService firestoreService = FirestoreService();
  
  final Rx<WeatherCondition?> weatherCondition = Rx<WeatherCondition?>(null);
  final RxBool isLoadingWeather = false.obs;
  final RxMap<String, dynamic> userData = RxMap<String, dynamic>({});
  
  // Dummy data for favorites - TODO: Replace with actual user favorites from data source
  final List<FavoriteClub> _favoriteClubs = [
    FavoriteClub(name: 'Real Madrid', status: AppStrings.won, logoUrl: ''),
    FavoriteClub(name: 'Barcelona', status: AppStrings.won, logoUrl: ''),
    FavoriteClub(name: 'Atlético', status: AppStrings.drew, logoUrl: ''),
    FavoriteClub(name: 'Valencia', status: AppStrings.lost, logoUrl: ''),
    FavoriteClub(name: 'Sevilla', status: AppStrings.won, logoUrl: ''),
  ];
  
  final List<String> _gameDays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadWeather();
    _loadUserData();
  }

  Future<void> _loadWeather() async {
    try {
      isLoadingWeather.value = true;
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        final prefs = await SharedPreferences.getInstance();
        final repository = WeatherRepositoryImpl(
          remoteDataSource: SabRemoteDataSourceImpl(client: http.Client()),
          sharedPreferences: prefs,
        );
        
        final result = await repository.getWeatherCondition(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        
        result.fold(
          (failure) => weatherCondition.value = null,
          (condition) => weatherCondition.value = condition,
        );
      }
    } catch (e) {
      weatherCondition.value = null;
    } finally {
      isLoadingWeather.value = false;
    }
  }

  Future<void> _loadUserData() async {
    final user = authService.currentUser;
    if (user != null) {
      final data = await firestoreService.getUserData(user.uid);
      if (data != null) {
        userData.value = data;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    return SafeArea(
      child: Column(
        children: [
          _buildTopMatchStrip(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: getVerticalSize(16)),
                  _buildPerformanceHeroCard(),
                  SizedBox(height: getVerticalSize(24)),
                  _buildFavoritesSection(),
                  SizedBox(height: getVerticalSize(24)),
                  _buildToolsSection(),
                  SizedBox(height: getVerticalSize(24)),
                  _buildGameDaysSection(),
                  SizedBox(height: getVerticalSize(24)),
                  _buildMatchesSection(),
                  SizedBox(height: getVerticalSize(32)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMatchStrip() {
    return Obx(() {
      final weather = weatherCondition.value;
      final matches = matchesController.matches;
      final nextMatch = matches.isEmpty 
          ? null 
          : matches.firstWhere(
              (m) => m.dateTime.isAfter(DateTime.now()),
              orElse: () => matches.first,
            );
      
      return Container(
        padding: getPadding(top: 16, left: 20, right: 20, bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard.withOpacity(0.8),
          border: Border(
            bottom: BorderSide(
              color: AppColors.kDarkSurface,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Weather icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.kDarkSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                weather != null ? _getWeatherIconData(weather.fieldCondition) : Icons.wb_cloudy,
                color: weather != null ? _getWeatherIconColor(weather.fieldCondition) : AppColors.kGrey,
                size: 20,
              ),
            ),
            SizedBox(width: getHorizontalSize(12)),
            // Match info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.nextLeagueMatch,
                    style: TextStyle(
                      color: AppColors.kGreyLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    nextMatch?.name ?? 'Liga Local',
                    style: TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Action icons
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.searchFillScreen),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.kDarkSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.search,
                  color: AppColors.kGreyLight,
                  size: 18,
                ),
              ),
            ),
            SizedBox(width: getHorizontalSize(8)),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.notificationsScreen),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.kDarkSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.kGreyLight,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPerformanceHeroCard() {
    return Obx(() {
      final userDataMap = userData.value;
      
      return Container(
        margin: getPadding(left: 20, right: 20),
        padding: getPadding(all: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.kYellowAccent,
              AppColors.kYellowAccent.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // Left side - Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.performance.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.kBlack,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppStrings.lastMatch,
                    style: TextStyle(
                      color: AppColors.kBlack.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    AppStrings.playedMinutes,
                    style: TextStyle(
                      color: AppColors.kBlack.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Big stat - TODO: Replace with actual player performance data
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '108 ',
                          style: TextStyle(
                            color: AppColors.kBlack,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                        TextSpan(
                          text: AppStrings.totalPasses,
                          style: TextStyle(
                            color: AppColors.kBlack.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: getHorizontalSize(16)),
            // Right side - Rating and Photo
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Rating chip
                Container(
                  padding: getPadding(left: 12, right: 12, top: 6, bottom: 6),
                  decoration: BoxDecoration(
                    color: AppColors.kBlack,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '8.5',
                    style: TextStyle(
                      color: AppColors.kYellowAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(height: getVerticalSize(12)),
                // Player photo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.kBlack, width: 3),
                  ),
                  child: ClipOval(
                    child: userDataMap['photoURL'] != null
                        ? Image.network(
                            userDataMap['photoURL'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              Icon(Icons.person, size: 40, color: AppColors.kBlack.withOpacity(0.3)),
                          )
                        : Icon(Icons.person, size: 40, color: AppColors.kBlack.withOpacity(0.3)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFavoritesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: getPadding(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.yourFavorites,
                style: TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.fixturesScreen);
                },
                child: Text(
                  AppStrings.viewAll,
                  style: TextStyle(
                    color: AppColors.kYellowAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: getVerticalSize(16)),
        SizedBox(
          height: 100,
          child: ListView.builder(
            padding: getPadding(left: 20, right: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _favoriteClubs.length,
            itemBuilder: (context, index) {
              final club = _favoriteClubs[index];
              return _buildFavoriteClubCard(club);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteClubCard(FavoriteClub club) {
    Color statusColor;
    // Match against AppStrings constants instead of literal strings
    if (club.status == AppStrings.won) {
      statusColor = AppColors.kGreen;
    } else if (club.status == AppStrings.drew) {
      statusColor = AppColors.kOrange;
    } else if (club.status == AppStrings.lost) {
      statusColor = AppColors.kRed;
    } else {
      statusColor = AppColors.kGrey;
    }
    
    return Container(
      width: 90,
      margin: getMargin(right: 12),
      padding: getPadding(all: 12),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
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
          SizedBox(height: 6),
          Text(
            club.name,
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            club.status,
            style: TextStyle(
              color: statusColor,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsSection() {
    // Tools with quick access functionalities from old HomeScreen integrated
    final tools = [
      ToolItem(
        label: AppStrings.matches,
        icon: Icons.sports_soccer,
        isPrimary: true,
        onTap: () => Get.toNamed(AppRoutes.createMatchScreen),
      ),
      ToolItem(
        label: AppStrings.polls,
        icon: Icons.poll,
        onTap: () => Get.toNamed(AppRoutes.pollsScreen),
      ),
      ToolItem(
        label: AppStrings.fixtures,
        icon: Icons.calendar_today,
        onTap: () => Get.toNamed(AppRoutes.fixturesScreen),
      ),
      ToolItem(
        label: AppStrings.weather,
        icon: Icons.wb_sunny,
        onTap: () => Get.toNamed(AppRoutes.weatherScreen),
      ),
      ToolItem(
        label: AppStrings.training,
        icon: Icons.fitness_center,
        onTap: () {
          Get.snackbar(
            AppStrings.training,
            'Próximamente',
            backgroundColor: AppColors.kDarkCard,
            colorText: AppColors.kWhite,
          );
        },
      ),
      ToolItem(
        label: AppStrings.teams,
        icon: Icons.groups,
        onTap: () {
          Get.snackbar(
            AppStrings.teams,
            'Próximamente',
            backgroundColor: AppColors.kDarkCard,
            colorText: AppColors.kWhite,
          );
        },
      ),
      ToolItem(
        label: AppStrings.tournaments,
        icon: Icons.emoji_events,
        onTap: () {
          Get.snackbar(
            AppStrings.tournaments,
            'Próximamente',
            backgroundColor: AppColors.kDarkCard,
            colorText: AppColors.kWhite,
          );
        },
      ),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: getPadding(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.tools,
                style: TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: getVerticalSize(16)),
        SizedBox(
          height: 100,
          child: ListView.builder(
            padding: getPadding(left: 20, right: 20),
            scrollDirection: Axis.horizontal,
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final tool = tools[index];
              return _buildToolButton(tool);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton(ToolItem tool) {
    return GestureDetector(
      onTap: tool.onTap,
      child: Container(
        width: 90,
        margin: getMargin(right: 12),
        padding: getPadding(all: 12),
        decoration: BoxDecoration(
          color: tool.isPrimary ? AppColors.kYellowAccent : AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tool.icon,
              color: tool.isPrimary ? AppColors.kBlack : AppColors.kYellowAccent,
              size: 32,
            ),
            SizedBox(height: 6),
            Text(
              tool.label,
              style: TextStyle(
                color: tool.isPrimary ? AppColors.kBlack : AppColors.kWhite,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: getPadding(left: 20, right: 20),
          child: Text(
            AppStrings.gameDays,
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: getVerticalSize(16)),
        Padding(
          padding: getPadding(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_gameDays.length, (index) {
              // All chips have same style - decorative UI element for now
              return Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.kDarkCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _gameDays[index],
                    style: TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIconData(FieldCondition condition) {
    switch (condition) {
      case FieldCondition.excellent:
        return Icons.wb_sunny;
      case FieldCondition.good:
        return Icons.wb_cloudy;
      case FieldCondition.fair:
        return Icons.cloud;
      case FieldCondition.poor:
        return Icons.grain;
      case FieldCondition.unplayable:
        return Icons.thunderstorm;
    }
  }

  Color _getWeatherIconColor(FieldCondition condition) {
    switch (condition) {
      case FieldCondition.excellent:
        return AppColors.kYellowAccent;
      case FieldCondition.good:
        return AppColors.kYellowAccent;
      case FieldCondition.fair:
        return AppColors.kOrange;
      case FieldCondition.poor:
        return AppColors.kOrange;
      case FieldCondition.unplayable:
        return AppColors.kRed;
    }
  }

  Widget _getWeatherIcon(FieldCondition condition) {
    return Icon(
      _getWeatherIconData(condition),
      color: _getWeatherIconColor(condition),
      size: 40,
    );
  }

  Widget _buildMatchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: getPadding(left: 20, right: 20),
          child: Text(
            'TUS PARTIDOS',
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(height: getVerticalSize(16)),
        Obx(() {
          final matches = matchesController.matches;
          final isLoading = matchesController.isLoading.value;

          if (isLoading) {
            return Center(
              child: Padding(
                padding: getPadding(all: 20),
                child: CircularProgressIndicator(color: AppColors.kYellowAccent),
              ),
            );
          }

          if (matches.isEmpty) {
            return Container(
              margin: getPadding(left: 20, right: 20),
              padding: getPadding(all: 20),
              decoration: BoxDecoration(
                color: AppColors.kDarkCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'No tienes partidos programados',
                  style: TextStyle(color: AppColors.kGrey, fontSize: 14),
                ),
              ),
            );
          }

          return SizedBox(
            height: 160,
            child: ListView.builder(
              padding: getPadding(left: 20, right: 20),
              scrollDirection: Axis.horizontal,
              itemCount: matches.length > 5 ? 5 : matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return _buildMatchCard(match);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMatchCard(Match match) {
    final dateFormat = DateFormat('dd MMM', 'es');
    final timeFormat = DateFormat('HH:mm');

    return GestureDetector(
      onTap: () => matchesController.navigateToMatchDetail(match.id),
      child: Container(
        width: 280,
        margin: getMargin(right: 16),
        padding: getPadding(all: 16),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: getPadding(left: 12, right: 12, top: 6, bottom: 6),
                  decoration: BoxDecoration(
                    color: AppColors.kYellowAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dateFormat.format(match.dateTime),
                    style: TextStyle(
                      color: AppColors.kYellowAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.wb_cloudy_outlined,
                  color: AppColors.kGrey,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: getVerticalSize(12)),
            Text(
              match.name,
              style: TextStyle(
                color: AppColors.kWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: getVerticalSize(8)),
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.kGrey, size: 16),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    match.venue,
                    style: TextStyle(color: AppColors.kGreyLight, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: getVerticalSize(4)),
            Row(
              children: [
                Icon(Icons.access_time, color: AppColors.kGrey, size: 16),
                SizedBox(width: 4),
                Text(
                  timeFormat.format(match.dateTime),
                  style: TextStyle(color: AppColors.kGreyLight, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
