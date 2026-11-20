class VocabularyItem {
  const VocabularyItem({
    required this.id,
    required this.word,
    required this.questionText,
    required this.imagePath,
    required this.questionAudioPath,
  });
  final String id;
  final String word;
  final String questionText;
  final String imagePath;
  final String questionAudioPath;

  factory VocabularyItem.fromJson(Map<String, dynamic> json) => VocabularyItem(
    id: json['id'] as String,
    word: json['word'] as String,
    questionText: json['questionText'] as String,
    imagePath: json['imagePath'] as String,
    questionAudioPath: json['questionAudioPath'] as String,
  );
}
