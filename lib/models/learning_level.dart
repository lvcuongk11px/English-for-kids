enum LearningLevel {
  firstWords(1, 'First Words', 'Từ đầu tiên'),
  easyInstructions(2, 'Easy Instructions', 'Hướng dẫn ngắn'),
  schoolSentences(3, 'School Sentences', 'Câu ở trường');

  const LearningLevel(this.value, this.label, this.vietnameseLabel);
  final int value;
  final String label;
  final String vietnameseLabel;

  static LearningLevel fromValue(int value) => values.firstWhere(
    (level) => level.value == value,
    orElse: () => LearningLevel.firstWords,
  );
}
