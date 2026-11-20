import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_level.dart';
import '../models/learning_settings.dart';

class SettingsService {
  const SettingsService();
  Future<LearningSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return LearningSettings(
      level: LearningLevel.fromValue(prefs.getInt('language_level') ?? 1),
      speechRate: prefs.getDouble('speech_rate') ?? 0.82,
      autoAdvanceEnabled: prefs.getBool('auto_next') ?? true,
      soundEffectsEnabled: prefs.getBool('sound_effects') ?? true,
      reviewModeEnabled: prefs.getBool('review_mode') ?? true,
    );
  }

  Future<void> save(LearningSettings value) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt('language_level', value.level.value),
      prefs.setDouble('speech_rate', value.speechRate),
      prefs.setBool('auto_next', value.autoAdvanceEnabled),
      prefs.setBool('sound_effects', value.soundEffectsEnabled),
      prefs.setBool('review_mode', value.reviewModeEnabled),
    ]);
  }
}
