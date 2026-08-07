class ReadingArticleModel {
  final String id;
  final String title;
  final String text;
  final String createdAt;

  ReadingArticleModel({
    required this.id,
    required this.title,
    required this.text,
    required this.createdAt,
  });

  factory ReadingArticleModel.fromMap(Map<String, dynamic> map) {
    return ReadingArticleModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toSupabaseRow() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'created_at': createdAt,
    };
  }

  Map<String, dynamic> toMap() => toSupabaseRow();
}
