class VocabularyEntry {
  const VocabularyEntry({
    required this.id,
    required this.english,
    required this.vietnamese,
    required this.aliases,
    required this.topicIds,
    required this.sourceTypes,
    required this.difficulty,
    required this.imagePath,
    required this.audioPath,
  });

  final String id;
  final String english;
  final String vietnamese;
  final List<String> aliases;
  final List<String> topicIds;
  final List<String> sourceTypes;
  final String difficulty;
  final String? imagePath;
  final String audioPath;
  bool get isPlayable => imagePath != null;
  bool get isSchoolVerified => sourceTypes.contains('school_verified');

  factory VocabularyEntry.fromJson(Map<String, dynamic> json) =>
      VocabularyEntry(
        id: json['id'] as String,
        english: json['english'] as String,
        vietnamese: json['vietnamese'] as String,
        aliases: List<String>.from(json['aliases'] as List<dynamic>),
        topicIds: List<String>.from(json['topicIds'] as List<dynamic>),
        sourceTypes: List<String>.from(json['sourceTypes'] as List<dynamic>),
        difficulty: json['difficulty'] as String,
        imagePath: json['imagePath'] as String?,
        audioPath: json['audioPath'] as String,
      );
}

class LessonDefinition {
  const LessonDefinition({
    required this.id,
    required this.title,
    required this.vietnameseTitle,
    required this.worldId,
    required this.sourceType,
    required this.week,
    required this.schoolLevel,
    required this.vocabularyIds,
    required this.sentencePatterns,
    required this.gameTypes,
  });

  final String id;
  final String title;
  final String vietnameseTitle;
  final String worldId;
  final String sourceType;
  final int? week;
  final String schoolLevel;
  final List<String> vocabularyIds;
  final List<String> sentencePatterns;
  final List<String> gameTypes;

  factory LessonDefinition.fromJson(Map<String, dynamic> json) =>
      LessonDefinition(
        id: json['id'] as String,
        title: json['title'] as String,
        vietnameseTitle: json['vietnameseTitle'] as String,
        worldId: json['worldId'] as String,
        sourceType: json['sourceType'] as String,
        week: json['week'] as int?,
        schoolLevel: json['schoolLevel'] as String,
        vocabularyIds: List<String>.from(
          json['vocabularyIds'] as List<dynamic>,
        ),
        sentencePatterns: List<String>.from(
          json['sentencePatterns'] as List<dynamic>,
        ),
        gameTypes: List<String>.from(json['gameTypes'] as List<dynamic>),
      );
}
