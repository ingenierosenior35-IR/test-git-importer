# API Integration Guide

## Overview
This document provides guidance for integrating the fixtures and polls features with real backend APIs.

## Current Implementation

All features currently use **mock data sources** that simulate API responses:
- `/lib/features/fixtures/data/datasources/fixtures_mock_data.dart`
- `/lib/features/polls/data/datasources/polls_mock_data.dart`

## Code Review Notes for API Integration

### 1. Data Refresh on Screen Return

**Current Implementation:**
```dart
// In polls_screen.dart and fixtures_screen.dart
final List<Poll> _allPolls = PollsMockData.getMockPolls();
final List<Fixture> _allFixtures = FixturesMockData.getMockFixtures();
```

**Issue:** Static data is loaded once when widget is created.

**Recommended Change for API Integration:**
```dart
class _PollsScreenState extends State<PollsScreen> {
  List<Poll> _polls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPolls();
  }

  Future<void> _loadPolls() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get('$apiUrl/polls');
      setState(() {
        _polls = (response.data as List)
            .map((json) => Poll.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }
}
```

**Alternative with GetX:**
```dart
// Create a PollsController
class PollsController extends GetxController {
  final RxList<Poll> polls = <Poll>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPolls();
  }

  Future<void> loadPolls() async {
    isLoading.value = true;
    try {
      final response = await http.get('$apiUrl/polls');
      polls.value = (response.data as List)
          .map((json) => Poll.fromJson(json))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 2. Match Information from Fixtures

**Current Implementation:**
```dart
// In poll_detail_screen.dart, line 227
Text('Real Madrid vs Barcelona')  // Hardcoded
```

**Issue:** Match info should come from fixture data, not hardcoded.

**Recommended Change:**
```dart
// First, create a method to get fixture by ID
Future<Fixture?> _getFixture(String fixtureId) async {
  try {
    final response = await http.get('$apiUrl/fixtures/$fixtureId');
    return Fixture.fromJson(response.data);
  } catch (e) {
    return null;
  }
}

// Then use it in the UI
FutureBuilder<Fixture?>(
  future: _getFixture(prediction.fixtureId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final fixture = snapshot.data!;
      return Text('${fixture.homeTeam} vs ${fixture.awayTeam}');
    }
    return Text('Cargando...');
  },
)
```

**Better approach with state management:**
```dart
// Cache fixtures in the controller
class PollDetailController extends GetxController {
  final RxMap<String, Fixture> fixturesCache = <String, Fixture>{}.obs;

  Future<Fixture?> getFixture(String fixtureId) async {
    if (fixturesCache.containsKey(fixtureId)) {
      return fixturesCache[fixtureId];
    }
    
    try {
      final response = await http.get('$apiUrl/fixtures/$fixtureId');
      final fixture = Fixture.fromJson(response.data);
      fixturesCache[fixtureId] = fixture;
      return fixture;
    } catch (e) {
      return null;
    }
  }
}
```

## Step-by-Step API Integration

### Step 1: Create API Service

Create `/lib/services/api_service.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://api.yourapp.com/v1';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }
}
```

### Step 2: Create Repository Layer

Create `/lib/features/fixtures/data/repositories/fixtures_repository.dart`:

```dart
import '../models/fixture_model.dart';
import '../../../../services/api_service.dart';

class FixturesRepository {
  final ApiService _apiService;

  FixturesRepository({required ApiService apiService}) 
      : _apiService = apiService;

  Future<List<Fixture>> getFixtures() async {
    final data = await _apiService.get('/fixtures');
    return (data as List)
        .map((json) => Fixture.fromJson(json))
        .toList();
  }

  Future<List<Fixture>> getUpcomingFixtures() async {
    final data = await _apiService.get('/fixtures?status=scheduled');
    return (data as List)
        .map((json) => Fixture.fromJson(json))
        .toList();
  }

  Future<List<Fixture>> getFinishedFixtures() async {
    final data = await _apiService.get('/fixtures?status=finished');
    return (data as List)
        .map((json) => Fixture.fromJson(json))
        .toList();
  }

  Future<Fixture> getFixture(String id) async {
    final data = await _apiService.get('/fixtures/$id');
    return Fixture.fromJson(data);
  }
}
```

Create `/lib/features/polls/data/repositories/polls_repository.dart`:

```dart
import '../models/poll_model.dart';
import '../../../../services/api_service.dart';

class PollsRepository {
  final ApiService _apiService;

  PollsRepository({required ApiService apiService}) 
      : _apiService = apiService;

  Future<List<Poll>> getPolls() async {
    final data = await _apiService.get('/polls');
    return (data as List)
        .map((json) => Poll.fromJson(json))
        .toList();
  }

  Future<Poll> createPoll(Poll poll) async {
    final data = await _apiService.post('/polls', poll.toJson());
    return Poll.fromJson(data);
  }

  Future<Poll> joinPoll(String pollId, String code) async {
    final data = await _apiService.post('/polls/$pollId/join', {
      'code': code,
    });
    return Poll.fromJson(data);
  }

  Future<Poll> getPoll(String id) async {
    final data = await _apiService.get('/polls/$id');
    return Poll.fromJson(data);
  }

  Future<List<PollStanding>> getStandings(String pollId) async {
    final data = await _apiService.get('/polls/$pollId/standings');
    return (data as List)
        .map((json) => PollStanding.fromJson(json))
        .toList();
  }

