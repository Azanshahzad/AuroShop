class UserModel {
  final String id;
  final String email;
  final String name;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.isAdmin = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'isAdmin': isAdmin,
    };
  }
}
