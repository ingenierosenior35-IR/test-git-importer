import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/player_stats.dart';

class MatchAnalysis {
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final String coachFeedback;

  MatchAnalysis({
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.coachFeedback,
  });
}

class AIService {
  static const String _apiKey = 'YOUR_API_KEY_HERE';

  Future<MatchAnalysis> analyzeMatch(PlayerStats stats) async {
    try {
      final summary = await _generateSummary(stats);
      final strengths = _identifyStrengths(stats);
      final improvements = _suggestImprovements(stats);
      final coachFeedback = _generateCoachFeedback(stats, strengths, improvements);

      return MatchAnalysis(
        summary: summary,
        strengths: strengths,
        improvements: improvements,
        coachFeedback: coachFeedback,
      );
    } catch (e) {
      debugPrint('Error analyzing match: $e');
      return MatchAnalysis(
        summary: _generateFallbackSummary(stats),
        strengths: _identifyStrengths(stats),
        improvements: _suggestImprovements(stats),
        coachFeedback: 'Análisis completado. Revisa tus estadísticas para más detalles.',
      );
    }
  }

  Future<String> _generateSummary(PlayerStats stats) async {
    try {
      final prompt = '''
Analiza el siguiente rendimiento de un jugador de fútbol y genera un resumen en español:

Estadísticas Físicas:
- Distancia: ${stats.physical.distanceM.toStringAsFixed(0)}m
- Velocidad promedio: ${stats.physical.avgSpeedKmh.toStringAsFixed(1)} km/h
- Velocidad máxima: ${stats.physical.maxSpeedKmh.toStringAsFixed(1)} km/h
- Sprints: ${stats.physical.sprintCount}
- Minutos jugados: ${stats.physical.minutesPlayed.toStringAsFixed(0)}

Estadísticas de Pases:
- Pases completados: ${stats.passing.passesCompleted}/${stats.passing.passesAttempted}
- Precisión: ${stats.passing.passAccuracyPct.toStringAsFixed(1)}%
- Asistencias: ${stats.passing.assists}

Estadísticas Defensivas:
- Tackles: ${stats.defensive.tackles}
- Intercepciones: ${stats.defensive.interceptions}
- Duelos ganados: ${stats.defensive.duelsWon}

Puntuación de Impacto: ${stats.advanced.impactScore.toStringAsFixed(1)}/10
Índice de Fatiga: ${(stats.fatigue.fatigueIndex * 100).toStringAsFixed(0)}%

Genera un resumen conciso de 2-3 oraciones sobre el rendimiento general del jugador.
''';

      return await _callAI(prompt);
    } catch (e) {
      debugPrint('Error generating summary with AI: $e');
      return _generateFallbackSummary(stats);
    }
  }

  Future<String> _callAI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'Eres un entrenador de fútbol profesional que analiza el rendimiento de jugadores.'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        throw Exception('AI API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error calling AI API: $e');
      rethrow;
    }
  }

  String _generateFallbackSummary(PlayerStats stats) {
    final impactLevel = stats.advanced.impactScore >= 7.5 
        ? 'excelente' 
        : stats.advanced.impactScore >= 6.0 
            ? 'sólido' 
            : 'mejorable';

    return 'Rendimiento $impactLevel con ${stats.physical.distanceM.toStringAsFixed(0)}m recorridos y una precisión de pases del ${stats.passing.passAccuracyPct.toStringAsFixed(0)}%. '
           'El jugador mostró ${stats.physical.sprintCount} sprints y completó ${stats.passing.assists} asistencias durante ${stats.physical.minutesPlayed.toStringAsFixed(0)} minutos de juego.';
  }

  List<String> _identifyStrengths(PlayerStats stats) {
    final strengths = <String>[];

    if (stats.passing.passAccuracyPct >= 80.0) {
      strengths.add('Excelente precisión de pases (${stats.passing.passAccuracyPct.toStringAsFixed(0)}%)');
    }

    if (stats.physical.maxSpeedKmh >= 25.0) {
      strengths.add('Alta velocidad máxima alcanzada (${stats.physical.maxSpeedKmh.toStringAsFixed(1)} km/h)');
    }

    if (stats.defensive.tackles >= 5) {
      strengths.add('Buen desempeño defensivo con ${stats.defensive.tackles} tackles');
    }

    if (stats.passing.assists >= 2) {
      strengths.add('Importante contribución ofensiva con ${stats.passing.assists} asistencias');
    }

    if (stats.ballInteraction.touches >= 40) {
      strengths.add('Alta participación en el juego (${stats.ballInteraction.touches} toques)');
    }

    if (stats.advanced.impactScore >= 7.5) {
      strengths.add('Puntuación de impacto destacada (${stats.advanced.impactScore.toStringAsFixed(1)}/10)');
    }

    if (strengths.isEmpty) {
      strengths.add('Completó el partido con esfuerzo constante');
    }

    return strengths.take(4).toList();
  }

  List<String> _suggestImprovements(PlayerStats stats) {
    final improvements = <String>[];

    if (stats.passing.passAccuracyPct < 70.0) {
      improvements.add('Mejorar la precisión de pases (actualmente ${stats.passing.passAccuracyPct.toStringAsFixed(0)}%)');
    }

    if (stats.physical.sprintCount < 3) {
      improvements.add('Aumentar la intensidad con más sprints explosivos');
    }

    if (stats.defensive.interceptions < 3) {
      improvements.add('Trabajar en la anticipación e intercepción de balones');
    }

    if (stats.fatigue.fatigueIndex > 0.75) {
      improvements.add('Gestionar mejor la fatiga durante el partido');
    }

    if (stats.ballInteraction.ballLosses > 5) {
      improvements.add('Reducir las pérdidas de balón (${stats.ballInteraction.ballLosses} pérdidas)');
    }

    if (stats.advanced.impactScore < 6.0) {
      improvements.add('Incrementar la contribución general al equipo');
    }

    if (improvements.isEmpty) {
      improvements.add('Mantener la consistencia en el rendimiento');
    }

    return improvements.take(3).toList();
  }

  String _generateCoachFeedback(PlayerStats stats, List<String> strengths, List<String> improvements) {
    final performanceLevel = stats.advanced.impactScore >= 7.5 
        ? 'Excelente partido' 
        : stats.advanced.impactScore >= 6.0 
            ? 'Buen desempeño' 
            : 'Partido con áreas de mejora';

    return '$performanceLevel. ${strengths.isNotEmpty ? "Destacan: ${strengths.first.toLowerCase()}. " : ""}'
           '${improvements.isNotEmpty ? "Área de trabajo: ${improvements.first.toLowerCase()}. " : ""}'
           'Sigue entrenando con dedicación para alcanzar tu máximo potencial.';
  }
}
