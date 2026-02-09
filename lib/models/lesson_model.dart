class Lesson {
  final String id;
  final String title;
  final String type; // 'video', 'document', 'image', 'text'
  final String contentUrl; // URL for video/doc/image or text content
  final int durationSeconds;
  final bool isCompleted; // Local state helper

  Lesson({
    required this.id,
    required this.title,
    required this.type,
    required this.contentUrl,
    this.durationSeconds = 0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'contentUrl': contentUrl,
      'durationSeconds': durationSeconds,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? 'text',
      contentUrl: map['contentUrl'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 0,
    );
  }
}
