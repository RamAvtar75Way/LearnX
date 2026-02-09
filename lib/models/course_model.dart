import 'module_model.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String thumbnailUrl;
  final String instructorId;
  final String instructorName;
  final double ratingAvg;
  final int totalStudents;
  int get students => totalStudents; // Alias for UI compatibility
  final List<Module> modules; // Helper for UI

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.thumbnailUrl,
    required this.instructorId,
    required this.instructorName,
    this.ratingAvg = 0.0,
    this.totalStudents = 0,
    this.modules = const [],
  });
  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    double? price,
    String? thumbnailUrl,
    String? instructorId,
    String? instructorName,
    double? ratingAvg,
    int? totalStudents,
    List<Module>? modules,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      totalStudents: totalStudents ?? this.totalStudents,
      modules: modules ?? this.modules,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'thumbnailUrl': thumbnailUrl,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'ratingAvg': ratingAvg,
      'totalStudents': totalStudents,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? 'Unknown',
      ratingAvg: (map['ratingAvg'] ?? 0.0).toDouble(),
      totalStudents: map['totalStudents'] ?? 0,
    );
  }
}
