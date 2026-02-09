class Physical {
  final double distanceM;
  final double avgSpeedKmh;
  final double maxSpeedKmh;
  final int sprintCount;
  final double sprintDistanceM;
  final int highIntensityRuns;
  final double accelerationMaxMS2;
  final double decelerationMaxMS2;
  final double minutesPlayed;

  Physical({
    required this.distanceM,
    required this.avgSpeedKmh,
    required this.maxSpeedKmh,
    required this.sprintCount,
    required this.sprintDistanceM,
    required this.highIntensityRuns,
    required this.accelerationMaxMS2,
    required this.decelerationMaxMS2,
    required this.minutesPlayed,
  });

  factory Physical.fromJson(Map<String, dynamic> json) {
    return Physical(
      distanceM: (json['distance_m'] as num).toDouble(),
      avgSpeedKmh: (json['avg_speed_kmh'] as num).toDouble(),
      maxSpeedKmh: (json['max_speed_kmh'] as num).toDouble(),
      sprintCount: json['sprint_count'] as int,
      sprintDistanceM: (json['sprint_distance_m'] as num).toDouble(),
      highIntensityRuns: json['high_intensity_runs'] as int,
      accelerationMaxMS2: (json['acceleration_max_m_s2'] as num).toDouble(),
      decelerationMaxMS2: (json['deceleration_max_m_s2'] as num).toDouble(),
      minutesPlayed: (json['minutes_played'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance_m': distanceM,
      'avg_speed_kmh': avgSpeedKmh,
      'max_speed_kmh': maxSpeedKmh,
      'sprint_count': sprintCount,
      'sprint_distance_m': sprintDistanceM,
      'high_intensity_runs': highIntensityRuns,
      'acceleration_max_m_s2': accelerationMaxMS2,
      'deceleration_max_m_s2': decelerationMaxMS2,
      'minutes_played': minutesPlayed,
    };
  }
}

class Position {
  final double x;
  final double y;

  Position({required this.x, required this.y});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y};
  }
}

class Positioning {
  final Position avgPosition;
  final int fieldCoveragePct;
  final List<int> heatmapZones;
  final double offensiveLineAvgM;
  final double defensiveLineAvgM;

  Positioning({
    required this.avgPosition,
    required this.fieldCoveragePct,
    required this.heatmapZones,
    required this.offensiveLineAvgM,
    required this.defensiveLineAvgM,
  });

