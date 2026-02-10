import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Rival/core/app_export.dart';
import 'package:Rival/core/constants/colors.dart';
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
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        SizedBox(height: getVerticalSize(24)),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildWeatherCard(),
                SizedBox(height: getVerticalSize(20)),
                _buildPlayerCard(),
                SizedBox(height: getVerticalSize(20)),
                _buildMatchesSection(),
                SizedBox(height: getVerticalSize(20)),
                _buildFieldConditionsSection(),
                SizedBox(height: getVerticalSize(20)),
                _buildTournamentCTA(),
                SizedBox(height: getVerticalSize(32)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: getPadding(top: 16, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomImageView(
            svgPath: ImageConstant.imgFrame34501Onprimarycontainer,
          ),
          CustomImageView(
            svgPath: ImageConstant.imgNotification,
            height: getSize(24),
            width: getSize(24),
            margin: getMargin(top: 4, bottom: 4),
            onTap: () => Get.toNamed(AppRoutes.notificationsScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: getPadding(left: 20, right: 20, top: 32),
      child: AppbarEdittext(
        function: () => Get.toNamed(AppRoutes.searchFillScreen),
        action: TextInputType.none,
        hintText: "Buscar",
        controller: controller.searchController,
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Obx(() {
      final weather = weatherCondition.value;
      final isLoading = isLoadingWeather.value;

      return Container(
        margin: getPadding(left: 20, right: 20),
        padding: getPadding(all: 20),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.kYellowAccent))
            : weather != null
                ? Row(
                    children: [
                      _getWeatherIcon(weather.fieldCondition),
                      SizedBox(width: getHorizontalSize(16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weather.stationName,
                              style: TextStyle(
                                color: AppColors.kWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: getVerticalSize(4)),
                            Text(
                              weather.description,
                              style: TextStyle(
                                color: AppColors.kGreyLight,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: getVerticalSize(4)),
                            Text(
                              '${weather.rainfallMm.toStringAsFixed(1)}mm - ${weather.distanceKm.toStringAsFixed(1)}km',
                              style: TextStyle(
                                color: AppColors.kYellowAccent,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(Icons.location_off, color: AppColors.kGrey, size: 40),
                      SizedBox(width: getHorizontalSize(16)),
                      Text(
                        'No se pudo obtener el clima',
                        style: TextStyle(color: AppColors.kGrey, fontSize: 14),
                      ),
                    ],
                  ),
      );
    });
  }

  Widget _getWeatherIcon(FieldCondition condition) {
    IconData icon;
    Color color;

    switch (condition) {
      case FieldCondition.excellent:
        icon = Icons.wb_sunny;
        color = AppColors.kYellowAccent;
        break;
      case FieldCondition.good:
        icon = Icons.wb_cloudy;
        color = AppColors.kYellowAccent;
        break;
      case FieldCondition.fair:
        icon = Icons.cloud;
        color = AppColors.kOrange;
        break;
      case FieldCondition.poor:
        icon = Icons.grain;
        color = AppColors.kOrange;
        break;
      case FieldCondition.unplayable:
        icon = Icons.thunderstorm;
        color = AppColors.kRed;
        break;
    }

    return Icon(icon, color: color, size: 40);
  }

  Widget _buildPlayerCard() {
    return Obx(() {
      // ignore: invalid_use_of_protected_member
      final userDataMap = userData.value;

      return Container(
        margin: getPadding(left: 20, right: 20),
        padding: getPadding(all: 20),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.kYellowAccent, width: 3),
              ),
              child: ClipOval(
                child: userDataMap['photoURL'] != null
                    ? Image.network(
                        userDataMap['photoURL'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.person, size: 40, color: AppColors.kGrey),
                      )
                    : Icon(Icons.person, size: 40, color: AppColors.kGrey),
              ),
            ),
            SizedBox(width: getHorizontalSize(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userDataMap['displayName'] ?? 'Jugador',
                    style: TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: getVerticalSize(8)),
                  Obx(() {
                    final matches = matchesController.matches;
                    final nextMatch = matches.isEmpty 
                        ? null 
                        : matches.firstWhere(
                            (m) => m.dateTime.isAfter(DateTime.now()),
                            orElse: () => matches.first,
                          );
                    
                    if (nextMatch != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Próximo partido',
                            style: TextStyle(
                              color: AppColors.kGreyLight,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            nextMatch.name,
                            style: TextStyle(
                              color: AppColors.kYellowAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Text(
                        'Sin partidos programados',
                        style: TextStyle(
                          color: AppColors.kGreyLight,
                          fontSize: 14,
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
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

  Widget _buildFieldConditionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: getPadding(left: 20, right: 20),
          child: Text(
            'CONDICIONES POR CANCHA',
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(height: getVerticalSize(16)),
        Container(
          margin: getPadding(left: 20, right: 20),
          padding: getPadding(all: 16),
          decoration: BoxDecoration(
            color: AppColors.kDarkCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildFieldConditionItem('Cancha Municipal', FieldCondition.excellent),
              Divider(color: AppColors.kDarkSurface, height: 24),
              _buildFieldConditionItem('Estadio Central', FieldCondition.good),
              Divider(color: AppColors.kDarkSurface, height: 24),
              _buildFieldConditionItem('Campo Deportivo Norte', FieldCondition.fair),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldConditionItem(String venueName, FieldCondition condition) {
    String conditionText;
    Color conditionColor;

    switch (condition) {
      case FieldCondition.excellent:
        conditionText = 'Excelente';
        conditionColor = AppColors.kGreen;
        break;
      case FieldCondition.good:
        conditionText = 'Buena';
        conditionColor = AppColors.kYellowAccent;
        break;
      case FieldCondition.fair:
        conditionText = 'Regular';
        conditionColor = AppColors.kOrange;
        break;
      case FieldCondition.poor:
        conditionText = 'Mala';
        conditionColor = AppColors.kRed;
        break;
      case FieldCondition.unplayable:
        conditionText = 'No jugable';
        conditionColor = AppColors.kRed;
        break;
    }

    return Row(
      children: [
        _getWeatherIcon(condition),
        SizedBox(width: getHorizontalSize(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                venueName,
                style: TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                conditionText,
                style: TextStyle(
                  color: conditionColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTournamentCTA() {
    return GestureDetector(
      onTap: () {
        // Navigate to tournament creation
        Get.snackbar(
          'Próximamente',
          'Función de creación de torneos en desarrollo',
          backgroundColor: AppColors.kDarkCard,
          colorText: AppColors.kWhite,
        );
      },
      child: Container(
        margin: getPadding(left: 20, right: 20),
        padding: getPadding(all: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.kYellowAccent.withOpacity(0.2),
              AppColors.kYellowAccent.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.kYellowAccent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: getPadding(all: 12),
              decoration: BoxDecoration(
                color: AppColors.kYellowAccent,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events, color: AppColors.kBlack, size: 32),
            ),
            SizedBox(width: getHorizontalSize(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crear Torneo',
                    style: TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Organiza tu propio torneo',
                    style: TextStyle(
                      color: AppColors.kGreyLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.kYellowAccent, size: 20),
          ],
        ),
      ),
    );
  }
}
