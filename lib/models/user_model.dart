class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'instructor' or 'learner'
  final String? profileImage;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profileImage,
  });
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? profileImage,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'learner',
      profileImage: map['profileImage'],
    );
  }
}
