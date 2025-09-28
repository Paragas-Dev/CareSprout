import 'dart:math';

class InterventionDifficulty {
  final int minSteps;
  final int maxSteps;
  final bool hintsVisible;
  final int distractions;
  final int? timeLimitSeconds;

  InterventionDifficulty({
    required this.minSteps,
    required this.maxSteps,
    required this.hintsVisible,
    required this.distractions,
    this.timeLimitSeconds,
  });

  // Steps to use (e.g., Brushing Teeth).
  int stepsForTotal(int total) => min(maxSteps + 1, max(minSteps, total));

  // Pairs to use (e.g., Getting Dressed). Same as stepsForTotal for clarity.
  int pairsForTotal(int totalPairs) => stepsForTotal(totalPairs);

  // Decoys to add given available decoys in assets.
  // Most games do distractions * 2.
  int decoysForAvailable(int available) => min(available, distractions * 2);

  // For tap/spot games: ensure enough taps; keeps at least baseSpots.
  int tapsForBase(int baseSpots) => max(baseSpots, maxSteps);

  bool get hasTimer => timeLimitSeconds != null;
}

// Level bands:
// 1-3    Basic Routine, 1-2 steps
// 4-6    Hints Visible, 2-3 steps
// 7-9    With Distractions, 3-4 steps
// 10-12  Less hints, 4-5 steps
// 13-15  Full steps, Time challenges
InterventionDifficulty difficultyForLevel(int level) {
  if (level <= 3) {
    return InterventionDifficulty(
      minSteps: 1,
      maxSteps: 2,
      hintsVisible: true,
      distractions: 0,
      timeLimitSeconds: null,
    );
  } else if (level <= 6) {
    return InterventionDifficulty(
      minSteps: 2,
      maxSteps: 3,
      hintsVisible: true,
      distractions: 0,
      timeLimitSeconds: null,
    );
  } else if (level <= 9) {
    return InterventionDifficulty(
      minSteps: 3,
      maxSteps: 4,
      hintsVisible: true,
      distractions: 1,
      timeLimitSeconds: null,
    );
  } else if (level <= 12) {
    return InterventionDifficulty(
      minSteps: 4,
      maxSteps: 5,
      hintsVisible: false,
      distractions: 1,
      timeLimitSeconds: null,
    );
  } else {
    return InterventionDifficulty(
      minSteps: 4,
      maxSteps: 5,
      hintsVisible: false,
      distractions: 2,
      timeLimitSeconds: 90,
    );
  }
}
