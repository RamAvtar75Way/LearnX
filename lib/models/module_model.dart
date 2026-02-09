import 'lesson_model.dart';

class Module {
  final String id;
  final String title;
  final int order;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.title,
    required this.order,
    this.lessons = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'order': order,
       // lessons are usually stored as a subcollection in Firestore, 
       // but for local object we might want them. 
       // For toMap (saving to DB), we might not save lessons array directly if using subcollections.
       // However, strictly following the prompt "Modules Subcollection", "Lessons Subcollection".
       // So we won't store lessons in the module map.
    };
  }

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      order: map['order'] ?? 0,
    );
  }
}
