import '../models/fixture_model.dart';

class FixturesMockData {
  static List<Fixture> getMockFixtures() {
    final now = DateTime.now();
    
    return [
      // Finished matches
      Fixture(
        id: '1',
        homeTeam: 'Real Madrid',
        awayTeam: 'Barcelona',
        homeScore: '2',
        awayScore: '1',
        dateTime: now.subtract(const Duration(days: 2)),
        competition: 'La Liga',
        status: 'finished',
        venue: 'Santiago Bernabéu',
      ),
      Fixture(
        id: '2',
        homeTeam: 'Atlético Madrid',
        awayTeam: 'Valencia',
        homeScore: '1',
        awayScore: '1',
        dateTime: now.subtract(const Duration(days: 3)),
        competition: 'La Liga',
        status: 'finished',
        venue: 'Metropolitano',
      ),
      Fixture(
        id: '3',
        homeTeam: 'Sevilla',
        awayTeam: 'Real Betis',
        homeScore: '3',
        awayScore: '0',
        dateTime: now.subtract(const Duration(days: 5)),
        competition: 'La Liga',
        status: 'finished',
        venue: 'Ramón Sánchez-Pizjuán',
      ),
      // Upcoming matches
      Fixture(
        id: '4',
        homeTeam: 'Barcelona',
        awayTeam: 'Atlético Madrid',
        dateTime: now.add(const Duration(days: 2)),
        competition: 'La Liga',
        status: 'scheduled',
        venue: 'Camp Nou',
      ),
      Fixture(
        id: '5',
        homeTeam: 'Valencia',
        awayTeam: 'Real Madrid',
        dateTime: now.add(const Duration(days: 4)),
        competition: 'La Liga',
        status: 'scheduled',
        venue: 'Mestalla',
      ),
      Fixture(
        id: '6',
        homeTeam: 'Real Madrid',
        awayTeam: 'Sevilla',
        dateTime: now.add(const Duration(days: 7)),
        competition: 'Copa del Rey',
        status: 'scheduled',
        venue: 'Santiago Bernabéu',
      ),
      Fixture(
        id: '7',
        homeTeam: 'Atlético Madrid',
        awayTeam: 'Barcelona',
        dateTime: now.add(const Duration(days: 10)),
        competition: 'La Liga',
        status: 'scheduled',
        venue: 'Metropolitano',
      ),
      Fixture(
        id: '8',
        homeTeam: 'Real Betis',
        awayTeam: 'Valencia',
        dateTime: now.add(const Duration(days: 12)),
        competition: 'La Liga',
        status: 'scheduled',
        venue: 'Benito Villamarín',
      ),
    ];
  }

  static List<Fixture> getFixturesForTeam(String teamName) {
    return getMockFixtures()
        .where((fixture) =>
            fixture.homeTeam.toLowerCase().contains(teamName.toLowerCase()) ||
            fixture.awayTeam.toLowerCase().contains(teamName.toLowerCase()))
        .toList();
  }

  static List<Fixture> getUpcomingFixtures() {
    return getMockFixtures()
        .where((fixture) => fixture.isScheduled)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  static List<Fixture> getFinishedFixtures() {
    return getMockFixtures()
        .where((fixture) => fixture.isFinished)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }
}
