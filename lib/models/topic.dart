import 'vocabulary_item.dart';

class Topic {
  const Topic({
    required this.id,
    required this.englishName,
    required this.vietnameseName,
    required this.coverImagePath,
    required this.accentColor,
    required this.items,
  });
  final String id;
  final String englishName;
  final String vietnameseName;
  final String coverImagePath;
  final int accentColor;
  final List<VocabularyItem> items;

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
    id: json['id'] as String,
    englishName: json['englishName'] as String,
    vietnameseName: json['vietnameseName'] as String,
    coverImagePath: json['coverImagePath'] as String,
    accentColor: int.parse(json['accentColor'] as String, radix: 16),
    items: (json['items'] as List<dynamic>)
        .map((item) => VocabularyItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );
}
