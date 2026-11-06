import 'syncable.dart';

class ReadingArticleModel implements Syncable {
  @override
  final String id;
  @override
  final String? userId;
  final String title;
  final String text;
  final String createdAt;
  final String folder;

  /// Son yerel/bulut değişikliğinin zamanı (ISO-8601 UTC); bulutta yoksa null.
  @override
  final String? updatedAt;

  ReadingArticleModel({
    required this.id,
    this.userId,
    required this.title,
    required this.text,
    required this.createdAt,
    this.folder = 'Genel',
    this.updatedAt,
  });

  factory ReadingArticleModel.fromMap(Map<String, dynamic> map) {
    return ReadingArticleModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? map['userId']?.toString(),
      title: map['title']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      folder: (map['folder']?.toString().trim().isNotEmpty == true) ? map['folder'].toString().trim() : 'Genel',
      updatedAt: map['updated_at']?.toString() ?? map['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toSupabaseRow() {
    final row = <String, dynamic>{
      'id': id,
      'title': title,
      'text': text,
      'created_at': createdAt,
      'folder': folder,
    };
    if (userId != null && userId!.isNotEmpty) {
      row['user_id'] = userId;
    }
    if (updatedAt != null) {
      row['updated_at'] = updatedAt;
    }
    return row;
  }

  Map<String, dynamic> toMap() => toSupabaseRow();

  ReadingArticleModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? text,
    String? createdAt,
    String? folder,
    String? updatedAt,
  }) {
    return ReadingArticleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      folder: folder ?? this.folder,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
