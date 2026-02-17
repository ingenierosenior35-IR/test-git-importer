import '../models/poll_model.dart';

class PollsMockData {
  static List<Poll> getMockPolls() {
    final now = DateTime.now();
    
    return [
      Poll(
        id: '1',
        name: 'La Liga 2024 - Amigos',
        description: 'Polla de predicciones para la temporada de La Liga con amigos',
        creatorId: 'user1',
        creatorName: 'Carlos García',
        createdAt: now.subtract(const Duration(days: 30)),
        participantIds: ['user1', 'user2', 'user3', 'user4', 'user5'],
        status: 'active',
      ),
      Poll(
        id: '2',
        name: 'Champions League Final',
        description: 'Predicciones para la final de la Champions League',
        creatorId: 'user2',
        creatorName: 'María López',
        createdAt: now.subtract(const Duration(days: 15)),
        participantIds: ['user1', 'user2', 'user3', 'user6'],
        status: 'active',
      ),
      Poll(
        id: '3',
        name: 'Copa del Rey',
        description: 'Polla para todos los partidos de la Copa del Rey',
        creatorId: 'user1',
        creatorName: 'Carlos García',
        createdAt: now.subtract(const Duration(days: 60)),
        participantIds: ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7'],
        status: 'active',
      ),
      Poll(
        id: '4',
        name: 'Mundial Qatar - Finalizado',
        description: 'Polla del Mundial de Qatar 2022',
        creatorId: 'user3',
        creatorName: 'Juan Pérez',
        createdAt: now.subtract(const Duration(days: 400)),
        participantIds: ['user1', 'user2', 'user3', 'user4'],
        status: 'finished',
      ),
    ];
  }

  static List<PollStanding> getMockStandings(String pollId) {
    return [
      PollStanding(
        userId: 'user1',
        userName: 'Carlos García',
        points: 145,
        correctPredictions: 12,
        totalPredictions: 20,
      ),
      PollStanding(
        userId: 'user2',
        userName: 'María López',
        points: 132,
        correctPredictions: 11,
        totalPredictions: 20,
      ),
      PollStanding(
        userId: 'user3',
        userName: 'Juan Pérez',
        points: 128,
        correctPredictions: 10,
        totalPredictions: 20,
      ),
      PollStanding(
        userId: 'user4',
        userName: 'Ana Martínez',
        points: 115,
        correctPredictions: 9,
        totalPredictions: 20,
      ),
      PollStanding(
        userId: 'user5',
        userName: 'Pedro Sánchez',
        points: 98,
        correctPredictions: 8,
        totalPredictions: 18,
      ),
    ];
  }

  static List<PollPrediction> getMockPredictions(String pollId) {
    final now = DateTime.now();
    
    return [
      PollPrediction(
        id: 'pred1',
        pollId: pollId,
        userId: 'user1',
        userName: 'Carlos García',
        fixtureId: '1',
        homeTeamPrediction: '2',
        awayTeamPrediction: '1',
        predictedAt: now.subtract(const Duration(days: 3)),
        points: 15,
      ),
      PollPrediction(
        id: 'pred2',
        pollId: pollId,
        userId: 'user2',
        userName: 'María López',
        fixtureId: '1',
        homeTeamPrediction: '1',
        awayTeamPrediction: '1',
        predictedAt: now.subtract(const Duration(days: 3)),
        points: 5,
      ),
      PollPrediction(
        id: 'pred3',
        pollId: pollId,
        userId: 'user3',
        userName: 'Juan Pérez',
        fixtureId: '1',
        homeTeamPrediction: '3',
        awayTeamPrediction: '0',
        predictedAt: now.subtract(const Duration(days: 3)),
        points: 3,
      ),
    ];
  }

  static Poll? getPollById(String pollId) {
    try {
      return getMockPolls().firstWhere((poll) => poll.id == pollId);
    } catch (e) {
      return null;
    }
  }

  static List<Poll> getActivePolls() {
    return getMockPolls().where((poll) => poll.isActive).toList();
  }

  static List<Poll> getFinishedPolls() {
    return getMockPolls().where((poll) => poll.isFinished).toList();
  }
}
