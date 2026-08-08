class ReadingArticleModel {
  final String id;
  final String title;
  final String text;
  final String createdAt;
  final String folder;

  ReadingArticleModel({
    required this.id,
    required this.title,
    required this.text,
    required this.createdAt,
    this.folder = 'Genel',
  });

  factory ReadingArticleModel.fromMap(Map<String, dynamic> map) {
    return ReadingArticleModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      folder: (map['folder']?.toString().trim().isNotEmpty == true) ? map['folder'].toString().trim() : 'Genel',
    );
  }

  Map<String, dynamic> toSupabaseRow() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'created_at': createdAt,
      'folder': folder,
    };
  }

  Map<String, dynamic> toMap() => toSupabaseRow();

  ReadingArticleModel copyWith({
    String? id,
    String? title,
    String? text,
    String? createdAt,
    String? folder,
  }) {
    return ReadingArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      folder: folder ?? this.folder,
    );
  }
}