  Future<List<PollPrediction>> getPredictions(String pollId) async {
    final data = await _apiService.get('/polls/$pollId/predictions');
    return (data as List)
        .map((json) => PollPrediction.fromJson(json))
        .toList();
  }
}
```

### Step 3: Update Controllers

Create `/lib/features/fixtures/presentation/controllers/fixtures_controller.dart`:

```dart
import 'package:get/get.dart';
import '../../data/models/fixture_model.dart';
import '../../data/repositories/fixtures_repository.dart';

class FixturesController extends GetxController {
  final FixturesRepository _repository;
  
  FixturesController({required FixturesRepository repository})
      : _repository = repository;

  final RxList<Fixture> fixtures = <Fixture>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFixtures();
  }

  Future<void> loadFixtures() async {
    try {
      isLoading.value = true;
      error.value = '';
      fixtures.value = await _repository.getFixtures();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadFixtures();
  }

  List<Fixture> get upcomingFixtures {
    return fixtures
        .where((f) => f.isScheduled)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Fixture> get finishedFixtures {
    return fixtures
        .where((f) => f.isFinished)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }
}
```

### Step 4: Update Screens with Controllers

Update `/lib/features/fixtures/presentation/screens/fixtures_screen.dart`:

```dart
class FixturesScreen extends StatelessWidget {
  const FixturesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller with repository
    final controller = Get.put(FixturesController(
      repository: FixturesRepository(
        apiService: Get.find<ApiService>(),
      ),
    ));

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${controller.error.value}'),
                ElevatedButton(
                  onPressed: () => controller.refresh(),
                  child: Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        
        return TabBarView(
          children: [
            _buildFixturesList(controller.upcomingFixtures, true),
            _buildFixturesList(controller.finishedFixtures, false),
          ],
        );
      }),
    );
  }
}
```

### Step 5: Add Dependency Injection

In `/lib/main.dart` or an initialization file:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  Get.put(ApiService());
  
  runApp(MyApp());
}
```

## Error Handling

### Add Error States

```dart
Widget _buildErrorState(String error, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.kRed),
          SizedBox(height: 16),
          Text(
            'Algo salió mal',
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: AppColors.kGrey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kYellowAccent,
            ),
            child: Text(
              'REINTENTAR',
              style: TextStyle(color: AppColors.kBlack),
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Add Loading States

```dart
Widget _buildLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppColors.kYellowAccent),
        SizedBox(height: 16),
        Text(
          'Cargando...',
          style: TextStyle(color: AppColors.kGrey, fontSize: 14),
        ),
      ],
    ),
  );
}
```

### Add Empty States

```dart
Widget _buildEmptyState(String message, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: AppColors.kGrey),
        SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(color: AppColors.kGrey, fontSize: 16),
        ),
      ],
    ),
  );
}
```

## Testing with Mock API

You can test API integration locally using a mock server:

### Option 1: JSON Server

```bash
npm install -g json-server
```

Create `db.json`:

```json
{
  "fixtures": [
    {
      "id": "1",
      "homeTeam": "Real Madrid",
      "awayTeam": "Barcelona",
      "homeScore": "2",
      "awayScore": "1",
      "dateTime": "2024-02-16T20:00:00Z",
      "competition": "La Liga",
      "status": "finished",
      "venue": "Santiago Bernabéu"
    }
  ],
  "polls": [
    {
      "id": "1",
      "name": "La Liga 2024",
      "description": "Predicciones para La Liga",
      "creatorId": "user1",
      "creatorName": "Carlos",
      "createdAt": "2024-01-18T10:00:00Z",
      "participantIds": ["user1", "user2"],
      "status": "active"
    }
  ]
}
```

Run:
```bash
json-server --watch db.json --port 3000
```

Update API base URL:
```dart
static const String baseUrl = 'http://localhost:3000';
```

## Real-time Updates

For real-time updates (live scores, poll standings), consider:

### Option 1: WebSockets

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel _channel;

  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    
    _channel.stream.listen((message) {
      // Handle incoming messages
      final data = json.decode(message);
      _handleUpdate(data);
    });
  }

  void _handleUpdate(Map<String, dynamic> data) {
    if (data['type'] == 'fixture_update') {
      // Update fixture
      Get.find<FixturesController>().updateFixture(
        Fixture.fromJson(data['fixture']),
      );
    }
  }
}
```

### Option 2: Firebase Real-time Database

Already using Firebase, so can leverage:

```dart
import 'package:firebase_database/firebase_database.dart';

class FirebaseFixturesService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Stream<List<Fixture>> watchFixtures() {
    return _db.child('fixtures').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return <Fixture>[];
      
      return data.entries
          .map((e) => Fixture.fromJson(e.value))
          .toList();
    });
  }
}
```

## Summary

When ready to integrate with a real API:

1. ✅ Create `ApiService` for HTTP requests
2. ✅ Create `Repository` classes for each feature
3. ✅ Create or update `Controllers` to use repositories
4. ✅ Update screens to use controllers with Obx
5. ✅ Add error, loading, and empty states
6. ✅ Test with mock API server
7. ✅ Add real-time updates if needed
8. ✅ Add proper error logging and analytics

All models are already JSON-ready, so integration will be straightforward!
