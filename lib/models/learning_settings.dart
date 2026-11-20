import 'learning_level.dart';

class LearningSettings {
  const LearningSettings({
    this.level = LearningLevel.firstWords,
    this.speechRate = 0.82,
    this.successDelay = const Duration(milliseconds: 2700),
    this.questionTransitionDelay = const Duration(milliseconds: 450),
    this.feedbackDuration = const Duration(milliseconds: 650),
    this.autoAdvanceEnabled = true,
    this.soundEffectsEnabled = true,
    this.reviewModeEnabled = true,
  });

  final LearningLevel level;
  final double speechRate;
  final Duration successDelay;
  final Duration questionTransitionDelay;
  final Duration feedbackDuration;
  final bool autoAdvanceEnabled;
  final bool soundEffectsEnabled;
  final bool reviewModeEnabled;

  LearningSettings copyWith({
    LearningLevel? level,
    double? speechRate,
    bool? autoAdvanceEnabled,
    bool? soundEffectsEnabled,
    bool? reviewModeEnabled,
  }) => LearningSettings(
    level: level ?? this.level,
    speechRate: speechRate ?? this.speechRate,
    successDelay: successDelay,
    questionTransitionDelay: questionTransitionDelay,
    feedbackDuration: feedbackDuration,
    autoAdvanceEnabled: autoAdvanceEnabled ?? this.autoAdvanceEnabled,
    soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
    reviewModeEnabled: reviewModeEnabled ?? this.reviewModeEnabled,
  );
}