  factory Positioning.fromJson(Map<String, dynamic> json) {
    return Positioning(
      avgPosition: Position.fromJson(json['avg_position'] as Map<String, dynamic>),
      fieldCoveragePct: json['field_coverage_pct'] as int,
      heatmapZones: List<int>.from(json['heatmap_zones'] as List),
      offensiveLineAvgM: (json['offensive_line_avg_m'] as num).toDouble(),
      defensiveLineAvgM: (json['defensive_line_avg_m'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avg_position': avgPosition.toJson(),
      'field_coverage_pct': fieldCoveragePct,
      'heatmap_zones': heatmapZones,
      'offensive_line_avg_m': offensiveLineAvgM,
      'defensive_line_avg_m': defensiveLineAvgM,
    };
  }
}

class BallInteraction {
  final int touches;
  final double timeInPossessionS;
  final double avgTouchDurationS;
  final int ballRecoveries;
  final int ballLosses;

  BallInteraction({
    required this.touches,
    required this.timeInPossessionS,
    required this.avgTouchDurationS,
    required this.ballRecoveries,
    required this.ballLosses,
  });

  factory BallInteraction.fromJson(Map<String, dynamic> json) {
    return BallInteraction(
      touches: json['touches'] as int,
      timeInPossessionS: (json['time_in_possession_s'] as num).toDouble(),
      avgTouchDurationS: (json['avg_touch_duration_s'] as num).toDouble(),
      ballRecoveries: json['ball_recoveries'] as int,
      ballLosses: json['ball_losses'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'touches': touches,
      'time_in_possession_s': timeInPossessionS,
      'avg_touch_duration_s': avgTouchDurationS,
      'ball_recoveries': ballRecoveries,
      'ball_losses': ballLosses,
    };
  }
}

class Passing {
  final int passesAttempted;
  final int passesCompleted;
  final double passAccuracyPct;
  final double avgPassLengthM;
  final int forwardPasses;
  final int backwardPasses;
  final int lateralPasses;
  final int keyPasses;
  final int assists;
  final int preAssists;

  Passing({
    required this.passesAttempted,
    required this.passesCompleted,
    required this.passAccuracyPct,
    required this.avgPassLengthM,
    required this.forwardPasses,
    required this.backwardPasses,
    required this.lateralPasses,
    required this.keyPasses,
    required this.assists,
    required this.preAssists,
  });

  factory Passing.fromJson(Map<String, dynamic> json) {
    return Passing(
      passesAttempted: json['passes_attempted'] as int,
      passesCompleted: json['passes_completed'] as int,
      passAccuracyPct: (json['pass_accuracy_pct'] as num).toDouble(),
      avgPassLengthM: (json['avg_pass_length_m'] as num).toDouble(),
      forwardPasses: json['forward_passes'] as int,
      backwardPasses: json['backward_passes'] as int,
      lateralPasses: json['lateral_passes'] as int,
      keyPasses: json['key_passes'] as int,
      assists: json['assists'] as int,
      preAssists: json['pre_assists'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passes_attempted': passesAttempted,
      'passes_completed': passesCompleted,
      'pass_accuracy_pct': passAccuracyPct,
      'avg_pass_length_m': avgPassLengthM,
      'forward_passes': forwardPasses,
      'backward_passes': backwardPasses,
      'lateral_passes': lateralPasses,
      'key_passes': keyPasses,
      'assists': assists,
      'pre_assists': preAssists,
    };
  }
}

class Defensive {
  final int tackles;
  final int interceptions;
  final int pressures;
  final int duelsWon;
  final int duelsLost;
  final int blocks;

  Defensive({
    required this.tackles,
    required this.interceptions,
    required this.pressures,
    required this.duelsWon,
    required this.duelsLost,
    required this.blocks,
  });

  factory Defensive.fromJson(Map<String, dynamic> json) {
    return Defensive(
      tackles: json['tackles'] as int,
      interceptions: json['interceptions'] as int,
      pressures: json['pressures'] as int,
      duelsWon: json['duels_won'] as int,
      duelsLost: json['duels_lost'] as int,
      blocks: json['blocks'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tackles': tackles,
      'interceptions': interceptions,
      'pressures': pressures,
      'duels_won': duelsWon,
      'duels_lost': duelsLost,
      'blocks': blocks,
    };
  }
}

class Fatigue {
  final double fatigueIndex;
  final double consistencyIndex;
  final double speedDropPct;

  Fatigue({
    required this.fatigueIndex,
    required this.consistencyIndex,
    required this.speedDropPct,
  });

  factory Fatigue.fromJson(Map<String, dynamic> json) {
    return Fatigue(
      fatigueIndex: (json['fatigue_index'] as num).toDouble(),
      consistencyIndex: (json['consistency_index'] as num).toDouble(),
      speedDropPct: (json['speed_drop_pct'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fatigue_index': fatigueIndex,
      'consistency_index': consistencyIndex,
      'speed_drop_pct': speedDropPct,
    };
  }
}

class EstimatedBiometrics {
  final double estimatedHeightM;
  final double estimatedWeightKg;
  final double strideLengthM;
  final int cadenceStepsPerMin;
  final int jumpEstimatedCm;
  final double confidence;

  EstimatedBiometrics({
    required this.estimatedHeightM,
    required this.estimatedWeightKg,
    required this.strideLengthM,
    required this.cadenceStepsPerMin,
    required this.jumpEstimatedCm,
    required this.confidence,
  });

  factory EstimatedBiometrics.fromJson(Map<String, dynamic> json) {
    return EstimatedBiometrics(
      estimatedHeightM: (json['estimated_height_m'] as num).toDouble(),
      estimatedWeightKg: (json['estimated_weight_kg'] as num).toDouble(),
      strideLengthM: (json['stride_length_m'] as num).toDouble(),
      cadenceStepsPerMin: json['cadence_steps_per_min'] as int,
      jumpEstimatedCm: json['jump_estimated_cm'] as int,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimated_height_m': estimatedHeightM,
      'estimated_weight_kg': estimatedWeightKg,
      'stride_length_m': strideLengthM,
      'cadence_steps_per_min': cadenceStepsPerMin,
      'jump_estimated_cm': jumpEstimatedCm,
      'confidence': confidence,
    };
  }
}

class Advanced {
  final double impactScore;
  final double offensiveContribution;
  final double defensiveContribution;
  final double versatilityIndex;

  Advanced({
    required this.impactScore,
    required this.offensiveContribution,
    required this.defensiveContribution,
    required this.versatilityIndex,
  });

  factory Advanced.fromJson(Map<String, dynamic> json) {
    return Advanced(
      impactScore: (json['impact_score'] as num).toDouble(),
      offensiveContribution: (json['offensive_contribution'] as num).toDouble(),
      defensiveContribution: (json['defensive_contribution'] as num).toDouble(),
      versatilityIndex: (json['versatility_index'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'impact_score': impactScore,
      'offensive_contribution': offensiveContribution,
      'defensive_contribution': defensiveContribution,
      'versatility_index': versatilityIndex,
    };
  }
}

class PlayerStats {
  final int playerId;
  final int teamId;
  final Physical physical;
  final Positioning positioning;
  final BallInteraction ballInteraction;
  final Passing passing;
  final Defensive defensive;
  final Fatigue fatigue;
  final EstimatedBiometrics estimatedBiometrics;
  final Advanced advanced;

  PlayerStats({
    required this.playerId,
    required this.teamId,
    required this.physical,
    required this.positioning,
    required this.ballInteraction,
    required this.passing,
    required this.defensive,
    required this.fatigue,
    required this.estimatedBiometrics,
    required this.advanced,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      playerId: json['player_id'] as int,
      teamId: json['team_id'] as int,
      physical: Physical.fromJson(json['physical'] as Map<String, dynamic>),
      positioning: Positioning.fromJson(json['positioning'] as Map<String, dynamic>),
      ballInteraction: BallInteraction.fromJson(json['ball_interaction'] as Map<String, dynamic>),
      passing: Passing.fromJson(json['passing'] as Map<String, dynamic>),
      defensive: Defensive.fromJson(json['defensive'] as Map<String, dynamic>),
      fatigue: Fatigue.fromJson(json['fatigue'] as Map<String, dynamic>),
      estimatedBiometrics: EstimatedBiometrics.fromJson(json['estimated_biometrics'] as Map<String, dynamic>),
      advanced: Advanced.fromJson(json['advanced'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'team_id': teamId,
      'physical': physical.toJson(),
      'positioning': positioning.toJson(),
      'ball_interaction': ballInteraction.toJson(),
      'passing': passing.toJson(),
      'defensive': defensive.toJson(),
      'fatigue': fatigue.toJson(),
      'estimated_biometrics': estimatedBiometrics.toJson(),
      'advanced': advanced.toJson(),
    };
  }
}
